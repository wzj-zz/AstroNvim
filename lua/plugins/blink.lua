if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return { -- override blink.cmp plugin
  "Saghen/blink.cmp",
  build = "cargo build --release",
  opts = {
    signature = { enabled = true },
  },
}
