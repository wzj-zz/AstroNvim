if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return {
  "burgr033/mf-runner.nvim",
  cmd = { "MFROpen", "MFRRun", "MFREdit" },
  dependencies = {
    { "folke/snacks.nvim" },
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>xf"] = { "<Cmd>MFROpen<CR>", desc = "mf-runner: open" },
            ["<Leader>xx"] = { "<Cmd>MFREdit<CR>", desc = "mf-runner: edit Makefile" },
          },
        },
      },
    },
  },
  opts = {},
}
