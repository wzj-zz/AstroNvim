-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local xtools = require "xtools"

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        wrapscan = false, -- sets vim.opt.wrapscan
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- Normal mode
      n = {
        ["<Leader>q"] = false,
        ["<M-q>"] = { "<cmd>close<cr>", desc = "Close window" },
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

        ["<M-e>"] = { "<cmd>normal z%<cr>", desc = "Next matchup inside" },
        ["<M-u>"] = { "<cmd>normal [%<cr>", desc = "Goto matchup outside" },
        ["<M-a>"] = { "<cmd>normal %<cr>", desc = "Next matchup" },

        ["<M-c>"] = { function() require("telescope.builtin").lsp_incoming_calls() end, desc = "Incoming Calls" },
        ["<S-M-c>"] = { function() require("telescope.builtin").lsp_outgoing_calls() end, desc = "Outgoing Calls" },
        ["<M-d>"] = { "<cmd>normal gd<cr>", desc = "goto definition" },
        ["<M-r>"] = { "<cmd>normal grr<cr>", desc = "goto references" },
        ["<M-y>"] = { "<cmd>normal gy<cr>", desc = "goto type definition" },
        ["<M-i>"] = { "<cmd>normal gri<cr>", desc = "goto implementation" },

        -- navigate buffer and tabs
        ["<S-M-i>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-M-u>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings under group name "Code"
        ["<Leader>a"] = { name = "Code" },
        ["<Leader>aa"] = { "<cmd>InspectTree<cr>", desc = "Show AST" },

        -- mappings under group name "Find"
        ["<Leader>fl"] = { function() require("telescope.builtin").filetypes() end, desc = "Select Language" },

        -- mappings under group name "Buffer"
        ["<Leader>bv"] = { "<cmd>e!<cr>", desc = "Revert Buffer" },
        ["<Leader>bx"] = {
          function()
            require("astrocore.buffer").close_all(true)
            vim.cmd "only"
          end,
          desc = "Close all buffers/windows except current",
        },

        -- mappings under group name "Local"
        ["<Leader>,"] = { name = "Local" },
        ["<Leader>,x"] = {
          function()
            xtools.set_clip(xtools.get_buf_content())
            xtools.new_term_cmd_float { cmd = "xt -c -d", display_name = "xtools_exec", close_on_exit = false }
          end,
          desc = "xtools exec",
        },
        ["<Leader>,v"] = {
          function()
            xtools.set_clip(xtools.get_buf_content())
            xtools.new_term_cmd_float {
              cmd = "xt -c -e stdout -d",
              display_name = "xtools_eval",
              close_on_exit = false,
            }
          end,
          desc = "xtools eval",
        },

        ["<Leader>,."] = {
          function()
            xtools.new_term_cmd_vertical {
              cmd = "xs",
              display_name = "xtools",
            }
          end,
          desc = "ToggleTerm xtools (python)",
        },
        ["<Leader>,s"] = {
          function()
            xtools.new_term_cmd_vertical {
              cmd = vim.o.shell,
              display_name = "shell",
            }
          end,
          desc = "ToggleTerm shell",
        },
        ["<Leader>,e"] = {
          function()
            vim.cmd "cd %:h"
            vim.cmd "Neotree focus"
            vim.cmd "pwd"
          end,
          desc = "Sync Neotree With Current Buffer",
        },
        ["<Leader>,1"] = {
          '<cmd>let @+ = expand("%:p:h")<cr><cmd>echo expand("%:p:h")<cr>',
          desc = "Yank directory path",
        },
        ["<Leader>,2"] = { '<cmd>let @+ = expand("%:t")<cr><cmd>echo expand("%:t")<cr>', desc = "Yank filename" },
        ["<Leader>,3"] = { '<cmd>let @+ = expand("%:p")<cr><cmd>echo expand("%:p")<cr>', desc = "Yank full path" },
        ["<Leader>,c"] = {
          function()
            local work_dir = xtools.cwd()
            xtools.set_clip(work_dir)
            print(work_dir)
          end,
          desc = "Yank CWD",
        },
        ["<Leader>,,"] = {
          function()
            xtools.adjust_path_from_clip()
            local path = xtools.get_clip()
            if xtools.isdir(path) then
              xtools.cd(path)
              print(xtools.cwd())
            elseif xtools.isfile(path) then
              vim.cmd("e " .. path)
            else
              print "Invalid Path !!!"
            end
          end,
          desc = "Set cwd or Open file with clipboard",
        },

        -- mappings under group name "Local/Hex"
        ["<Leader>,hh"] = { "<cmd>%!xxd -g 1<cr>", desc = "Switch to hex view" },
        ["<Leader>,hr"] = { "<cmd>%!xxd -r<cr>", desc = "Switch to binary view" },
        ["<Leader>,ho"] = { ":e ++binary ", desc = "Open binary file" },
        ["<Leader>,h"] = { name = "Hex" },
      },

      -- Visual mode
      v = {
        ["<Leader>,"] = { name = "Local" },
        ["<Leader>,x"] = {
          function()
            local line_begin = vim.fn.getpos("v")[2]
            local line_end = vim.fn.getcurpos()[2]
            local line_tmp
            if line_begin > line_end then
              line_tmp = line_begin
              line_begin = line_end
              line_end = line_tmp
            end
            xtools.set_clip(xtools.get_buf_content(line_begin, line_end))
            xtools.new_term_cmd_float { cmd = "xt -c -d", display_name = "xtools_exec", close_on_exit = false }
          end,
          desc = "xtools exec",
        },
        ["<Leader>,v"] = {
          function()
            local line_begin = vim.fn.getpos("v")[2]
            local line_end = vim.fn.getcurpos()[2]
            local line_tmp
            if line_begin > line_end then
              line_tmp = line_begin
              line_begin = line_end
              line_end = line_tmp
            end
            xtools.set_clip(xtools.get_buf_content(line_begin, line_end))
            xtools.new_term_cmd_float {
              cmd = "xt -c -e stdout -d",
              display_name = "xtools_eval",
              close_on_exit = false,
            }
          end,
          desc = "xtools eval",
        },

        ["<C-S-Left>"] = { "b", desc = "" },
        ["<C-S-Right>"] = { "e", desc = "" },
        ["<S-Up>"] = { "k", desc = "" },
        ["<S-Down>"] = { "j", desc = "" },
        ["<S-Left>"] = { "h", desc = "" },
        ["<S-Right>"] = { "l", desc = "" },
        ["<S-PageUp>"] = { "<C-u>", desc = "" },
        ["<S-PageDown>"] = { "<C-d>", desc = "" },
      },

      -- Command mode
      c = { ["<C-v>"] = { "<C-r>*", desc = "Paste in Command mode" } },

      -- Terminal mode
      t = {
        ["<C-l>"] = false,
        ["<M-q>"] = {
          "<cmd>close<cr>",
          desc = "Close buffer",
        },
      },

      -- Insert mode
      i = {
        ["<C-s>"] = { "<Esc>:w<cr>", desc = "Save" },
        ["<C-v>"] = { "<cmd>normal P<cr><Right>", desc = "Paste from clipboard" },

        ["<C-h>"] = { "<C-w>", desc = "Delete word" },
        ["<C-S-Left>"] = { '_<Esc>mz"_xv`z<BS>ob<Space>', desc = "" },
        ["<C-S-Right>"] = { '_<Esc>my"_xi<S-Right><C-o><BS>_<Esc>mz"_xv`yo`z', desc = "" },
        ["<S-End>"] = { "<cmd>normal v<End><cr><Esc>", desc = "" },
        ["<S-Home>"] = { "<cmd>normal hv<Home><cr><Esc>", desc = "" },
        ["<S-Up>"] = { "<cmd>normal vkloho<cr><Esc>", desc = "" },
        ["<S-Down>"] = { "<cmd>normal vj<cr><Esc>", desc = "" },
        ["<S-Left>"] = { "<Esc>v", desc = "" },
        ["<S-Right>"] = { "<Esc>vlolo", desc = "" },
        ["<S-PageUp>"] = { "<Esc>v<C-u>", desc = "" },
        ["<S-PageDown>"] = { "<Esc>v<C-d>", desc = "" },
      },
    },
  },
}
