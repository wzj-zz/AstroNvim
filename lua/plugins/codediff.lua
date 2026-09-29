if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

local function set_codediff_aliases()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.bo[buf].filetype

    if filetype == "codediff-explorer" or filetype == "codediff-history" then
      vim.keymap.set("n", "o", "<CR>", { buffer = buf, remap = true, desc = "Open selected entry" })
      vim.keymap.set("n", "l", "<CR>", { buffer = buf, remap = true, desc = "Open selected entry" })
      vim.keymap.set("n", "<M-e>", function() vim.api.nvim_command "2wincmd l" end, {
        buffer = buf,
        desc = "Goto current file",
        silent = true,
      })
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffOpen",
  callback = function() vim.schedule(set_codediff_aliases) end,
})

return {
  "esmuellert/codediff.nvim",
  event = "User AstroGitFile",
  cmd = { "CodeDiff" },
  opts = {
    diff = {
      layout = "side-by-side",
      disable_inlay_hints = true,
      cycle_next_hunk = false,
      cycle_next_file = false,
      jump_to_first_change = true,
    },
    explorer = {
      position = "left",
      width = 40,
      view_mode = "list",
      flatten_dirs = true,
      focus_on_select = false,
      initial_focus = "explorer",
      visible_groups = {
        staged = true,
        unstaged = true,
        conflicts = true,
      },
    },
    history = {
      position = "bottom",
      height = 15,
      initial_focus = "history",
      view_mode = "list",
    },
    keymaps = {
      view = {
        quit = "<M-q>",
        toggle_explorer = "<Leader>b",
        focus_explorer = "<Leader>e",
        next_hunk = "<M-n>",
        prev_hunk = "<M-p>",
        next_file = "<tab>",
        prev_file = "<s-tab>",
        open_in_prev_tab = "gf",
        show_help = "g?",
        toggle_layout = "g<C-x>",
      },
      explorer = {
        select = "<CR>",
        refresh = "R",
        toggle_view_mode = "i",
        stage_all = "S",
        unstage_all = "U",
        restore = "X",
        fold_open = "zo",
        fold_open_recursive = "zO",
        fold_close = "zc",
        fold_close_recursive = "zC",
        fold_toggle = "za",
        fold_toggle_recursive = "zA",
        fold_open_all = "zR",
        fold_close_all = "zM",
      },
      history = {
        select = "<CR>",
        refresh = "R",
        toggle_view_mode = "i",
        fold_open = "zo",
        fold_open_recursive = "zO",
        fold_close = "zc",
        fold_close_recursive = "zC",
        fold_toggle = "za",
        fold_toggle_recursive = "zA",
        fold_open_all = "zR",
        fold_close_all = "zM",
      },
      conflict = {
        accept_current = ",o",
        accept_incoming = ",t",
        accept_both = ",a",
        discard = "dx",
        accept_all_current = ",O",
        accept_all_incoming = ",T",
        accept_all_both = ",A",
        discard_all = "dX",
        next_conflict = "<S-M-n>",
        prev_conflict = "<S-M-p>",
        diffget_incoming = "2do",
        diffget_current = "3do",
      },
    },
  },
  config = function(_, opts)
    require("codediff").setup(opts)

    -- hunk 位置指示：codediff 在 <M-n>/<M-p> 时 echo "Hunk x of y"，但 noice 对瞬时
    -- echo 只能弹窗（会堆叠）。这里直接监听该消息，画成右侧虚拟文本（原地替换、自动消失）。
    -- noice.lua 中已 skip 这三条消息，避免重复显示。
    local ns = vim.api.nvim_create_namespace "codediff_hunk_pos"
    local state = { buf = nil, timer = vim.uv.new_timer() }

    local function clear()
      state.timer:stop()
      if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        pcall(vim.api.nvim_buf_del_extmark, state.buf, ns, 1)
      end
      state.buf = nil
    end

    vim.ui_attach(ns, { ext_messages = true }, function(event, _, content)
      if event ~= "msg_show" then return end
      local chunks = {}
      for _, chunk in ipairs(content) do
        chunks[#chunks + 1] = chunk[2]
      end
      local text = table.concat(chunks)
      local n, total = text:match "^Hunk (%d+) of (%d+)$"
      if not n then n, total = text:match "^%a+ hunk %((%d+) of (%d+)%)$" end
      if not n then return end
      vim.schedule(function()
        clear()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_extmark(buf, ns, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
          id = 1,
          virt_text = { { ("[%d/%d]"):format(n, total), "DiagnosticVirtualTextInfo" } },
          virt_text_pos = "right_align",
        })
        state.buf = buf
        state.timer:start(800, 0, vim.schedule_wrap(clear))
      end)
    end)

    -- workaround: NeogitOrg/neogit#2008（neogit 还在传旧的 session schema，上游修复后可删除）
    local ok_view, view = pcall(require, "codediff.ui.view")
    if ok_view and view.create then
      local original_create = view.create
      local path = require "codediff.core.path"
      view.create = function(session_config, filetype, on_ready)
        if session_config.mode == "explorer" and not session_config.panel then
          session_config.panel = {
            name = "explorer",
            data = session_config.explorer_data or {},
          }
          session_config.original = session_config.original or path.empty()
          session_config.modified = session_config.modified or path.empty()
        end
        return original_create(session_config, filetype, on_ready)
      end
    end

    local ok, welcome_window = pcall(require, "codediff.ui.view.welcome_window")
    if not ok or not welcome_window then return end

    if welcome_window.apply_normal then
      local orig_apply_normal = welcome_window.apply_normal
      welcome_window.apply_normal = function(winid) pcall(orig_apply_normal, winid) end
    end

    if welcome_window.apply then
      local orig_apply = welcome_window.apply
      welcome_window.apply = function(winid) pcall(orig_apply, winid) end
    end
  end,
}
