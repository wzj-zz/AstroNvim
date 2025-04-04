if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "User AstroFile",
  opts = {
    enable = false,
    multiwindow = true,
  },
  cmd = { "TSContextToggle" },
  dependencies = {
    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        mappings = {
          n = {
            ["<Leader>vu"] = {
              function() require("treesitter-context").go_to_context(vim.v.count1) end,
              desc = "Goto context",
            },
            ["<Leader>ux"] = {
              "<cmd>TSContext toggle<CR>",
              desc = "Toggle treesitter-context",
            },
          },
        },
      },
    },
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        highlights = {
          init = function()
            return {
              TreesitterContextBottom = {
                underline = true,
                sp = "Grey",
              },
            }
          end,
        },
      },
    },
  },
}
