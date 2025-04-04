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
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<M-9>"] = {
              function()
                vim.cmd "cprevious"
                vim.cmd "norm! zz"
              end,
              desc = "Previous quickfix item",
            },
            ["<M-0>"] = {
              function()
                vim.cmd "cnext"
                vim.cmd "norm! zz"
              end,
              desc = "Next quickfix item",
            },
            ["<M-(>"] = {
              function()
                vim.cmd "cfirst"
                vim.cmd "norm! zz"
              end,
              desc = "First quickfix item",
            },
            ["<M-)>"] = {
              function()
                vim.cmd "clast"
                vim.cmd "norm! zz"
              end,
              desc = "Last quickfix item",
            },
            ["<M-8>"] = {
              function()
                vim.cmd "cc"
                vim.cmd "norm! zz"
              end,
              desc = "Current quickfix item",
            },
          },
        },
      },
    },
  },
}
