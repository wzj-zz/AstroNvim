return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install && git restore .",
  ft = "markdown",
  specs = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<C-M-m>"] = { "<cmd>MarkdownPreview<cr>", desc = "MarkdownPreview" },
        },
      },
    },
  },
}
