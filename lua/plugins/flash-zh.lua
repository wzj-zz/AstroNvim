return {
  {
    "wzj-zz/flash-zh.nvim",
    dependencies = { "folke/flash.nvim" },
    opts = {},
    config = function(_, opts) require("flash_zh").setup(opts) end,
    keys = {
      {
        "gh",
        mode = { "n", "x" },
        function() require("flash_zh").jump() end,
        desc = "Flash Pinyin Jump",
      },
    },
  },
}
