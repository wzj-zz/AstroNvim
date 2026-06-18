return {
  "kkew3/jieba.vim",
  branch = "release",
  build = ":call jieba_vim#install()",
  event = "VeryLazy",
  init = function()
    vim.g.jieba_vim_lazy = 1
    vim.g.jieba_vim_keymap = 1
  end,
}
