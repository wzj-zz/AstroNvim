if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.g.sqlite_clib_path = vim.fn.stdpath "config" .. "\\sqlite3.dll"
end

return {
  {
    "wzj-zz/xmark.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "folke/snacks.nvim",
    },
    config = function()
      require("xmark").setup {
        keymaps = {
          enabled = false,
        },
      }
    end,
    specs = {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>m"] = { name = "Xmark" },
            ["<Leader>mm"] = { "<cmd>XmarkAdd<cr>", desc = "Add or Update Item" },
            ["<Leader>mt"] = { "<cmd>XmarkToggle<cr>", desc = "Toggle Item" },
            ["<Leader>md"] = { "<cmd>XmarkDelete<cr>", desc = "Delete Item" },
            ["<Leader>mc"] = { "<cmd>XmarkDesc<cr>", desc = "Edit Desc" },
            ["<Leader>mp"] = { "<cmd>XmarkPrev<cr>", desc = "Previous Item" },
            ["<Leader>mn"] = { "<cmd>XmarkNext<cr>", desc = "Next Item" },
            ["<Leader>mP"] = { "<cmd>XmarkFirst<cr>", desc = "First Item" },
            ["<Leader>mN"] = { "<cmd>XmarkLast<cr>", desc = "Last Item" },
            ["<Leader>mf"] = { "<cmd>XmarkPick<cr>", desc = "Find Item" },
            ["<Leader>ml"] = { "<cmd>XmarkLists<cr>", desc = "Switch List" },
            ["<Leader>ma"] = { "<cmd>XmarkNewList<cr>", desc = "New List" },
            ["<Leader>mr"] = { "<cmd>XmarkRenameList<cr>", desc = "Rename List" },
            ["<Leader>me"] = { "<cmd>XmarkEditList<cr>", desc = "Edit List Order" },
            ["<M-{>"] = { "<cmd>XmarkPrev<cr>", desc = "Previous Xmark Item" },
            ["<M-}>"] = { "<cmd>XmarkNext<cr>", desc = "Next Xmark Item" },
          },
        },
      },
    },
  },
}
