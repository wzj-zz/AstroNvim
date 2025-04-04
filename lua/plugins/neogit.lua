return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "AstroNvim/astroui", opts = { icons = { Neogit = "󰰔" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>g"] = { desc = require("astroui").get_icon("Neogit", 1, true) .. "Neogit" }
        maps.n["<Leader>gg"] = { "<Cmd>Neogit<CR>", desc = "Open Neogit Tab Page" }
        maps.n["<Leader>ge"] = { ":Neogit cwd=", desc = "Open Neogit Override CWD" }
        maps.n["<Leader>gf"] = {
          function() require("neogit").open { cwd = vim.fn.stdpath "config" .. "/" } end,
          desc = "Open Neogit In AstroNvim config",
        }
        maps.n["<Leader>gx"] = {
          function()
            local xtools_path
            if vim.fn.has "win64" == 1 then
              xtools_path = "D:\\tools"
              require("neogit").open { cwd = xtools_path }
            end
          end,
          desc = "Open Neogit In xtools (only win64)",
        }
      end,
    },
  },
  specs = {
    {
      "catppuccin",
      optional = true,
      ---@type CatppuccinOptions
      opts = { integrations = { neogit = true } },
    },
  },
  event = "User AstroGitFile",
  opts = function(_, opts)
    local utils = require "astrocore"
    local disable_builtin_notifications = utils.is_available "nvim-notify" or utils.is_available "noice.nvim"

    return utils.extend_tbl(opts, {
      disable_builtin_notifications = disable_builtin_notifications,
      disable_signs = true,
      telescope_sorter = function()
        if utils.is_available "telescope-fzf-native.nvim" then
          return require("telescope").extensions.fzf.native_fzf_sorter()
        end
      end,
      integrations = { telescope = utils.is_available "telescope.nvim" },
    })
  end,
}
