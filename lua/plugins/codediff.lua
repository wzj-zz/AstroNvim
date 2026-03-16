if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

local function set_codediff_aliases()
  local function focus_modified_window()
    local target_win
    local target_col = -1

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local filetype = vim.bo[buf].filetype
      if filetype ~= "codediff-explorer" and filetype ~= "codediff-history" then
        local pos = vim.api.nvim_win_get_position(win)
        local col = pos[2]
        if col > target_col then
          target_col = col
          target_win = win
        end
      end
    end

    if target_win and vim.api.nvim_win_is_valid(target_win) then vim.api.nvim_set_current_win(target_win) end
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.bo[buf].filetype

    if filetype == "codediff-explorer" or filetype == "codediff-history" then
      vim.keymap.set("n", "o", "<CR>", { buffer = buf, remap = true, desc = "Open selected entry" })
      vim.keymap.set("n", "l", "<CR>", { buffer = buf, remap = true, desc = "Open selected entry" })
    end

    vim.keymap.set("n", "<M-e>", focus_modified_window, {
      buffer = buf,
      desc = "Focus modified diff pane",
      silent = true,
    })
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffOpen",
  callback = function() vim.schedule(set_codediff_aliases) end,
})

return {
  "esmuellert/codediff.nvim",
  event = "User AstroGitFile",
  cmd = { "CodeDiff" },
  opts = {
    diff = {
      layout = "side-by-side",
      disable_inlay_hints = true,
      cycle_next_hunk = false,
      cycle_next_file = false,
      jump_to_first_change = true,
    },
    explorer = {
      position = "left",
      width = 40,
      view_mode = "list",
      flatten_dirs = true,
      focus_on_select = false,
      initial_focus = "explorer",
      visible_groups = {
        staged = true,
        unstaged = true,
        conflicts = true,
      },
    },
    history = {
      position = "bottom",
      height = 15,
      initial_focus = "history",
      view_mode = "list",
    },
    keymaps = {
      view = {
        quit = "<M-q>",
        toggle_explorer = "<Leader>b",
        focus_explorer = "<Leader>e",
        next_hunk = "<M-n>",
        prev_hunk = "<M-p>",
        next_file = "<tab>",
        prev_file = "<s-tab>",
        open_in_prev_tab = "gf",
        show_help = "g?",
        toggle_layout = "g<C-x>",
      },
      explorer = {
        select = "<CR>",
        refresh = "R",
        toggle_view_mode = "i",
        stage_all = "S",
        unstage_all = "U",
        restore = "X",
        fold_open = "zo",
        fold_close = "zc",
        fold_toggle = "za",
        fold_open_all = "zR",
        fold_close_all = "zM",
      },
      history = {
        select = "<CR>",
        refresh = "R",
        toggle_view_mode = "i",
        fold_open = "zo",
        fold_close = "zc",
        fold_toggle = "za",
        fold_open_all = "zR",
        fold_close_all = "zM",
      },
      conflict = {
        accept_current = ",o",
        accept_incoming = ",t",
        accept_both = ",a",
        discard = "dx",
        accept_all_current = ",O",
        accept_all_incoming = ",T",
        accept_all_both = ",A",
        discard_all = "dX",
        next_conflict = "<S-M-n>",
        prev_conflict = "<S-M-p>",
        diffget_incoming = "2do",
        diffget_current = "3do",
      },
    },
  },
}
