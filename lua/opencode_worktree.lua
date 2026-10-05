-- Backend for the worktree picker on <M-w> in opencode windows (registered in
-- lua/plugins/opencode.lua via a buffer-local FileType autocmd).
--
-- Worktrees live under <repo>/.worktrees/<branch>; a session tab opened there is
-- pinned to its repo: :cd inside the same repo cannot hijack it, :cd to another
-- repo unpins it and follows normally.
--
-- Uses opencode.nvim internals (no public "session in directory" API); upstream
-- refactors break this in isolation. Simplify once upstream lands
-- https://github.com/sudo-tee/opencode.nvim/issues/511.

local M = {}

---@param cmd string[]
---@param cwd string
---@param cb fun(ok: boolean, stdout: string, stderr: string)
local function git(cmd, cwd, cb)
  vim.system(vim.list_extend({ "git" }, cmd), { cwd = cwd, text = true }, function(res)
    vim.schedule(function() cb(res.code == 0, res.stdout or "", res.stderr or "") end)
  end)
end

---@param name string
---@return string
local function sanitize_branch(name)
  return (name:gsub("%s+", "-"):gsub("[~^:%?*%[%]\\]", ""):gsub("^[-.]+", ""):gsub("[%.%-]+$", ""))
end

-- Keep .worktrees/ out of git status via the repo-local exclude file (not the
-- shared .gitignore, so this doesn't touch tracked files).
---@param root string
local function exclude_worktrees_dir(root)
  local exclude = root .. "/.git/info/exclude"
  local f = io.open(exclude, "r")
  local content = f and f:read "*a" or ""
  if f then f:close() end
  if content:find(".worktrees/", 1, true) then return end
  f = io.open(exclude, "a")
  if f then
    f:write "\n.worktrees/\n"
    f:close()
  end
end

-- tab id -> main repo root, for tabs created by this module.
---@type table<string, string>
local repo_root_by_tab = {}

local scoped_lock_installed = false

---@param dir string
---@param root string
---@return boolean
local function dir_is_under(dir, root)
  local n = vim.fs.normalize(dir):lower()
  local r = vim.fs.normalize(root):lower()
  return n == r or n:sub(1, #r + 1) == r .. "/"
end

-- Patch two plugin internals so worktree tabs are pinned only within their repo:
-- is_session_locked (the plugin's only session-swap decision point) reports locked
-- only while cwd is under the tab's repo root; set_current_cwd is blocked
-- in-family so the tab keeps pointing at the worktree (<C-n>, `@` completion),
-- and unpins the tab once cwd leaves the repo. Other tabs keep plugin semantics.
local function install_scoped_lock()
  if scoped_lock_installed then return end
  scoped_lock_installed = true
  local session_runtime = require "opencode.services.session_runtime"
  local session_tabs = require "opencode.state.session_tabs"
  local context = require "opencode.state.context"

  local orig_is_locked = session_runtime.is_session_locked

  -- Repo root when the active tab is one of our locked worktree tabs, else nil.
  local function locked_tab_root()
    if not orig_is_locked() then return nil end
    local ok, tab = pcall(session_tabs.current)
    return (ok and tab and repo_root_by_tab[tab.id]) or nil
  end

  session_runtime.is_session_locked = function()
    local root = locked_tab_root()
    if not root then return orig_is_locked() end
    return dir_is_under(vim.fn.getcwd(), root)
  end

  local orig_set_cwd = context.set_current_cwd
  context.set_current_cwd = function(cwd)
    local root = locked_tab_root()
    if root then
      if dir_is_under(cwd, root) then return end
      local ok, tab = pcall(session_tabs.current)
      if ok and tab then repo_root_by_tab[tab.id] = nil end
      session_runtime.set_session_lock(false)
    end
    return orig_set_cwd(cwd)
  end
end

---@param worktree_path string
---@param branch string
---@param root string git toplevel of the main repo
local function open_session_tab(worktree_path, branch, root)
  local Promise = require "opencode.promise"
  Promise.async(function()
    local util = require "opencode.util"
    local session_runtime = require "opencode.services.session_runtime"
    local connection = require("opencode.server_job").ensure_server():await()

    local location = { directory = worktree_path }

    -- Reopen the directory's most recent session if one exists (its tab may
    -- have been closed); only create a fresh session otherwise.
    local existing = connection.operations
      .list_sessions_project(connection, location, util.apply_path_map, util.apply_reverse_path_map)
      :await()
    local session
    if type(existing) == "table" then
      table.sort(existing, function(a, b)
        return (a.time and a.time.updated or 0) > (b.time and b.time.updated or 0)
      end)
      for _, s in ipairs(existing) do
        if s.parentID == nil then
          session = s
          break
        end
      end
    end
    if not session then
      session = connection.operations
        .create_session(connection, location, { title = "wt:" .. branch }, util.apply_path_map, util.apply_reverse_path_map)
        :await()
    end
    if not session or not session.id then
      return vim.notify("Failed to create session for worktree " .. branch, vim.log.levels.ERROR)
    end
    session.location = session.location or location

    session_runtime.open_session_in_tab(session):await()

    -- Point the new tab at the worktree and pin it (see install_scoped_lock).
    require("opencode.state.context").set_current_cwd(worktree_path)
    session_runtime.set_session_lock(true)
    repo_root_by_tab[require("opencode.state.session_tabs").active_id()] = root
    install_scoped_lock()
    vim.notify("Worktree session ready: " .. branch, vim.log.levels.INFO)
  end)():catch(function(err) vim.notify("Open worktree session failed: " .. vim.inspect(err), vim.log.levels.ERROR) end)
end

---@param root string git toplevel
---@param branch string
function M.open_worktree(root, branch)
  local path = root .. "/.worktrees/" .. branch
  if vim.uv.fs_stat(path) then return open_session_tab(path, branch, root) end

  exclude_worktrees_dir(root)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  -- Exit code 0 = branch exists; reuse it, otherwise create it.
  git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }, root, function(exists)
    local cmd = exists and { "worktree", "add", path, branch } or { "worktree", "add", "-b", branch, path }
    vim.notify("Creating worktree " .. branch .. " ...", vim.log.levels.INFO)
    git(cmd, root, function(ok, _, stderr)
      if not ok then return vim.notify("git worktree add failed: " .. stderr, vim.log.levels.ERROR) end
      open_session_tab(path, branch, root)
    end)
  end)
end

-- Synchronous git call for the picker's finder (local worktree listing is fast).
---@param cmd string[]
---@param cwd string
---@return boolean ok, string stdout
local function git_sync(cmd, cwd)
  local res = vim.system(vim.list_extend({ "git" }, cmd), { cwd = cwd, text = true }):wait()
  return res.code == 0, res.stdout or ""
end

---@param root string git toplevel
---@return {path: string, branch: string}[]
local function list_worktrees(root)
  local ok, stdout = git_sync({ "worktree", "list", "--porcelain" }, root)
  local items = {}
  if not ok then return items end
  local path, branch
  for line in (stdout .. "\n"):gmatch "(.-)\n" do
    local wt = line:match "^worktree (.+)$"
    if wt then
      path, branch = wt, nil
    elseif line == "" and path then
      table.insert(items, { path = path, branch = branch or "(detached)" })
      path, branch = nil, nil
    elseif path then
      branch = line:match "^branch refs/heads/(.+)$" or branch
    end
  end
  return items
end

---@param root string git toplevel
---@return string[]
local function list_branches(root)
  local ok, stdout = git_sync({ "branch", "--format=%(refname:short)" }, root)
  if not ok then return {} end
  return vim.split(vim.trim(stdout), "\n", { trimempty = true })
end

---@param root string git toplevel
---@param path string
---@param branch string
---@param cb fun(ok: boolean)
local function remove_worktree(root, path, branch, cb)
  -- Force on purpose: the user owns the consequences (uncommitted changes and
  -- unmerged branch work are discarded without asking).
  git({ "worktree", "remove", "--force", path }, root, function(ok, _, stderr)    if not ok then
      vim.notify("git worktree remove failed: " .. stderr, vim.log.levels.ERROR)
      return cb(false)
    end
    if branch == "(detached)" then return cb(true) end
    git({ "branch", "-D", branch }, root, function() cb(true) end)
  end)
end

---@param root string git toplevel
---@param branch string
---@param picker any
local function delete_branch(root, branch, picker)
  git({ "branch", "-D", branch }, root, function(ok, _, stderr)
    if not ok then return vim.notify("git branch -D failed: " .. stderr, vim.log.levels.ERROR) end
    vim.notify("Deleted branch " .. branch, vim.log.levels.INFO)
    picker:refresh()
  end)
end

---Open the worktree picker: <CR> open/recreate session tab, <C-a> new branch,
---<C-d> force-delete worktree/branch, <C-r> refresh. Merging is left to the agent.
function M.pick()
  local base = require("opencode.state").current_cwd or vim.fn.getcwd()
  local ok, stdout = git_sync({ "rev-parse", "--show-toplevel" }, base)
  if not ok then return vim.notify("Not a git repository", vim.log.levels.ERROR) end
  local root = vim.trim(stdout)

  local keys = {
    ["<C-a>"] = { "worktree_create", mode = { "n", "i" }, desc = "New branch worktree" },
    ["<C-d>"] = { "worktree_delete", mode = { "n", "i" }, desc = "Force delete worktree/branch" },
    ["<C-r>"] = { "worktree_refresh", mode = { "n", "i" }, desc = "Refresh" },
  }
  require("snacks").picker.pick {
    title = "Git Worktrees|<C-a> new|<C-d> del|<C-r> refresh",
    finder = function()
      local items = {}
      local in_worktree = {}
      for _, wt in ipairs(list_worktrees(root)) do
        in_worktree[wt.branch] = true
        table.insert(items, { text = wt.branch .. " " .. wt.path, path = wt.path, branch = wt.branch })
      end
      -- Also list worktree-less branches so they stay visible and manageable.
      for _, b in ipairs(list_branches(root)) do
        if not in_worktree[b] then
          table.insert(items, { text = b .. " (no worktree)", branch = b })
        end
      end
      return items
    end,
    format = function(item)
      return { { item.branch, "Special" }, { "  " .. (item.path or "(no worktree)"), "Comment" } }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      if item.path then
        open_session_tab(item.path, item.branch, root)
      else
        M.open_worktree(root, item.branch)
      end
    end,
    actions = {
      worktree_create = function(picker)
        picker:close()
        vim.ui.input({ prompt = "New branch name: " }, function(input)
          local branch = input and sanitize_branch(vim.trim(input)) or ""
          if branch ~= "" then M.open_worktree(root, branch) end
        end)
      end,
      worktree_delete = function(picker, item)
        if not item then return end
        if not item.path then return delete_branch(root, item.branch, picker) end
        if vim.fs.normalize(item.path) == vim.fs.normalize(root) then
          return vim.notify("Cannot remove the main worktree", vim.log.levels.WARN)
        end
        remove_worktree(root, item.path, item.branch, function(removed)
          if removed then picker:refresh() end
        end)
      end,
      worktree_refresh = function(picker) picker:refresh() end,
    },
    win = { input = { keys = keys }, list = { keys = keys } },
  }
end

return M
