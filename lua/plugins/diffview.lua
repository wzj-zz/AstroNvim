return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile",
  cmd = { "DiffviewOpen" },
  opts = {
    keymaps = {
      view = {
        {
          "n",
          "<M-p>",
          function()
            vim.cmd "norm! [c"
            vim.cmd "norm! zz"
          end,
          { desc = "Previous diff" },
        },
        {
          "n",
          "<M-n>",
          function()
            vim.cmd "norm! ]c"
            vim.cmd "norm! zz"
          end,
          { desc = "Next diff" },
        },
        { "n", "<M-q>", function() vim.cmd "DiffviewClose" end, { desc = "Diffview close" } },
      },
      file_panel = {
        {
          "n",
          "<M-p>",
          function()
            require("diffview.actions").view_windo(function(_, sym)
              if sym == "b" then
                vim.cmd "norm! [c"
                vim.cmd "norm! zz"
              end
            end)()
          end,
        },
        {
          "n",
          "<M-n>",
          function()
            require("diffview.actions").view_windo(function(_, sym)
              if sym == "b" then
                vim.cmd "norm! ]c"
                vim.cmd "norm! zz"
              end
            end)()
          end,
        },
        { "n", "<M-q>", function() vim.cmd "DiffviewClose" end, { desc = "Diffview close" } },
      },
    },
    enhanced_diff_hl = true,
    view = {
      default = { winbar_info = true },
      file_history = { winbar_info = true },
    },
    hooks = { diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = false end },
  },
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      opts = { integrations = { diffview = true } },
    },
  },
}
