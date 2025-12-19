-- if true then return {} end

return {
  {
    "igorlfs/nvim-dap-view",
    lazy = true,
    opts = {
      winbar = {
        sections = {
          "watches",
          "scopes",
          "exceptions",
          "breakpoints",
          "threads",
          "repl",
          "disassembly",
        },
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>d"] = vim.tbl_get(opts, "_map_sections", "d")
          maps.n["<Leader>de"] = { function() require("dap-view").add_expr() end, desc = "Add expression" }
          maps.n["<Leader>dE"] = { function() require("dap-view").add_expr() end, desc = "Add expression" }
          maps.n["<Leader>du"] = { function() require("dap-view").toggle() end, desc = "Toggle Debugger UI" }
        end,
      },
      { "rcarriga/nvim-dap-ui", enabled = false },
    },
  },
  {
    "Jorenar/nvim-dap-disasm",
    dependencies = "igorlfs/nvim-dap-view",
    config = true,
  },
}
