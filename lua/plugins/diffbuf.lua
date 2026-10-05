if vim.g.vscode then return {} end

local function setup_diff_mappings()
  if vim.wo.diff then
    vim.keymap.set("n", "<M-n>", "]czz", {
      buffer = true,
      desc = "Next diff hunk",
      silent = true,
      nowait = true,
    })

    vim.keymap.set("n", "<M-p>", "[czz", {
      buffer = true,
      desc = "Previous diff hunk",
      silent = true,
      nowait = true,
    })
  end
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "diff",
  callback = function()
    setup_diff_mappings()
    if not vim.wo.diff then
      pcall(vim.keymap.del, "n", "<M-n>", { buffer = true })
      pcall(vim.keymap.del, "n", "<M-p>", { buffer = true })
    end
  end,
})

-- OptionSet does not fire when 'diff' is toggled from inside another autocmd
-- callback (e.g. opencode.nvim session-diff: file switching is driven by the
-- list window's CursorMoved, so diffthis runs in a nested context). WinEnter
-- covers that gap: focusing a diff-mode window ensures the mappings exist.
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    if vim.wo.diff then setup_diff_mappings() end
  end,
})

if vim.wo.diff then setup_diff_mappings() end
return {}
