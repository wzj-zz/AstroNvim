if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.g.sqlite_clib_path = vim.fn.stdpath "config" .. "\\sqlite3.dll"
end

local function switch_to_session_bookmark_list()
  local resession = require "resession"
  local session_name = resession.get_current()

  local Repo = require "bookmarks.domain.repo"
  local Service = require "bookmarks.domain.service"
  local lists = Repo.find_lists()
  local target_list_id = nil

  if session_name == nil then
    Service.set_active_list(0)
    return
  end

  -- Look for existing list with the session name
  for _, list_node in ipairs(lists) do
    if list_node.name == session_name then
      target_list_id = list_node.id
      break
    end
  end

  -- If list doesn't exist, create it
  if not target_list_id then
    local new_list = Service.create_list(session_name)
    target_list_id = new_list.id
  end

  -- Switch to the list (whether it was found or created)
  if target_list_id then Service.set_active_list(target_list_id) end
end

return {
  "LintaoAmons/bookmarks.nvim",
  dependencies = {
    { "kkharji/sqlite.lua" },
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    local opts = {
      navigation = {
        next_prev_wraparound_same_file = false,
      },
    } -- check the "./lua/bookmarks/default-config.lua" file for all the options
    require("bookmarks").setup(opts)
  end,
  specs = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>m"] = { name = "Bookmark" },
          ["<Leader>mn"] = { "<cmd>BookmarksNewList<cr>", desc = "New Bookmark List" },
          ["<Leader>mm"] = { "<cmd>BookmarksMark<cr>", desc = "Add Bookmark" },
          ["<Leader>m;"] = { "<cmd>BookmarksDesc<cr>", desc = "Bookmark Desc" },
          ["<Leader>mf"] = { "<cmd>BookmarksGoto<cr>", desc = "Find Bookmark" },
          ["<Leader>mg"] = { "<cmd>BookmarksGrep<cr>", desc = "Grep Bookmarked Files" },
          ["<Leader>ma"] = { "<cmd>BookmarksCommands<cr>", desc = "Bookmark Command" },
          ["<Leader>mr"] = { "<cmd>BookmarkRebindOrphanNode<cr>", desc = "Bookmark Rebind" },
          ["<Leader>mv"] = { "<cmd>BookmarksInfoCurrentBookmark<cr>", desc = "Current Bookmark Info" },
          ["<Leader>mi"] = {
            function() require("bookmarks.commands")["Goto linked in bookmarks"]() end,
            desc = "Goto Linked In Bookmarks",
          },
          ["<Leader>mo"] = {
            function() require("bookmarks.commands")["Goto linked out bookmarks"]() end,
            desc = "Goto Linked Out Bookmarks",
          },
          ["<Leader>ml"] = {
            function() require("bookmarks.commands")["Link bookmark"]() end,
            desc = "Link Bookmark",
          },
          ["<Leader>ms"] = {
            function() require("bookmarks.commands").mark_selected_files() end,
            desc = "Mark Selected Files",
          },
          ["<Leader>mq"] = {
            function()
              vim.cmd "BookmarksQuery"
              vim.cmd "setlocal nowrap"
            end,
            desc = "Query Bookmark",
          },

          ["<M-{>"] = { "<cmd>BookmarksGotoPrevInList<cr>", desc = "Prev Bookmark (by order id)" },
          ["<M-}>"] = { "<cmd>BookmarksGotoNextInList<cr>", desc = "Next Bookmark (by order id)" },
          ["<M-/>"] = {
            function()
              switch_to_session_bookmark_list()
              vim.cmd "BookmarksTree"
              vim.cmd "setlocal nowrap"
            end,
            desc = "Bookmark Tree",
          },
        },
      },
    },
  },
}
