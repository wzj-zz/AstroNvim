local prefix = "<Leader>a"

return {
  "olimorris/codecompanion.nvim",
  event = "User AstroFile",
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    opts = {
      log_level = "ERROR",
      language = "中文",
    },
    strategies = {
      chat = {
        -- adapter = "qwen_code",
        -- adapter = "opencode",
        adapter = {
          name = "openrouter",
          model = "deepseek/deepseek-v3.2",
          -- model = "deepseek/deepseek-v3.2-speciale",
          -- model = "anthropic/claude-sonnet-4.5",
        },
      },
      inline = {
        adapter = {
          name = "openrouter",
          model = "deepseek/deepseek-v3.2",
          -- model = "deepseek/deepseek-v3.2-speciale",
          -- model = "anthropic/claude-sonnet-4.5",
        },
      },
      cmd = {
        adapter = {
          name = "openrouter",
          model = "deepseek/deepseek-v3.2",
          -- model = "deepseek/deepseek-v3.2-speciale",
          -- model = "anthropic/claude-sonnet-4.5",
        },
      },
    },
    adapters = {
      http = {
        opts = {
          show_defaults = false,
          -- allow_insecure = true,
          -- proxy = "socks5://127.0.0.1:1080",
        },
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "OPENROUTER_API_KEY",
              chat_url = "/v1/chat/completions",
            },
            handlers = {
              parse_message_meta = function(self, data)
                local extra = data.extra
                if extra and extra.reasoning then
                  data.output.reasoning = { content = extra.reasoning }
                  if data.output.content == "" then data.output.content = nil end
                end
                return data
              end,
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "GEMINI_API_KEY",
            },
          })
        end,
      },
      acp = {
        opts = {
          show_defaults = false,
          -- allow_insecure = true,
          -- proxy = "socks5://127.0.0.1:1080",
        },

        opencode = "opencode",

        qwen_code = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            name = "qwen_code",
            formatted_name = "Qwen Code",
            commands = {
              default = {
                "qwen",
                "--experimental-acp",
              },
              yolo = {
                "qwen",
                "--yolo",
                "--experimental-acp",
              },
            },
            defaults = {
              auth_method = "qwen-oauth",
              oauth_credentials_path = vim.fs.abspath "~/.qwen/oauth_creds.json",
            },
            handlers = {
              -- do not auth again if oauth_credentials is already exists
              auth = function(self)
                local oauth_credentials_path = self.defaults.oauth_credentials_path
                return (oauth_credentials_path and vim.fn.filereadable(oauth_credentials_path)) == 1
              end,
            },
          })
        end,

        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "gemini-api-key",
              mcpServers = {},
            },
            env = {
              GEMINI_API_KEY = "GEMINI_API_KEY",
            },
          })
        end,
      },
    },
  },
  specs = {
    {
      "rebelot/heirline.nvim",
      optional = true,

      opts = function(_, opts)
        opts.statusline = opts.statusline or {}
        local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        local astroui = require "astroui.status.hl"
        table.insert(opts.statusline, {
          static = {
            n_requests = 0,
            spinner_index = 0,
            spinner_symbols = spinner_symbols,
            done_symbol = "✓",
          },
          init = function(self)
            if self._cc_autocmds then return end
            self._cc_autocmds = true
            vim.api.nvim_create_autocmd("User", {
              pattern = "CodeCompanionRequestStarted",
              callback = function()
                self.n_requests = self.n_requests + 1
                vim.cmd "redrawstatus"
              end,
            })
            vim.api.nvim_create_autocmd("User", {
              pattern = "CodeCompanionRequestFinished",
              callback = function()
                self.n_requests = math.max(0, self.n_requests - 1)
                vim.cmd "redrawstatus"
              end,
            })
          end,
          provider = function(self)
            if not package.loaded["codecompanion"] then return nil end
            local symbol
            if self.n_requests > 0 then
              self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
              symbol = self.spinner_symbols[self.spinner_index]
            else
              symbol = self.done_symbol
              self.spinner_index = 0
            end
            return ("%d %s"):format(self.n_requests, symbol)
          end,
          hl = function() return astroui.filetype_color() end,
        })
      end,
    },
    { "AstroNvim/astroui", opts = { icons = { CodeCompanion = "󱙺" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = {} end
        opts.mappings.n = opts.mappings.n or {}
        opts.mappings.v = opts.mappings.v or {}
        opts.mappings.n[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
        opts.mappings.v[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
        opts.mappings.n["<M-o>"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
        opts.mappings.n[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
        opts.mappings.v[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
        opts.mappings.n[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
        opts.mappings.v[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
        opts.mappings.n[prefix .. "i"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
        opts.mappings.v[prefix .. "i"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
        opts.mappings.v[prefix .. "a"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat" }
      end,
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.file_types = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "codecompanion" })
      end,
    },
    {
      "OXY2DEV/markview.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.preview then opts.preview = {} end
        if not opts.preview.filetypes then opts.preview.filetypes = { "markdown", "quarto", "rmd" } end
        opts.preview.filetypes = require("astrocore").list_insert_unique(opts.preview.filetypes, { "codecompanion" })
      end,
    },
  },
}
