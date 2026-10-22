local M = {}

local function git(cmd, cwd, cb)
  vim.system(vim.list_extend({ "git" }, cmd), { cwd = cwd, text = true }, function(res)
    vim.schedule(function() cb(res.code == 0, res.stdout or "", res.stderr or "") end)
  end)
end

local function sanitize_branch(name)
  return (name:gsub("%s+", "-"):gsub("[~^:%?*%[%]\\]", ""):gsub("^[-.]+", ""):gsub("[%.%-]+$", ""))
end

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

local function norm(path) return vim.fs.normalize(path):lower() end

local function tab_directory(tab)
  local d = tab.bound_directory
  if not d then
    local s = tab.active_session
    d = s and (s.location and s.location.directory or s.directory)
  end
  return type(d) == "string" and norm(d) or nil
end

local function open_session_tab(worktree_path, branch)
  require("opencode.promise").async(function()
    local session_tabs = require "opencode.state.session_tabs"
    local session_runtime = require "opencode.services.session_runtime"
    local target = norm(worktree_path)
    for _, tab in ipairs(session_tabs.list()) do
      if tab_directory(tab) == target then
        session_runtime.switch_session_tab(tab.id):await()
        return vim.notify("Worktree session ready: " .. branch, vim.log.levels.INFO)
      end
    end
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

function M.open_worktree(root, branch)
  local path = root .. "/.worktrees/" .. branch
  if vim.uv.fs_stat(path .. "/.git") then return open_session_tab(path, branch) end
  if vim.uv.fs_stat(path) then vim.fn.delete(path, "rf") end

  exclude_worktrees_dir(root)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }, root, function(exists)
    local cmd = exists and { "worktree", "add", path, branch } or { "worktree", "add", "-b", branch, path }
    git(cmd, root, function(ok, _, stderr)
      if not ok then return vim.notify("git worktree add failed: " .. stderr, vim.log.levels.ERROR) end
      open_session_tab(path, branch)
    end)
  end)
end

local function git_sync(cmd, cwd)
  local res = vim.system(vim.list_extend({ "git" }, cmd), { cwd = cwd, text = true }):wait()
  return res.code == 0, res.stdout or ""
end

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

local function close_tabs_for_dir(dir)
  local session_tabs = require "opencode.state.session_tabs"
  local session_runtime = require "opencode.services.session_runtime"
  local target = norm(dir)
  for _, tab in ipairs(session_tabs.list()) do
    if tab_directory(tab) == target then
      if tab.id == session_tabs.active_id() then
        local fallback
        for _, other in ipairs(session_tabs.list()) do
          if other.id ~= tab.id and tab_directory(other) ~= target then
            fallback = other
            break
          end
        end
        if fallback then pcall(function() session_runtime.switch_session_tab(fallback.id):await() end) end
        tab.bound_directory = nil
      end
      session_runtime.close_session_tab(tab.id)
    end
  end
end

local function remove_worktree(root, path, branch, cb)
  close_tabs_for_dir(path)
  git({ "worktree", "remove", "--force", path }, root, function(ok, _, stderr)
    if not ok then
      if stderr:find "is not a working tree" then
        if vim.fn.delete(path, "rf") ~= 0 then
          vim.notify("Failed to delete leftover directory: " .. path, vim.log.levels.ERROR)
          return cb(false)
        end
      else
        vim.notify("git worktree remove failed: " .. stderr, vim.log.levels.ERROR)
        return cb(false)
      end
    end
    if branch == "(detached)" then return cb(true) end
    git({ "branch", "-D", branch }, root, function() cb(true) end)
  end)
end

local function delete_branch(root, branch, picker)
  git({ "branch", "-D", branch }, root, function(ok, _, stderr)
    if not ok then return vim.notify("git branch -D failed: " .. stderr, vim.log.levels.ERROR) end
    vim.notify("Deleted branch " .. branch, vim.log.levels.INFO)
    if not picker.closed then picker:refresh() end
  end)
end

function M.pick()
  local base = require("opencode.state").current_cwd or vim.fn.getcwd()
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
      local wt_proc = vim.system({ "git", "worktree", "list", "--porcelain" }, { cwd = root, text = true })
      local br_proc = vim.system({ "git", "branch", "--format=%(refname:short)" }, { cwd = root, text = true })
      local wt_res, br_res = wt_proc:wait(), br_proc:wait()
      local items = {}
      local in_worktree = {}
      for i, wt in ipairs(parse_worktrees(wt_res.stdout or "")) do
        in_worktree[wt.branch] = true
        table.insert(items, { text = wt.branch .. " " .. wt.path, path = wt.path, branch = wt.branch, is_main = i == 1 })
      end
      if br_res.code == 0 then
        for _, b in ipairs(vim.split(vim.trim(br_res.stdout or ""), "\n", { trimempty = true })) do
          if not in_worktree[b] then table.insert(items, { text = b .. " (no worktree)", branch = b }) end
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
        vim.schedule(function() vim.cmd "startinsert!" end)
      end,
      worktree_delete = function(picker, item)
        if not item then return end
        if not item.path then return delete_branch(root, item.branch, picker) end
        if item.is_main then return vim.notify("Cannot remove the main worktree", vim.log.levels.WARN) end
        remove_worktree(root, item.path, item.branch, function(removed)
          if removed and not picker.closed then picker:refresh() end
        end)
      end,
      worktree_refresh = function(picker) picker:refresh() end,
    },
    win = { input = { keys = keys }, list = { keys = keys } },
    layout = { preset = "select" },
  }
end

return M
