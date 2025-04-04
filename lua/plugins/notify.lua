if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

return {
  "rcarriga/nvim-notify",
  opts = {
    timeout = 0,
  },
}
