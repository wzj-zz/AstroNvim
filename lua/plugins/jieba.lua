return {
  "kkew3/jieba.vim",
  branch = "release",
  build = ":call jieba_vim#install()",
  event = "VeryLazy",
  init = function()
    vim.g.jieba_vim_lazy = 1
    vim.g.jieba_vim_keymap = 1
  end,
  config = function()
    -- jieba's operator-pending maps start with <Esc>, which cancels pending g@
    -- operators like nvim-surround's `ys`; use builtin motions for those.
    for _, key in ipairs { "w", "W", "e", "E", "b", "B", "ge", "gE", "iw", "iW", "aw", "aW" } do
      vim.keymap.set("o", key, function()
        if vim.v.operator == "g@" then return key end
        return "<Plug>(Jieba_" .. key .. ")"
      end, { expr = true, remap = true })
    end
  end,
}
