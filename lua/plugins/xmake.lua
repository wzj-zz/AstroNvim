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
          ["<Leader>xb"] = { "<cmd>Xmake build<cr>", desc = "Xmake build" },
          ["<Leader>xr"] = { "<cmd>Xmake run<cr>", desc = "Xmake run" },
          ["<Leader>xd"] = { "<cmd>Xmake debug<cr>", desc = "Xmake debug" },
          ["<Leader>xc"] = { "<cmd>Xmake clean<cr>", desc = "Xmake clean" },
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
