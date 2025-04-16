if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return {
  "Mythos-404/xmake.nvim",
  version = "^3",
  cmd = { "Xmake" },
  lazy = true,
  event = "BufReadPost",
  config = true,
  specs = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>xb"] = { "<cmd>Xmake build<cr>", desc = "Xmake quick build" },
          ["<Leader>xr"] = { "<cmd>Xmake run<cr>", desc = "Xmake quick run" },
          ["<Leader>xd"] = { "<cmd>Xmake debug<cr>", desc = "Xmake quick debug" },
          ["<Leader>xc"] = { "<cmd>Xmake clean<cr>", desc = "Xmake quick clean" },
          ["<Leader>xB"] = { ":Xmake build ", desc = "Xmake build" },
          ["<Leader>xR"] = { ":Xmake run ", desc = "Xmake run" },
          ["<Leader>xD"] = { ":Xmake debug ", desc = "Xmake debug" },

          ["<Leader>xm"] = { ":Xmake mode ", desc = "Xmake mode" },
          ["<Leader>xp"] = { ":Xmake plat ", desc = "Xmake plat" },
          ["<Leader>xt"] = { ":Xmake toolchain ", desc = "Xmake toolchain" },
        },
      },
    },
  },
}
