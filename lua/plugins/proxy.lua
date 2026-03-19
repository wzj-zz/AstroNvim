local proxy_url = "http://127.0.0.1:1080"
local no_proxy = "localhost,127.0.0.1"

local function proxy_enabled()
  return vim.env.HTTPS_PROXY == proxy_url or vim.env.HTTP_PROXY == proxy_url or vim.env.ALL_PROXY == proxy_url
end

local function toggle_proxy()
  local enabled

  if proxy_enabled() then
    vim.env.HTTPS_PROXY = nil
    vim.env.HTTP_PROXY = nil
    vim.env.ALL_PROXY = nil
    vim.env.NO_PROXY = no_proxy
    enabled = false
  else
    vim.env.HTTPS_PROXY = proxy_url
    vim.env.HTTP_PROXY = proxy_url
    vim.env.ALL_PROXY = proxy_url
    vim.env.NO_PROXY = no_proxy
    enabled = true
  end

  local status = enabled and ("Proxy enabled: " .. proxy_url) or "Proxy disabled"
  vim.notify(status, vim.log.levels.INFO)
end

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}

    opts.mappings.n["<Leader>P"] = {
      toggle_proxy,
      desc = "Toggle proxy",
    }
  end,
}
