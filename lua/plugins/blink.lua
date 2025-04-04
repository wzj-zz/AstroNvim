if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return { -- override blink.cmp plugin
  "Saghen/blink.cmp",
  opts = {
    signature = { enabled = true },
  },
}
