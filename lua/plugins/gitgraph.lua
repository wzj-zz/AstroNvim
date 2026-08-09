vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitgraph",
  callback = function(event)
    vim.keymap.set("n", "<M-q>", function()
      local current = vim.api.nvim_get_current_buf()
      local previous = vim.fn.bufnr "#"

      if previous > 0 and previous ~= current and vim.api.nvim_buf_is_valid(previous) then
        vim.api.nvim_set_current_buf(previous)
      else
        vim.cmd "enew"
      end

      vim.api.nvim_buf_delete(current, { force = true })
    end, {
      buffer = event.buf,
      silent = true,
      desc = "Close GitGraph",
    })
  end,
})

return {
  "isakbm/gitgraph.nvim",
  lazy = true,
  opts = function(_, opts)
    if vim.env.KITTY_PID ~= nil then
      opts.symbols = {
        merge_commit = "",
        commit = "",
        merge_commit_end = "",
        commit_end = "",

        -- Advanced symbols
        GVER = "",
        GHOR = "",
        GCLD = "",
        GCRD = "╭",
        GCLU = "",
        GCRU = "",
        GLRU = "",
        GLRD = "",
        GLUD = "",
        GRUD = "",
        GFORKU = "",
        GFORKD = "",
        GRUDCD = "",
        GRUDCU = "",
        GLUDCD = "",
        GLUDCU = "",
        GLRDCL = "",
        GLRDCR = "",
        GLRUCL = "",
        GLRUCR = "",
      }
    end
  end,
  specs = {
    { -- mapping to open GitGraph
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>gG"] = {
              function() require("gitgraph").draw({}, { all = true, max_count = 5000 }) end,
              desc = "GitGraph",
            },
          },
        },
      },
    },
    { -- use diffview for viewing commits if available
      "sindrets/diffview.nvim",
      optional = true,
      specs = {
        {
          "isakbm/gitgraph.nvim",
          opts = {
            hooks = {
              on_select_commit = function(commit) vim.cmd.DiffviewOpen(commit.hash .. "^!") end,
              on_select_range_commit = function(from, to) vim.cmd.DiffviewOpen(from.hash .. "~1.." .. to.hash) end,
            },
          },
        },
      },
    },
  },
}
