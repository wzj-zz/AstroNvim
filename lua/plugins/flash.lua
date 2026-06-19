return {
  {
    "folke/flash.nvim",

    event = "VeryLazy",
    vscode = true,

    dependencies = "nvim-telescope/telescope.nvim",

    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
      },
      label = {
        before = true,
        after = false,
        rainbow = {
          enabled = true,
          shade = 5,
        },
      },
    },

    keys = {
      {
        "S",
        mode = { "n", "o", "x" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
    },
  },
  {
    "wzj-zz/flash-zh.nvim",

    dependencies = { "folke/flash.nvim" },

    opts = {},
    config = function(_, opts) require("flash_zh").setup(opts) end,

    keys = {
      {
        "s",
        mode = { "n", "x" },
        function() require("flash_zh").jump() end,
        desc = "Flash Zh",
      },
      {
        "r",
        mode = "o",
        function() require("flash_zh").remote() end,
        desc = "Remote Flash Zh",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",

    optional = true,
    opts = function(_, opts)
      local function flash(prompt_bufnr)
        require("flash").jump {
          pattern = "^",
          label = {
            before = true,
            after = false,
          },
          search = {
            mode = "search",
            exclude = {
              function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        }
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          i = { ["<M-s>"] = flash },
        },
      })
    end,
  },
}
