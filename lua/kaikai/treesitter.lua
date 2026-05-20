-- Tree-sitter integration for kaikai.
--
-- The kaikai grammar lives at github.com/kaikailang-org/tree-sitter-kaikai.
-- Because both `nvim-treesitter` master and `main` branches handle custom
-- grammars differently — and `main` no longer supports runtime registration —
-- this module bundles the parser inside the plugin tree and registers it
-- with Neovim's *native* `vim.treesitter` API. That works on any Nvim 0.9+
-- regardless of which nvim-treesitter branch (if any) the user runs.
--
-- The parser shared object is built by the plugin's `build` hook (see
-- README and the `build.lua` helper). It lives at:
--   <plugin_dir>/parser/kaikai.so          (Unix)
--   <plugin_dir>/parser/kaikai.dylib       (macOS, optional)
-- Queries live at:
--   <plugin_dir>/queries/kaikai/*.scm
-- which is already on Neovim's default treesitter query search path because
-- the plugin dir is on runtimepath.

local M = {}

local function plugin_root()
  local source = debug.getinfo(1, "S").source
  -- source starts with "@" for files. Strip the prefix.
  local path = source:sub(2)
  -- this file is at <root>/lua/kaikai/treesitter.lua — go up 3.
  return vim.fs.normalize(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(path))))
end

local function parser_path()
  local root = plugin_root()
  -- Neovim looks for parsers named "<lang>.so" on every platform (the
  -- ".so" extension is hard-coded in libuv's loader regardless of host).
  return vim.fs.joinpath(root, "parser", "kaikai.so")
end

function M.is_parser_built()
  return vim.fn.filereadable(parser_path()) == 1
end

local registered = false

function M.register()
  if registered then
    return true
  end
  local path = parser_path()
  if vim.fn.filereadable(path) ~= 1 then
    return false
  end
  -- Map the parser file + tell Neovim the filetype association.
  vim.treesitter.language.add("kaikai", { path = path })
  -- Some Neovim versions also need an explicit filetype-to-language map.
  if vim.treesitter.language.register then
    pcall(vim.treesitter.language.register, "kaikai", "kaikai")
  end
  registered = true
  return true
end

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then
    return
  end

  if not M.register() then
    -- Parser not built yet. The build hook should produce it; warn once.
    vim.schedule(function()
      vim.notify(
        "kaikai.nvim: tree-sitter parser not built. Run `:Lazy build kaikai.nvim` "
          .. "or compile manually (see README).",
        vim.log.levels.WARN
      )
    end)
  end
end

-- Exposed so external callers (e.g. a `:checkhealth` shim) can inspect.
M.plugin_root = plugin_root
M.parser_path = parser_path

return M
