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
      require("xmark").setup()
    end,
    specs = {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>m"] = { name = "Xmark" },
          },
        },
      },
    },
  },
}
