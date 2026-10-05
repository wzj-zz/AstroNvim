-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = false,
        allow_filetypes = {
          -- "go",
        },
        ignore_filetypes = {
          -- "python",
        },
      },
      disabled = {
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 3000,
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- client specific configuration can also go in `lsp/` in your configuration root (see `:h lsp-config`)
    config = {
      -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
    },
    handlers = {
      -- a function with the key `*` modifies the default handler, functions takes the server name as the parameter
      -- ["*"] = function(server) vim.lsp.enable(server) end

      -- the key is the server that is being setup with `vim.lsp.config`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lsp-attach`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
