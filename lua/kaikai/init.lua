local M = {}

local defaults = {
  lsp = {
    enabled = true,
    cmd = { "kai", "lsp" },
    settings = {},
    on_attach = nil,
    capabilities = nil,
  },
  treesitter = {
    enabled = true,
    ensure_installed = true,
  },
  snippets = {
    enabled = true,
  },
}

M.config = vim.deepcopy(defaults)

local function deep_merge(dst, src)
  for k, v in pairs(src or {}) do
    if type(v) == "table" and type(dst[k]) == "table" then
      deep_merge(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

function M.setup(opts)
  M.config = deep_merge(vim.deepcopy(defaults), opts or {})

  require("kaikai.treesitter").setup(M.config.treesitter)
  require("kaikai.lsp").setup(M.config.lsp)

  -- snippets are loaded lazily via plugin/kaikai.lua (FileType autocmd)
  -- to keep startup cheap; nothing to do here.
end

return M
