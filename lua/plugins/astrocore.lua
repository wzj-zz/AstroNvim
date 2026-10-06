if vim.g.vscode then return {} end

-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local xtools = require "xtools"
local is_windows = vim.fn.has "win32" == 1
local default_shell = is_windows and (vim.fn.executable "pwsh.exe" == 1 and "pwsh.exe" or "cmd.exe") or vim.o.shell
local default_shellcmdflag = is_windows and "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  or vim.o.shellcmdflag
local default_shellquote = is_windows and "" or vim.o.shellquote
local default_shellxquote = is_windows and "" or vim.o.shellxquote

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      auto_install = true,
      enabled = function(_, bufnr) return not require("astrocore.buffer").is_large(bufnr) end,
      highlight = true,
      indent = true,
      ensure_installed = {
        "lua",
        "vim",
        "bash",
        "zig",
        "ql",
        "rust",
        "c_sharp",
        "python",
        "asm",
        "nasm",
        "c",
        "cpp",
        "objc",
        "cuda",
        "proto",
        "cmake",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "java",
        "javadoc",
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "json",
        "jsonc",
        "xml",
        "toml",
        "yaml",
        "html",
        "markdown",
        "markdown_inline",
      },
    },
    sessions = {
      autosave = { last = false, cwd = false },
    },
    features = {
      large_buf = {
        size = 1024 * 1024,
        lines = false,
        line_length = false,
      },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      opt = {
        relativenumber = true,
        number = true,
        shellcmdflag = default_shellcmdflag,
        shellquote = default_shellquote,
        spell = false,
        shell = default_shell,
        shellxquote = default_shellxquote,
        signcolumn = "yes",
        wrap = true,
        wrapscan = false,
      },
      g = {
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file

        clipboard = (function()
          -- WSL 固定用仓库自带的 win32yank，避免 wl-copy/xclip 抢优先级
          if vim.fn.has "wsl" == 1 then
            local win32yank = vim.fn.stdpath "config" .. "/bin/win32yank.exe"
            return {
              name = "win32yank",
              copy = { ["+"] = { win32yank, "-i", "--crlf" }, ["*"] = { win32yank, "-i", "--crlf" } },
              paste = { ["+"] = { win32yank, "-o", "--lf" }, ["*"] = { win32yank, "-o", "--lf" } },
            }
          end
          -- 其余环境走默认探测链；无可用工具时（如 SSH 服务器）兜底 OSC 52
          if is_windows or vim.fn.has "macunix" == 1 then return nil end
          if vim.env.WAYLAND_DISPLAY and (vim.fn.executable "wl-copy" == 1 or vim.fn.executable "waycopy" == 1) then
            return nil
          end
          if vim.env.DISPLAY and (vim.fn.executable "xsel" == 1 or vim.fn.executable "xclip" == 1) then return nil end
          if vim.fn.executable "termux-clipboard-set" == 1 then return nil end
          if vim.env.TMUX and vim.fn.executable "tmux" == 1 then return nil end
          -- 粘贴只回本会话复制过的内容：OSC 52 读取在不支持的终端上会挂起
          local osc52 = require "vim.ui.clipboard.osc52"
          local cache = {}
          local function wrap_copy(reg)
            local copy = osc52.copy(reg)
            return function(lines, regtype)
              cache[reg] = { lines, regtype }
              copy(lines, regtype)
            end
          end
          local function wrap_paste(reg) return function() return cache[reg] or {} end end
          return {
            name = "osc52-copy-only",
            copy = { ["+"] = wrap_copy "+", ["*"] = wrap_copy "*" },
            paste = { ["+"] = wrap_paste "+", ["*"] = wrap_paste "*" },
          }
        end)(),
      },
    },
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      n = {
        ["<Leader>q"] = false,
        ["<Leader>h"] = false,
        ["<C-z>"] = { function() xtools.toggle_window_zoom() end, desc = "Toggle window zoom" },

        ["<M-q>"] = { "<cmd>close<cr>", desc = "Close window" },
        ["<C-.>"] = { "<C-w>w", desc = "Switch window" },
        ["<Leader><Tab>"] = { "<C-w>w", desc = "Switch window" },

        ["<M-d>"] = { "<cmd>normal gd<cr>", desc = "goto definition" },
        ["<M-r>"] = { "<cmd>normal grr<cr>", desc = "goto references" },
        ["<M-y>"] = { "<cmd>normal gy<cr>", desc = "goto type definition" },
        ["<M-i>"] = { "<cmd>normal gri<cr>", desc = "goto implementation" },
        ["<M-[>"] = {
          function()
            if vim.wo.diff then
              vim.cmd.normal { "[c", bang = true }
              return
            end
            require("gitsigns").nav_hunk "prev"
          end,
          desc = "Previous git hunk",
        },
        ["<M-]>"] = {
          function()
            if vim.wo.diff then
              vim.cmd.normal { "]c", bang = true }
              return
            end
            require("gitsigns").nav_hunk "next"
          end,
          desc = "Next git hunk",
        },

        ["<M-1>"] = { "<cmd>tabn 1<cr>", desc = "goto tabn 1" },
        ["<M-2>"] = { "<cmd>tabn 2<cr>", desc = "goto tabn 2" },
        ["<M-3>"] = { "<cmd>tabn 3<cr>", desc = "goto tabn 3" },
        ["<M-4>"] = { "<cmd>tabn 4<cr>", desc = "goto tabn 4" },

        ["<S-M-i>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-M-u>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<Leader>lt"] = { "<cmd>InspectTree<cr>", desc = "Show AST" },

        ["<Leader>fl"] = { function() require("telescope.builtin").filetypes() end, desc = "Select Language" },

        ["<Leader>bv"] = { "<cmd>e!<cr>", desc = "Revert Buffer" },
        ["<Leader>bx"] = {
          function()
            require("astrocore.buffer").close_all(true)
            vim.cmd "only"
          end,
          desc = "Close all buffers/windows except current",
        },

        ["<Leader>,"] = { name = "Local" },
        ["<Leader>,a"] = { "<cmd>normal! ggVG<cr>", desc = "Select entire buffer" },
        ["<Leader>,dd"] = { "<cmd>diffthis<cr>", desc = "diffthis" },
        ["<Leader>,dc"] = { "<cmd>diffoff!<cr>", desc = "diffoff" },
        ["<Leader>,dg"] = { "<cmd>diffget<cr>", desc = "diffget" },
        ["<Leader>,dp"] = { "<cmd>diffput<cr>", desc = "diffput" },
        ["<Leader>,r"] = { "<cmd>%s/\\r//ge<cr>", desc = "Remove all ^M (CR)" },
        ["<Leader>,x"] = {
          function()
            local code = xtools.get_buf_content()
            xtools.xtools_exec_vertical(code)
          end,
          desc = "xtools exec vertical",
        },
        ["<Leader>,f"] = {
          function()
            local code = xtools.get_buf_content()
            xtools.xtools_exec_float(code)
          end,
          desc = "xtools exec float",
        },
        ["<Leader>,v"] = {
          function()
            local code = xtools.get_buf_content()
            xtools.xtools_eval(code)
          end,
          desc = "xtools eval",
        },
        ["<Leader>,z"] = {
          "<cmd>%lua<cr>",
          desc = "lua exec",
        },

        ["<Leader>,e"] = {
          function()
            vim.cmd "cd %:h"
            vim.cmd "Neotree focus"
            vim.cmd "pwd"
          end,
          desc = "Sync Neotree With Current Buffer",
        },
        ["<M-/>"] = {
          function() xtools.toggle_shell() end,
          desc = "ToggleTerm shell",
        },
        ["<M-O>"] = (is_windows or vim.fn.has "wsl" == 1) and {
          function() xtools.open_agent_wt "opencode2" end,
          desc = "Open opencode2 in Windows Terminal split pane",
        } or nil,
        ["<Leader>,s"] = {
          function()
            xtools.new_term_cmd_vertical {
              cmd = "xs",
              display_name = "xtools",
            }
          end,
          desc = "ToggleTerm xtools (python)",
        },

        ["<Leader>,1"] = {
          function() xtools.yank_clip(vim.fn.expand "%:p:h") end,
          desc = "Yank directory path",
        },
        ["<Leader>,2"] = { function() xtools.yank_clip(vim.fn.expand "%:t") end, desc = "Yank filename" },
        ["<Leader>,3"] = { function() xtools.yank_clip(vim.fn.expand "%:p") end, desc = "Yank full path" },
        ["<Leader>,c"] = {
          function() xtools.yank_clip(xtools.cwd()) end,
          desc = "Yank CWD",
        },
        ["<Leader>,w"] = (is_windows or vim.fn.has "wsl" == 1) and {
          function() xtools.open_agent_wt "codex" end,
          desc = "Open codex in Windows Terminal split pane",
        } or nil,
        ["<Leader>,W"] = (is_windows or vim.fn.has "wsl" == 1) and {
          function() xtools.select_agent_wt() end,
          desc = "Select agent in Windows Terminal split pane",
        } or nil,
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

        ["<Leader>,hh"] = { "<cmd>%!xxd -g 1<cr>", desc = "Switch to hex view" },
        ["<Leader>,hr"] = { "<cmd>%!xxd -r<cr>", desc = "Switch to binary view" },
        ["<Leader>,ho"] = { ":e ++binary ", desc = "Open binary file" },
        ["<Leader>,h"] = { name = "Hex" },
      },

      v = {
        ["<Leader>,"] = { name = "Local" },
        ["<Leader>,x"] = {
          function()
            local code = xtools.get_vbuf_content()
            xtools.xtools_exec_vertical(code)
          end,
          desc = "xtools exec vertical",
        },
        ["<Leader>,f"] = {
          function()
            local code = xtools.get_vbuf_content()
            xtools.xtools_exec_float(code)
          end,
          desc = "xtools exec float",
        },
        ["<Leader>,v"] = {
          function()
            local code = xtools.get_vbuf_content()
            xtools.xtools_eval(code)
          end,
          desc = "xtools eval",
        },
        ["<Leader>,z"] = {
          "<Esc><cmd>'<,'>%lua<cr>",
          desc = "lua exec",
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

      c = { ["<C-v>"] = { "<C-r>*", desc = "Paste in Command mode" } },

      t = {
        ["<C-l>"] = false,
        ["<M-w>"] = {
          [[<C-\><C-n><cmd>lua Snacks.picker.buffers()<cr>]],
          desc = "Find Buffer",
        },
        ["<M-/>"] = {
          [[<C-\><C-n><cmd>lua require("xtools").toggle_shell()<cr>]],
          desc = "ToggleTerm shell",
        },
        ["<M-q>"] = {
          "<cmd>close<cr>",
          desc = "Close buffer",
        },
      },

      i = {
        ["<C-s>"] = { "<Esc>:w<cr>", desc = "Save" },
        ["<C-z>"] = { '<Esc><cmd>lua require("xtools").toggle_window_zoom()<cr>', desc = "Toggle window zoom" },
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
