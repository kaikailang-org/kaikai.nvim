-- LSP wiring for kaikai.
--
-- Targets Neovim 0.11+ where `vim.lsp.config` is the canonical way to
-- define a server config and `vim.lsp.enable` activates it for its
-- declared filetypes. The legacy `require('lspconfig').kaikai.setup({})`
-- path is deprecated upstream (see nvim-lspconfig issue #3693) and is
-- not used here. We fall back to `vim.lsp.start` in a FileType autocmd
-- on Nvim 0.10.

local M = {}

local function root_marker_dir(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr or 0)
  local start = (fname ~= "" and vim.fs.dirname(fname)) or vim.fn.getcwd()
  local hits = vim.fs.find({ "kai.toml", ".git" }, { upward = true, path = start })
  if hits and hits[1] then
    return vim.fs.dirname(hits[1])
  end
  return start
end

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then
    return
  end

  local cmd = opts.cmd or { "kai", "lsp" }

  -- Nvim 0.11+ canonical path.
  if vim.lsp.config and vim.lsp.enable then
    vim.lsp.config("kaikai", {
      cmd = cmd,
      filetypes = { "kaikai" },
      root_dir = function(bufnr, on_dir)
        on_dir(root_marker_dir(bufnr))
      end,
      settings = opts.settings or {},
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
    })
    vim.lsp.enable("kaikai")
    return
  end

  -- Nvim 0.10 fallback. Deliberately does NOT use `require('lspconfig')`
  -- — that framework is being removed upstream.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "kaikai",
    group = vim.api.nvim_create_augroup("KaikaiLsp", { clear = true }),
    callback = function(args)
      vim.lsp.start({
        name = "kaikai",
        cmd = cmd,
        root_dir = root_marker_dir(args.buf),
        settings = opts.settings or {},
        on_attach = opts.on_attach,
        capabilities = opts.capabilities,
      })
    end,
  })
end

return M
