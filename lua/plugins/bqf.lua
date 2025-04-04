return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  opts = {
    preview = {
      auto_preview = true,
    },
  },
  dependencies = {
    { "junegunn/fzf" },
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        if not opts.signs then opts.signs = {} end
        opts.signs.BqfSign = { text = " " .. require("astroui").get_icon "Selected", texthl = "BqfSign" }
      end,
    },
  },
}
