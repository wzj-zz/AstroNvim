if not vim.g.vscode then return {} end -- don't do anything in non-vscode instances

-- Set `vim.notify` to VS Code notifications
vim.notify = require("vscode").notify

local enabled = {}
vim.tbl_map(function(plugin) enabled[plugin] = true end, {
  -- core plugins
  "lazy.nvim",
  "AstroNvim",
  "astrocore",
  "astroui",
  "Comment.nvim",
  "nvim-autopairs",
  "nvim-treesitter",
  "nvim-ts-autotag",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  -- more known working
  "dial.nvim",
  "flash.nvim",
  "flit.nvim",
  "leap.nvim",
  "mini.ai",
  "mini.comment",
  "mini.move",
  "mini.pairs",
  "mini.surround",
  "nvim-surround",
  "ts-comments.nvim",
  "vim-easy-align",
  "vim-repeat",
  "vim-sandwich",
  "yanky.nvim",
  -- feel free to open PRs to add more support!
  "multicursor.nvim",
  "treewalker.nvim",
  "treesj",
  "tshjkl.nvim",
  "wildfire.nvim",
  "arshlib.nvim",
  "indent-tools.nvim",
  "vim-matchup",
  "vim-highlighter",
  "marks.nvim",
  "nvim-hlslens",
})

local Config = require "lazy.core.config"
-- disable plugin update checking
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
-- replace the default `cond`
Config.options.defaults.cond = function(plugin) return enabled[plugin.name] end

---@type LazySpec
return {
  -- add a few keybindings
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local opt = vim.tbl_get(opts, "options", "opt")
      if opt then opt.cmdheight = nil end

      local maps = assert(opts.mappings)

      -- basic actions
      maps.n["<Leader>n"] = function() require("vscode").action "welcome.showNewFileEntries" end

      -- buffer management
      maps.n["<Leader>c"] = "<cmd>Tabclose<cr>"
      maps.n["<Leader>C"] = "<cmd>Tabclose!<cr>"
      maps.n["<Leader>bx"] = "<cmd>Tabonly<cr>"
      maps.n["<Leader>bv"] = function() require("vscode").action "workbench.action.files.revert" end

      -- file explorer
      maps.n["<Leader>e"] = function() require("vscode").action "workbench.files.action.focusFilesExplorer" end

      -- indentation
      maps.v["<Tab>"] = function() require("vscode").action "editor.action.indentLines" end
      maps.v["<S-Tab>"] = function() require("vscode").action "editor.action.outdentLines" end

      -- diagnostics
      maps.n["]d"] = function() require("vscode").action "editor.action.marker.next" end
      maps.n["[d"] = function() require("vscode").action "editor.action.marker.prev" end

      -- pickers (emulate telescope mappings)
      maps.n["<Leader>fa"] = function() require("vscode").action "workbench.action.openSettings" end
      maps.n["<Leader>ff"] = function() require("vscode").action "workbench.action.quickOpen" end
      maps.n["<Leader>fo"] = function() require("vscode").action "workbench.action.openRecent" end

      maps.n["<Leader>sw"] = function()
        require("vscode").action("workbench.action.findInFiles", { args = { query = vim.fn.expand "<cword>" } })
      end
      maps.n["<Leader>sc"] = function() require("vscode").action "workbench.action.showCommands" end
      maps.n["<Leader>sk"] = function() require("vscode").action "workbench.action.openGlobalKeybindings" end
      maps.n["<Leader>sd"] = function() require("vscode").action "workbench.actions.view.problems" end
      maps.n["<Leader>sn"] = function() require("vscode").action "notifications.showList" end
      maps.n["<Leader>sg"] = function() require("vscode").action "workbench.action.findInFiles" end
      maps.n["<Leader>sb"] = function() require("vscode").action "actions.find" end

      -- git client
      maps.n["<Leader>gg"] = function() require("vscode").action "workbench.view.scm" end

      -- LSP Mappings
      maps.n["K"] = function() require("vscode").action "editor.action.showHover" end
      maps.n["gd"] = function() require("vscode").action "editor.action.revealDefinition" end
      maps.n["gD"] = function() require("vscode").action "editor.action.revealDeclaration" end
      maps.n["gy"] = function() require("vscode").action "editor.action.goToTypeDefinition" end
      maps.n["grr"] = function() require("vscode").action "editor.action.goToReferences" end
      maps.n["gri"] = function() require("vscode").action "editor.action.goToImplementation" end

      maps.n["<M-d>"] = function() require("vscode").action "editor.action.revealDefinition" end
      maps.n["<M-r>"] = function() require("vscode").action "references-view.findReferences" end
      maps.n["<M-y>"] = function() require("vscode").action "editor.action.goToTypeDefinition" end
      maps.n["<M-i>"] = function() require("vscode").action "references-view.findImplementations" end

      maps.n["<Leader>vs"] = function() require("vscode").action "workbench.action.showAllSymbols" end
      maps.n["<Leader>vb"] = function() require("vscode").action "references-view.showCallHierarchy" end
      maps.n["<Leader>vt"] = function() require("vscode").action "references-view.showTypeHierarchy" end

      maps.n["<Leader>la"] = function() require("vscode").action "editor.action.quickFix" end
      maps.n["<Leader>lG"] = function() require("vscode").action "workbench.action.showAllSymbols" end
      maps.n["<Leader>lR"] = function() require("vscode").action "editor.action.goToReferences" end
      maps.n["<Leader>lr"] = function() require("vscode").action "editor.action.rename" end
      maps.n["<Leader>ls"] = function() require("vscode").action "workbench.action.gotoSymbol" end
      maps.n["<Leader>lf"] = function() require("vscode").action "editor.action.formatDocument" end

      -- Local Mappings
      maps.n["<Leader>,a"] = function() vim.cmd "normal! ggVG" end
      maps.n["<Leader>,1"] = '<cmd>let @+ = expand("%:p:h")<cr><cmd>echo expand("%:p:h")<cr>'
      maps.n["<Leader>,2"] = '<cmd>let @+ = expand("%:t")<cr><cmd>echo expand("%:t")<cr>'
      maps.n["<Leader>,3"] = function() require("vscode").action "copyFilePath" end
      maps.n["<Leader>,s"] = function() require("vscode").action "workbench.action.terminal.toggleTerminal" end

      -- vscode-harpoon Mappings
      maps.n["<M-m>"] = function() require("vscode").action "vscode-harpoon.editEditors" end
      maps.n["<M-M>"] = function() require("vscode").action "vscode-harpoon.addEditor" end
      maps.n["<Leader>1"] = function() require("vscode").action "vscode-harpoon.gotoEditor1" end
      maps.n["<Leader>2"] = function() require("vscode").action "vscode-harpoon.gotoEditor2" end
      maps.n["<Leader>3"] = function() require("vscode").action "vscode-harpoon.gotoEditor3" end
      maps.n["<Leader>4"] = function() require("vscode").action "vscode-harpoon.gotoEditor4" end

      -- CodeQL Mappings
      maps.n["<Leader>qh"] = function() require("vscode").action "codeQLQueryHistory.focus" end
      maps.n["<Leader>qq"] = function() require("vscode").action "codeQLQueries.focus" end
      maps.n["<Leader>qr"] = function() require("vscode").action "codeQL.runQuery" end
      maps.n["<Leader>qe"] = function() require("vscode").action "codeQL.quickEval" end
      maps.n["<Leader>qo"] = function() require("vscode").action "codeQL.chooseDatabaseFolder" end
      maps.n["<Leader>qO"] = function() require("vscode").action "codeQL.chooseDatabaseArchive" end
    end,
  },
  -- disable treesitter highlighting
  { "nvim-treesitter/nvim-treesitter", opts = { highlight = { enable = false } } },

  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        v = {
          ["<C-S-Left>"] = { "b", desc = "" },
          ["<C-S-Right>"] = { "e", desc = "" },
          ["<S-Up>"] = { "k", desc = "" },
          ["<S-Down>"] = { "j", desc = "" },
          ["<S-Left>"] = { "h", desc = "" },
          ["<S-Right>"] = { "l", desc = "" },
          ["<S-PageUp>"] = { "<C-u>", desc = "" },
          ["<S-PageDown>"] = { "<C-d>", desc = "" },
        },
      },
    },
  },
}
