-- Backend for the worktree picker on <M-w> in opencode windows (registered in
-- lua/plugins/opencode.lua via a buffer-local FileType autocmd).
--
-- Worktrees live under <repo>/.worktrees/<branch>. Tabs are directory-bound via
-- the official API (https://github.com/sudo-tee/opencode.nvim/pull/517,
-- issues #511/#513): same-repo :cd stays pinned (repo-wide lock policy in
-- lua/plugins/opencode.lua), :cd to another repo unbinds the tab.

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

---@param worktree_path string
---@param branch string
local function open_session_tab(worktree_path, branch)
  require("opencode.promise").async(function()
    local session_tabs = require "opencode.state.session_tabs"
    local session_runtime = require "opencode.services.session_runtime"
    local target = vim.fs.normalize(worktree_path):lower()
    -- Prefer the tab already bound to this directory: the reuse lookup inside
    -- open_session matches server-side session paths, which don't survive
    -- Windows cwd/port mapping — without this every <CR> spawns a new session.
    for _, tab in ipairs(session_tabs.list()) do
      local dir = tab.bound_directory
      if not dir then
        -- Tabs restored on startup have no binding; match by session dir.
        local s = tab.active_session
        dir = s and (s.location and s.location.directory or s.directory)
      end
      if dir and vim.fs.normalize(dir):lower() == target then
        session_runtime.switch_session_tab(tab.id):await()
        return vim.notify("Worktree session ready: " .. branch, vim.log.levels.INFO)
      end
    end
    -- open_session reopens the directory's most recent root session if one
    -- exists (its tab may have been closed); creates a fresh one otherwise.
    local ok, err = pcall(function()
      require("opencode.api").open_session({ directory = worktree_path, title = "wt:" .. branch }):await()
    end)
    if ok then
      vim.notify("Worktree session ready: " .. branch, vim.log.levels.INFO)
    else
      vim.notify("Open worktree session failed: " .. vim.inspect(err), vim.log.levels.ERROR)
    end
  end)()
end

---@param root string git toplevel of the main repo
---@param branch string
function M.open_worktree(root, branch)
  local path = root .. "/.worktrees/" .. branch
  if vim.uv.fs_stat(path) then return open_session_tab(path, branch) end

  exclude_worktrees_dir(root)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  -- Exit code 0 = branch exists; reuse it, otherwise create it.
  git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }, root, function(exists)
    local cmd = exists and { "worktree", "add", path, branch } or { "worktree", "add", "-b", branch, path }
    vim.notify("Creating worktree " .. branch .. " ...", vim.log.levels.INFO)
    git(cmd, root, function(ok, _, stderr)
      if not ok then return vim.notify("git worktree add failed: " .. stderr, vim.log.levels.ERROR) end
      open_session_tab(path, branch)
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

---@param stdout string `git worktree list --porcelain` output
---@return {path: string, branch: string}[]
local function parse_worktrees(stdout)
  local items = {}
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

-- Close session tabs whose session lives in a deleted directory.
---@param dir string
local function close_tabs_for_dir(dir)
  local session_tabs = require "opencode.state.session_tabs"
  local session_runtime = require "opencode.services.session_runtime"
  local target = vim.fs.normalize(dir):lower()
  for _, tab in ipairs(session_tabs.list()) do
    -- PR #517's open_session attaches a bound tab directory.
    local d = tab.bound_directory
    if not d then
      local s = tab.active_session
      d = s and (s.location and s.location.directory or s.directory)
    end
    if type(d) == "string" and vim.fs.normalize(d):lower() == target then
      if tab.id == session_tabs.active_id() then
        -- Closing the current tab from inside it switches into another tab;
        -- the policy would carry our binding along, so detach first.
        tab.bound_directory = nil
      end
      session_runtime.close_session_tab(tab.id)
    end
  end
end

---@param root string git toplevel
---@param path string
---@param branch string
---@param cb fun(ok: boolean)
local function remove_worktree(root, path, branch, cb)
  -- Force on purpose: the user owns the consequences (uncommitted changes and
  -- unmerged branch work are discarded without asking).
  git({ "worktree", "remove", "--force", path }, root, function(ok, _, stderr)
    if not ok then
      vim.notify("git worktree remove failed: " .. stderr, vim.log.levels.ERROR)
      return cb(false)
    end
    close_tabs_for_dir(path)
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
    if not picker.closed then picker:refresh() end
  end)
end

---Open the worktree picker: <CR> open/recreate session tab, <C-a> new branch,
---<C-d> force-delete worktree/branch, <C-r> refresh. Merging is left to the agent.
function M.pick()
  local base = require("opencode.state").current_cwd or vim.fn.getcwd()
  -- Resolve the MAIN repo root even when the current tab sits in a worktree
  -- (--show-toplevel would return the worktree's own path there).
  local ok, stdout = git_sync({ "rev-parse", "--path-format=absolute", "--git-common-dir" }, base)
  if not ok then return vim.notify("Not a git repository", vim.log.levels.ERROR) end
  local root = vim.fs.dirname(vim.trim(stdout))

  local keys = {
    ["<C-a>"] = { "worktree_create", mode = { "n", "i" }, desc = "New branch worktree" },
    ["<C-d>"] = { "worktree_delete", mode = { "n", "i" }, desc = "Force delete worktree/branch" },
    ["<C-r>"] = { "worktree_refresh", mode = { "n", "i" }, desc = "Refresh" },
  }
  require("snacks").picker.pick {
    title = "Git Worktrees|<C-a> new|<C-d> del|<C-r> refresh",
    finder = function()
      -- Spawn both listings concurrently: process startup dominates on Windows,
      -- two sequential waits would double the picker latency.
      local wt_proc = vim.system({ "git", "worktree", "list", "--porcelain" }, { cwd = root, text = true })
      local br_proc = vim.system({ "git", "branch", "--format=%(refname:short)" }, { cwd = root, text = true })
      local wt_res, br_res = wt_proc:wait(), br_proc:wait()
      local items = {}
      local in_worktree = {}
      for _, wt in ipairs(parse_worktrees(wt_res.stdout or "")) do
        in_worktree[wt.branch] = true
        table.insert(items, { text = wt.branch .. " " .. wt.path, path = wt.path, branch = wt.branch })
      end
      -- Also list worktree-less branches so they stay visible and manageable.
      if br_res.code == 0 then
        for _, b in ipairs(vim.split(vim.trim(br_res.stdout or ""), "\n", { trimempty = true })) do
          if not in_worktree[b] then
            table.insert(items, { text = b .. " (no worktree)", branch = b })
          end
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
        open_session_tab(item.path, item.branch)
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
        -- The picker leaves us in normal mode; the name prompt expects typing.
        vim.schedule(function() vim.cmd "startinsert!" end)
      end,
      worktree_delete = function(picker, item)
        if not item then return end
        if not item.path then return delete_branch(root, item.branch, picker) end
        if vim.fs.normalize(item.path) == vim.fs.normalize(root) then
          return vim.notify("Cannot remove the main worktree", vim.log.levels.WARN)
        end
        remove_worktree(root, item.path, item.branch, function(removed)
          -- Deleting the current tab's worktree closes that tab, which can take
          -- the picker down with it.
          if removed and not picker.closed then picker:refresh() end
        end)
      end,
      worktree_refresh = function(picker) picker:refresh() end,
    },
    win = { input = { keys = keys }, list = { keys = keys } },
    -- Small vim.ui.select-style window; the default layout's preview pane is
    -- wasted on this list.
    layout = { preset = "select" },
  }
end

return M
