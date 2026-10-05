if vim.g.vscode then return {} end

return {
  "Saghen/blink.cmp",
  build = "cargo build --release",
  opts = {
    signature = { enabled = true },
  },
}
