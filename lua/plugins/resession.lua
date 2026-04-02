if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return {
  "stevearc/resession.nvim",
  config = function()
    local resession = require "resession"
    resession.setup()
    resession.add_hook("post_load", function() vim.cmd "silent! bufdo e" end)
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>,>"] = { function() require("resession").save_tab() end, desc = "Save this tab's session" },
            ["<Leader>,."] = { function() require("resession").load() end, desc = "Load a session" },
            ["<Leader>,/"] = {
              function()
                print('Detached session "' .. require("resession").get_current() .. '"')
                require("resession").detach()
              end,
              desc = "Detach current session",
            },
            ["<Leader>,?"] = { function() require("resession").delete() end, desc = "Delete a session" },
          },
        },
      },
    },
  },
}
