local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error_ = health.error or health.report_error
local info = health.info or health.report_info

local MIN_KAI_VERSION = "0.76.0"

local function parse_version(s)
  local major, minor, patch = s:match("(%d+)%.(%d+)%.(%d+)")
  if not major then
    return nil
  end
  return { tonumber(major), tonumber(minor), tonumber(patch) }
end

local function version_ge(a, b)
  for i = 1, 3 do
    if a[i] > b[i] then return true end
    if a[i] < b[i] then return false end
  end
  return true
end

local function check_kai_binary()
  start("kaikai: compiler / language server")

  if vim.fn.executable("kai") ~= 1 then
    error_("`kai` not found on $PATH", {
      "Install kaikai: `brew install kaikailang-org/kaikai/kaikai`",
      "Or build from source: https://github.com/lnds/kaikai",
    })
    return
  end

  ok("`kai` found at " .. vim.fn.exepath("kai"))

  local out = vim.fn.system({ "kai", "--version" })
  if vim.v.shell_error ~= 0 then
    warn("`kai --version` exited non-zero")
    return
  end

  local found = out:match("(%d+%.%d+%.%d+)")
  if not found then
    warn("could not parse `kai --version` output: " .. vim.trim(out))
    return
  end

  local cur = parse_version(found)
  local min = parse_version(MIN_KAI_VERSION)
  if cur and min and version_ge(cur, min) then
    ok("kai version " .. found .. " (>= " .. MIN_KAI_VERSION .. ")")
  else
    warn(
      "kai version " .. found .. " is older than recommended " .. MIN_KAI_VERSION,
      { "Upgrade: `brew upgrade kaikai`" }
    )
  end
end

local function check_treesitter()
  start("kaikai: tree-sitter parser")

  local has_ts, parsers = pcall(require, "nvim-treesitter.parsers")
  if not has_ts then
    info("nvim-treesitter is not installed (optional, fallback to regex syntax)")
    return
  end

  if parsers.has_parser and parsers.has_parser("kaikai") then
    ok("tree-sitter parser `kaikai` is installed")
  else
    warn("tree-sitter parser `kaikai` is not installed", {
      "Run `:TSInstall kaikai`",
      "Grammar: https://github.com/kaikailang-org/tree-sitter-kaikai",
    })
  end
end

local function check_snippets()
  start("kaikai: snippets")

  local has_luasnip = pcall(require, "luasnip")
  if has_luasnip then
    ok("LuaSnip is available")
  else
    info("LuaSnip is not installed (optional, required only for built-in snippets)")
  end
end

local function check_lspconfig()
  start("kaikai: lspconfig")

  if pcall(require, "lspconfig") then
    ok("nvim-lspconfig is available")
  else
    info("nvim-lspconfig is not installed (optional, plugin falls back to vim.lsp.start)")
  end
end

function M.check()
  check_kai_binary()
  check_lspconfig()
  check_treesitter()
  check_snippets()
end

return M
