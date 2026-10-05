-- Position "[i/n]" badge on the USER message block the cursor is in, on the
-- message's first *body* line (header lines get clobbered by markdown-rule
-- rendering). The total counts only *cached* user messages.
local user_msg_badge_ns = vim.api.nvim_create_namespace("opencode_user_msg_badge")

-- Badge color: default-link to `Special`; override `OpencodeUserMsgBadge` to taste.
local function set_user_msg_badge_hl()
  vim.api.nvim_set_hl(0, "OpencodeUserMsgBadge", { link = "Special", default = true })
end
set_user_msg_badge_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_user_msg_badge_hl })

---First body line (1-indexed) of a rendered message: the first content part's
---start line, falling back to the message's own header line. The message-level
---range covers only the separator/header; the body lives in part ranges.
---Part lookup must go through ctx.content_key: v2 text/reasoning parts have
---no `id` and are registered as "<message_id>:content:<index>".
---@return integer? # 1-indexed line, nil if the message isn't rendered
local function message_body_line(ctx, m)
  local r = ctx.render_state:get_message(m.id)
  if not r or not r.line_start then return nil end
  for i, part in ipairs(m.content or {}) do
    if part.kind ~= "step_start" and part.kind ~= "step_finish" then
      local p = ctx.render_state:get_part(ctx.content_key(m, i))
      if p and p.line_start then return p.line_start + 1 end
    end
  end
  return r.line_start + 1
end

local function update_user_msg_badge(win)
  local state = require("opencode.state")
  local buf = state.windows and state.windows.output_buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  local ctx = require("opencode.ui.renderer.ctx").current()

  -- The current block owner is the last message (any kind) whose header is
  -- at/above the cursor; show the badge only when that owner is a USER message.
  local line = vim.api.nvim_win_get_cursor(win)[1]
  local total, owner_index, owner = 0, nil, nil
  for _, m in ipairs(ctx.entries) do
    if m.kind == "user" then total = total + 1 end
    local r = ctx.render_state:get_message(m.id)
    if r and r.line_start and r.line_start + 1 <= line then
      owner = m
      owner_index = m.kind == "user" and total or nil
    end
  end

  vim.api.nvim_buf_clear_namespace(buf, user_msg_badge_ns, 0, -1)
  local body = owner and message_body_line(ctx, owner)
  if owner_index and body then
    vim.api.nvim_buf_set_extmark(buf, user_msg_badge_ns, body - 1, 0, {
      virt_text = { { ("[%d/%d]"):format(owner_index, total), "OpencodeUserMsgBadge" } },
      virt_text_pos = "right_align",
    })
  end
end

---Expand unrendered history above the cursor (for `prev`-direction jumps).
---Lazy render shows only a tail window, so older entries may be unrendered.
---Expansion only prepends older messages, so it can only help jumping up.
---Guarded against re-expanding when everything cached is already rendered:
---a full re-render per extra press at the true top churns the buffer and lets
---scheduled follow-up work (markdown re-render, history pulls) move the
---cursor, which then eats the next few jump presses.
---@param ctx table render context
---@param current_line0 integer 0-indexed cursor line
---@return integer? base0 # 0-indexed line to re-search from, nil when nothing expanded
local function expand_unrendered_above(ctx, current_line0)
  local first = ctx.entries[1]
  local first_rendered = first and ctx.render_state:get_message(first.id)
  local has_unrendered_above = ctx.lazy_render_count ~= nil
    and ctx.lazy_render_count ~= math.huge
    and first ~= nil
    and not (first_rendered and first_rendered.line_start)
  if not has_unrendered_above then return nil end

  -- Remember the block under the cursor; expansion prepends lines.
  local anchor_id
  for _, m in ipairs(ctx.entries) do
    local r = ctx.render_state:get_message(m.id)
    if r and r.line_start and r.line_start <= current_line0 then anchor_id = m.id end
  end

  local renderer = require("opencode.ui.renderer")
  ctx.lazy_render_count = math.huge
  renderer.render_from_cache(ctx, { scroll_to_bottom = false })
  if not anchor_id then return 0 end
  local r = renderer.get_rendered_message(anchor_id)
  return (r and r.line_start) or 0
end

-- Jump between file-change blocks (edit / apply_patch / patch; `write` has no
-- diff action) via the render state's registered actions, not text search.
local function goto_file_change(forward)
  local state = require("opencode.state")
  require("opencode.ui.ui").focus_output()
  local win = state.windows and state.windows.output_win
  if not win or not vim.api.nvim_win_is_valid(win) then return end
  local ctx = require("opencode.ui.renderer.ctx").current()

  local function find_target(from_line0)
    local best
    for _, action in ipairs(ctx.render_state:get_all_actions()) do
      if action.type == "diff_toggle_file" and action.display_line then
        local l = action.display_line
        if forward and l > from_line0 and (not best or l < best) then best = l end
        if not forward and l < from_line0 and (not best or l > best) then best = l end
      end
    end
    return best
  end

  local current_line0 = vim.api.nvim_win_get_cursor(win)[1] - 1
  local target = find_target(current_line0)

  if not target and not forward then
    local base0 = expand_unrendered_above(ctx, current_line0)
    if base0 then target = find_target(base0) end
  end

  if target then
    pcall(vim.api.nvim_win_call, win, function() vim.cmd([[noau normal! m']]) end)
    vim.api.nvim_win_set_cursor(win, { target + 1, 0 })
  end
  -- At the boundary: stay put silently (no notification).
  update_user_msg_badge(win)
end

-- OSC 9;4 progress indicator on the terminal tab: spinner while busy, paused
-- at 50% on pending permission, cleared when done. Written to Neovim's stdout.
local term_progress = (function()
  local osc = {
    busy = "\027]9;4;3;0\007",
    idle = "\027]9;4;0;0\007",
    waiting = "\027]9;4;4;50\007",
  }
  local busy, waiting = {}, {}
  local current = "idle"

  local function refresh()
    local state
    if next(waiting) then
      state = "waiting"
    elseif next(busy) then
      state = "busy"
    else
      state = "idle"
    end
    if state == current then return end
    current = state
    io.stdout:write(osc[state])
    io.stdout:flush()
  end

  return {
    on_submit = function(session_id)
      if session_id then busy[session_id] = true end
      refresh()
    end,
    on_done = function(session)
      local id = session and session.id
      if id then
        busy[id] = nil
        waiting[id] = nil
      end
      refresh()
    end,
    on_permission = function(session)
      local id = session and session.id
      if id then waiting[id] = true end
      refresh()
    end,
    clear = function()
      current = "idle"
      io.stdout:write(osc.idle)
      io.stdout:flush()
    end,
  }
end)()

vim.api.nvim_create_autocmd("VimLeavePre", { callback = term_progress.clear })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "opencode", "opencode_output" },
  callback = function(event)
    -- AstroNvim maps `q` to close for nofile buffers on BufWinEnter; pre-empt it
    -- with a <Nop> so `q` stays inert in opencode windows (like the disabled <Esc>).
    vim.keymap.set("n", "q", "<Nop>", { buffer = event.buf })
    -- <M-f>: toggle current-file context (= "Current File" in the `#` picker; config default off).
    vim.keymap.set({ "n", "i" }, "<M-f>", function()
      require("opencode.context").toggle_context("current_file")
    end, { buffer = event.buf, desc = "Toggle current file context" })
    if event.match ~= "opencode_output" then return end
    -- Registered here instead of the plugin's output_window keymap table:
    -- the plugin re-processes function-valued window keymaps on every
    -- windows-store update with preserve_existing, and once the mapping
    -- exists it spams "No action found for keymap" warnings (plugin bug).
    vim.keymap.set("n", "<M-N>", function() goto_file_change(true) end, {
      buffer = event.buf,
      desc = "Next file change",
    })
    vim.keymap.set("n", "<M-P>", function() goto_file_change(false) end, {
      buffer = event.buf,
      desc = "Prev file change",
    })
    -- Recompute the [i/n] badge on CursorMoved: survives Neovim firing
    -- CursorMoved after the jump keymap returns, which would wipe the badge.
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = event.buf,
      callback = function()
        local st = require("opencode.state")
        local w = st.windows and st.windows.output_win
        if w and vim.api.nvim_win_is_valid(w) then update_user_msg_badge(w) end
      end,
    })
  end,
})

return {
  {
    "sudo-tee/opencode.nvim",
    branch = "v2", -- OpenCode v2 support (testing branch, not yet merged to main)
    cmd = { "Opencode" },
    keys = {
      { "<M-o>", mode = { "n", "i" }, desc = "Toggle windows" },
      { "<Leader>a/", mode = { "n", "x" }, desc = "Quick chat" },
      { "<Leader>aa", desc = "Session picker" },
      { "<Leader>ad", desc = "Diff review" },
      { "<Leader>ay", mode = "x", desc = "Add selection" },
      { "<Leader>aY", mode = "x", desc = "Add inline selection" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "opencode_output" },
      },
      {
        "folke/snacks.nvim",
        optional = true,
      },
      {
        "saghen/blink.cmp",
        optional = true,
      },
    },
    opts = {
      default_global_keymaps = false,
      keymap_prefix = "<Leader>a",
      preferred_picker = "snacks",
      preferred_completion = "blink",
      default_mode = "build",
      opencode_executable = "opencode2",
      keymap = {
        editor = {
          ["<M-o>"] = { "toggle", mode = { "n", "i" }, desc = "Toggle windows" },
          ["<Leader>a/"] = { "quick_chat", mode = { "n", "x" }, desc = "Quick chat" },
          ["<Leader>aa"] = { "select_session", desc = "Session picker" },
          ["<Leader>ad"] = { "diff_open", desc = "Diff review" },
          ["<Leader>ay"] = { "add_visual_selection", mode = "x", desc = "Add selection" },
          ["<Leader>aY"] = { "add_visual_selection_inline", mode = "x", desc = "Add inline selection" },
        },
        input_window = {
          ["<esc>"] = false,
          ["<C-s>"] = { "submit_input_prompt", mode = { "n", "i" }, desc = "Submit prompt" },
          ["<C-r>"] = { "rename_session", mode = { "n", "i" }, desc = "Rename session" },
          ["<M-h>"] = { "navigate_session_tree", { "parent" }, mode = { "n", "i" }, desc = "Parent session" },
          ["<M-j>"] = {
            "navigate_session_tree",
            { "sibling", "picker" },
            mode = { "n", "i" },
            desc = "Sibling sessions",
          },
          ["<M-l>"] = { "navigate_session_tree", { "child", "picker" }, mode = { "n", "i" }, desc = "Child sessions" },
          ["<M-,>"] = { "prev_session_tab", mode = { "n", "i" }, desc = "Prev session tab" },
          ["<M-.>"] = { "next_session_tab", mode = { "n", "i" }, desc = "Next session tab" },
          ["<M-1>"] = { "select_session_tab", { 1 }, mode = { "n", "i" }, desc = "Session tab 1" },
          ["<M-2>"] = { "select_session_tab", { 2 }, mode = { "n", "i" }, desc = "Session tab 2" },
          ["<M-3>"] = { "select_session_tab", { 3 }, mode = { "n", "i" }, desc = "Session tab 3" },
          ["<M-4>"] = { "select_session_tab", { 4 }, mode = { "n", "i" }, desc = "Session tab 4" },
          ["<M-c>"] = { "open_session_tab", mode = { "n", "i" }, desc = "New session tab" },
          ["<M-x>"] = { "close_session_tab", mode = { "n", "i" }, desc = "Close session tab" },
          ["<C-a>"] = { "select_session", mode = { "n", "i" }, desc = "Sessions" },
          ["<C-o>"] = { "mcp", mode = { "n", "i" }, desc = "MCP picker" },
          ["<M-s>"] = { "skills", mode = { "n", "i" }, desc = "Skills picker" },
          ["<C-z>"] = { "toggle_zoom", mode = { "n", "i" }, desc = "Toggle window zoom" },
          ["<C-x>"] = { "configure_provider", mode = { "n", "i" }, desc = "Provider/model" },
          ["<C-e>"] = { "configure_variant", mode = { "n", "i" }, desc = "Variant picker" },
          ["<C-t>"] = { "timeline", mode = { "n", "i" }, desc = "Timeline" },
          ["<C-c>"] = { "cancel", mode = { "n", "i" }, desc = "Cancel" },
          ["<C-n>"] = { "open_input_new_session", mode = "n", desc = "New session input" },
          ["~"] = { "mention_file", mode = "i", desc = "Mention file" },
          ["@"] = { "mention", mode = "i", desc = "Mention" },
          ["/"] = { "slash_commands", mode = "i", desc = "Slash commands" },
          ["#"] = { "context_items", mode = "i", desc = "Context items" },
          ["<M-v>"] = { "paste_image", mode = { "n", "i" }, desc = "Paste image" },
          ["<Tab>"] = { "toggle_pane", mode = "n", desc = "Toggle pane" },
          ["<Up>"] = { "prev_prompt_history", mode = { "n", "i" }, desc = "Prev history" },
          ["<Down>"] = { "next_prompt_history", mode = { "n", "i" }, desc = "Next history" },
          ["<M-m>"] = { "switch_mode", desc = "Switch mode" },
          ["<M-t>"] = { "toggle_tool_output", mode = { "n", "i" }, desc = "Toggle tool output" },
          ["<M-r>"] = { "toggle_reasoning_output", mode = { "n", "i" }, desc = "Toggle reasoning output" },
        },
        output_window = {
          ["<esc>"] = false,
          ["<C-r>"] = { "rename_session", mode = "n", desc = "Rename session" },
          ["<C-a>"] = { "select_session", mode = "n", desc = "Sessions" },
          ["<C-o>"] = { "mcp", mode = "n", desc = "MCP picker" },
          ["<M-h>"] = { "navigate_session_tree", { "parent" }, mode = "n", desc = "Parent session" },
          ["<M-j>"] = {
            "navigate_session_tree",
            { "sibling", "picker" },
            mode = "n",
            desc = "Sibling sessions",
          },
          ["<M-l>"] = { "navigate_session_tree", { "child", "picker" }, mode = "n", desc = "Child sessions" },
          ["<M-,>"] = { "prev_session_tab", mode = "n", desc = "Prev session tab" },
          ["<M-.>"] = { "next_session_tab", mode = "n", desc = "Next session tab" },
          ["<M-1>"] = { "select_session_tab", { 1 }, mode = "n", desc = "Session tab 1" },
          ["<M-2>"] = { "select_session_tab", { 2 }, mode = "n", desc = "Session tab 2" },
          ["<M-3>"] = { "select_session_tab", { 3 }, mode = "n", desc = "Session tab 3" },
          ["<M-4>"] = { "select_session_tab", { 4 }, mode = "n", desc = "Session tab 4" },
          ["<M-c>"] = { "open_session_tab", mode = "n", desc = "New session tab" },
          ["<M-x>"] = { "close_session_tab", mode = "n", desc = "Close session tab" },
          ["<C-z>"] = { "toggle_zoom", mode = "n", desc = "Toggle window zoom" },
          ["<C-x>"] = { "configure_provider", mode = "n", desc = "Provider/model" },
          ["<C-e>"] = { "configure_variant", mode = "n", desc = "Variant picker" },
          ["<C-t>"] = { "timeline", mode = "n", desc = "Timeline" },
          ["<C-c>"] = { "cancel", desc = "Cancel" },
          ["<C-n>"] = { "next_message", desc = "Next message" },
          ["<C-p>"] = { "prev_message", desc = "Prev message" },
          ["<Tab>"] = { "toggle_pane", mode = { "n", "i" }, desc = "Toggle pane" },
          ["i"] = { "focus_input", mode = { "n" }, desc = "Focus input" },
          ["gr"] = { "references", mode = { "n" }, desc = "References" },
          ["a"] = { "permission", { "accept" }, mode = { "n" }, desc = "Accept once" },
          ["A"] = { "permission", { "accept_all" }, mode = { "n" }, desc = "Accept all" },
          ["d"] = { "permission", { "deny" }, mode = { "n" }, desc = "Deny" },
          ["<M-t>"] = { "toggle_tool_output", mode = { "n" }, desc = "Toggle tool output" },
          ["<M-r>"] = { "toggle_reasoning_output", mode = { "n" }, desc = "Toggle reasoning output" },
          ["<M-n>"] = { "next_user_message", mode = "n", desc = "Next user message" },
          ["<M-p>"] = { "prev_user_message", mode = "n", desc = "Prev user message" },
        },
        session_diff = {
          -- <M-q>: close the whole diff view from any scope (`q` in floats only closes the float).
          list = {
            ["<M-q>"] = { "close", desc = "Close diff view" },
          },
          preview = {
            ["<M-q>"] = { "close", desc = "Close diff view" },
          },
          messages = {
            ["<M-q>"] = { "close", desc = "Close diff view" },
          },
          help = {
            ["<M-q>"] = { "close", desc = "Close diff view" },
          },
        },
        session_picker = {
          rename_session = { "<C-r>" },
          delete_session = { "<C-d>" },
          new_session = { "<C-s>" },
        },
        timeline_picker = {
          undo = { "<C-u>", mode = { "i", "n" } },
          fork = { "<C-f>", mode = { "i", "n" } },
        },
        history_picker = {
          delete_entry = { "<C-d>", mode = { "i", "n" } },
          clear_all = { "<C-x>", mode = { "i", "n" } },
        },
        model_picker = {
          toggle_favorite = { "<C-f>", mode = { "i", "n" } },
        },
        mcp_picker = {
          toggle_connection = { "<C-t>", mode = { "i", "n" } },
        },
      },
      ui = {
        enable_treesitter_markdown = true,
        position = "right",
        input_position = "bottom",
        window_width = 0.42,
        zoom_width = 0.80,
        display_model = true,
        display_context_size = true,
        display_cost = true,
        persist_state = true,
        icons = {
          preset = "text",
        },
        output = {
          filetype = "opencode_output",
          tools = {
            show_output = true,
            show_reasoning_output = true,
          },
          rendering = {
            markdown_debounce_ms = 150,
          },
        },
        input = {
          min_height = 0.10,
          max_height = 0.25,
          auto_hide = false,
          text = {
            wrap = false,
          },
        },
        picker = {
          snacks_layout = {
            preset = "select",
          },
        },
        completion = {
          file_sources = {
            enabled = true,
            preferred_cli_tool = "server",
            max_files = 10,
            max_display_length = 50,
          },
        },
      },
      context = {
        enabled = true,
        current_file = {
          enabled = false,
          show_full_path = true,
        },
        files = {
          enabled = true,
          show_full_path = true,
        },
        selection = {
          enabled = true,
        },
        diagnostics = {
          enabled = false,
          info = false,
          warning = true,
          error = true,
          only_closest = false,
        },
        cursor_data = {
          enabled = false,
          context_lines = 5,
        },
        buffer = {
          enabled = false,
        },
        git_diff = {
          enabled = false,
        },
      },
      quick_chat = {
        default_model = nil,
        default_agent = nil,
        instructions = nil,
      },
      -- Terminal tab progress (term_progress above)
      hooks = {
        on_done_thinking = function(session) term_progress.on_done(session) end,
        on_permission_requested = function(session) term_progress.on_permission(session) end,
      },
      debug = {
        enabled = false,
        capture_streamed_events = false,
        show_ids = true,
        quick_chat = {
          keep_session = false,
          set_active_session = false,
        },
      },
      logging = {
        enabled = false,
        level = "warn",
      },
    },
    config = function(_, opts)
      require("opencode").setup(opts)

      -- Terminal tab progress (term_progress above): mark the session busy on
      -- submit.
      local v2_operations = require("opencode.protocols.v2.operations")
      local submit_with_progress = v2_operations.submit
      v2_operations.submit = function(connection, session_id, ...)
        term_progress.on_submit(session_id)
        return submit_with_progress(connection, session_id, ...)
      end

      -- Worktree picker on <M-w> inside opencode input/output windows (backend:
      -- lua/opencode_worktree.lua). Buffer-local via FileType so it doesn't clash
      -- with the global <M-w> Find Buffer mapping in lua/plugins/snacks.lua.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "opencode", "opencode_output" },
        callback = function(ev)
          vim.keymap.set({ "n", "i" }, "<M-w>", function() require("opencode_worktree").pick() end, {
            buffer = ev.buf,
            desc = "Worktrees",
          })
        end,
      })

      local ok, wk = pcall(require, "which-key")
      if ok then wk.add {
        { "<Leader>a", group = "Opencode" },
      } end
    end,
  },
}
