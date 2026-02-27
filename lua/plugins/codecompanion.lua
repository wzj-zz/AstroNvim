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
    interactions = {
      chat = {
        -- adapter = "qwen_code",
        adapter = {
          name = "cliproxyapi",
          model = "gpt-5.3-codex",
        },
      },
      inline = {
        adapter = {
          name = "cliproxyapi",
          model = "gpt-5.3-codex",
        },
      },
      cmd = {
        adapter = {
          name = "cliproxyapi",
          model = "gpt-5.3-codex",
        },
      },
    },
    adapters = {
      http = {
        opts = {
          show_presets = false,
          -- allow_insecure = true,
          -- proxy = "http://127.0.0.1:8080",
        },
        cliproxyapi = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://127.0.0.1:2121",
              chat_url = "/v1/chat/completions",
              api_key = "CLIPROXY_API_KEY",
            },
          })
        end,
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
      },
      acp = {
        opts = {
          show_presets = false,
        },

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
