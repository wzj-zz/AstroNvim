return {
  "andymass/vim-matchup",
  lazy = true,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        options = {
          g = {
            matchup_matchparen_nomode = "i",
            matchup_matchparen_deferred = 1,
          },
        },
        mappings = {
          n = {
            ["<M-e>"] = { "<cmd>normal z%<cr>", desc = "Next matchup inside" },
            ["<M-u>"] = { function() vim.cmd("normal " .. vim.v.count1 .. "[%") end, desc = "Goto matchup outside" },
            ["<M-a>"] = { "<cmd>normal %<cr>", desc = "Next matchup" },
          },
          v = {
            ["<M-a>"] = { "<cmd>normal %<cr>", desc = "Next matchup" },
          },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = { "andymass/vim-matchup" },
      opts = { matchup = { enable = true } },
    },
  },
}
