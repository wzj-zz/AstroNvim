local function restart_opencode_server()
  local ok_state, state = pcall(require, "opencode.state")
  local ok_server_job, server_job = pcall(require, "opencode.server_job")

  if not ok_state or not ok_server_job then
    vim.notify("opencode.nvim internals unavailable", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(function()
    if state.opencode_server and type(state.opencode_server.shutdown) == "function" then
      state.opencode_server:shutdown():wait(3000)
    end

    state.jobs.clear_server()
    state.jobs.set_server(server_job.ensure_server():wait(5000))
  end)

  if not ok then
    vim.notify("Failed to restart opencode server: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.notify("Restarted opencode server", vim.log.levels.INFO)
end

return {
  {
    "sudo-tee/opencode.nvim",
    cmd = { "Opencode" },
    keys = {
      {
        "<M-o>",
        function() require("opencode.api").toggle() end,
        mode = { "n", "i" },
        desc = "Toggle",
      },
      { "<Leader>ag", function() require("opencode.api").toggle() end, desc = "Toggle" },
      { "<Leader>ai", function() require("opencode.api").open_input() end, desc = "Input" },
      { "<Leader>ao", function() require("opencode.api").open_output() end, desc = "Output" },
      { "<Leader>am", function() require("opencode.api").mcp() end, desc = "MCP" },
      { "<Leader>ax", restart_opencode_server, desc = "Restart server" },
      { "<Leader>ad", function() require("opencode.api").diff_open() end, desc = "Diff" },
      {
        "<Leader>a/",
        function() require("opencode.api").quick_chat() end,
        mode = { "n", "x" },
        desc = "Quick chat",
      },
      {
        "<Leader>ay",
        function() require("opencode.api").add_visual_selection() end,
        mode = "x",
        desc = "Add selection",
      },
      {
        "<Leader>aY",
        function() require("opencode.api").add_visual_selection_inline() end,
        mode = "x",
        desc = "Add selection inline",
      },
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
      opencode_executable = "opencode",
      keymap = {
        editor = {},
        input_window = {
          ["<C-s>"] = { "submit_input_prompt", mode = { "n", "i" }, desc = "Submit prompt" },
          ["<C-k>"] = { "select_child_session", mode = "n", desc = "Child sessions" },
          ["<C-l>"] = { "select_session", mode = "n", desc = "Sessions" },
          ["<C-p>"] = { "configure_provider", mode = "n", desc = "Provider/model" },
          ["<C-t>"] = { "timeline", mode = "n", desc = "Timeline" },
          ["<Esc>"] = { "close", desc = "Close" },
          ["<C-c>"] = { "cancel", desc = "Cancel" },
          ["~"] = { "mention_file", mode = "i", desc = "Mention file" },
          ["@"] = { "mention", mode = "i", desc = "Mention" },
          ["/"] = { "slash_commands", mode = "i", desc = "Slash commands" },
          ["#"] = { "context_items", mode = "i", desc = "Context items" },
          ["<M-v>"] = { "paste_image", mode = { "n", "i" }, desc = "Paste image" },
          ["<Tab>"] = { "toggle_pane", mode = "n", desc = "Toggle pane" },
          ["<Up>"] = { "prev_prompt_history", mode = { "n", "i" }, desc = "Prev history" },
          ["<Down>"] = { "next_prompt_history", mode = { "n", "i" }, desc = "Next history" },
          ["<M-m>"] = { "switch_mode", desc = "Switch mode" },
          ["<M-r>"] = { "cycle_variant", mode = { "n", "i" }, desc = "Cycle variant" },
        },
        output_window = {
          ["<C-k>"] = { "select_child_session", mode = "n", desc = "Child sessions" },
          ["<C-l>"] = { "select_session", mode = "n", desc = "Sessions" },
          ["<C-p>"] = { "configure_provider", mode = "n", desc = "Provider/model" },
          ["<C-t>"] = { "timeline", mode = "n", desc = "Timeline" },
          ["<Esc>"] = { "close", desc = "Close" },
          ["<C-c>"] = { "cancel", desc = "Cancel" },
          ["]]"] = { "next_message", desc = "Next message" },
          ["[["] = { "prev_message", desc = "Prev message" },
          ["<Tab>"] = { "toggle_pane", mode = { "n", "i" }, desc = "Toggle pane" },
          ["i"] = { "focus_input", mode = { "n" }, desc = "Focus input" },
          ["gr"] = { "references", mode = { "n" }, desc = "References" },
          ["a"] = { "permission_accept", mode = { "n" }, desc = "Accept once" },
          ["A"] = { "permission_accept_all", mode = { "n" }, desc = "Accept all" },
          ["d"] = { "permission_deny", mode = { "n" }, desc = "Deny" },
          ["<M-r>"] = { "cycle_variant", mode = { "n" }, desc = "Cycle variant" },
          ["<Leader>adm"] = { "debug_message", desc = "Debug message" },
          ["<Leader>ado"] = { "debug_output", desc = "Debug output" },
          ["<Leader>ads"] = { "debug_session", desc = "Debug session" },
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
          enabled = true,
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
          enabled = true,
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

      local ok, wk = pcall(require, "which-key")
      if ok then wk.add {
        { "<Leader>a", group = "Opencode" },
      } end
    end,
  },
}
