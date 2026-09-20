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
    -- jieba also segments Chinese for WORD motions, so uppercase W/E/B stop
    -- mid-string almost like lowercase. Drop those maps: builtin W/E/B/gE
    -- treat a continuous Chinese string as one WORD (jump to its end).
    for _, key in ipairs { "W", "E", "B", "gE" } do
      for _, mode in ipairs { "n", "x", "o" } do
        if vim.fn.maparg(key, mode) ~= "" then vim.keymap.del(mode, key) end
      end
    end
    -- jieba's operator-pending maps start with <Esc>, which cancels pending g@
    -- operators like nvim-surround's `ys`. Motions and WORD objects just fall
    -- back to builtin behavior in that case; but builtin iw/aw would span the
    -- whole continuous Chinese run, so for iw/aw we ask jieba for its range
    -- and select it visually -- a pending operator applies to a visual
    -- selection left by an omap, so g@ surrounds the segmented word.
    _G.jieba_g_at_select = function(key, count)
      local ok, res = pcall(vim.fn.JiebaModelOmap, key, vim.fn.getcurpos(), count, "g@")
      if not ok or (res.langle[2] == res.rangle[2] and res.langle[3] == res.rangle[3] and res.selection == "exclusive") then
        vim.api.nvim_feedkeys(vim.keycode "<Esc>", "n", false)
        return
      end
      vim.api.nvim_win_set_cursor(0, { res.langle[2], res.langle[3] - 1 })
      vim.cmd "normal! v"
      vim.api.nvim_win_set_cursor(0, { res.rangle[2], res.rangle[3] - 1 })
    end
    for _, key in ipairs { "w", "e", "b", "ge", "iW", "aW" } do
      vim.keymap.set("o", key, function()
        if vim.v.operator == "g@" then return key end
        return "<Plug>(Jieba_" .. key .. ")"
      end, { expr = true, remap = true })
    end
    for _, key in ipairs { "iw", "aw" } do
      vim.keymap.set("o", key, function()
        if vim.v.operator == "g@" then
          return ":<C-u>lua jieba_g_at_select('" .. key .. "', " .. vim.v.count1 .. ")<CR>"
        end
        return "<Plug>(Jieba_" .. key .. ")"
      end, { expr = true, remap = true })
    end
  end,
}
