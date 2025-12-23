return {
  "chentoast/marks.nvim",
  opts = {
    cyclic = false,
  },
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>f'"] = {
            function()
              require "marks"
              vim.cmd "MarksQFListAll"
            end,
            desc = "List Marks in QFList",
          },
        },
      },
    },
  },
}
