local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then
    return
  end

  local cmd = opts.cmd or { "kai", "lsp" }

  local has_lspconfig, lspconfig = pcall(require, "lspconfig")
  if has_lspconfig then
    local configs = require("lspconfig.configs")
    if not configs.kaikai then
      configs.kaikai = {
        default_config = {
          cmd = cmd,
          filetypes = { "kaikai" },
          root_dir = lspconfig.util.root_pattern("kai.toml", ".git"),
          single_file_support = true,
          settings = opts.settings or {},
        },
        docs = {
          description = "kaikai Language Server (https://kaikai-lang.org)",
        },
      }
    end

    lspconfig.kaikai.setup({
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
      settings = opts.settings or {},
    })
    return
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "kaikai",
    group = vim.api.nvim_create_augroup("KaikaiLsp", { clear = true }),
    callback = function(args)
      local fname = vim.api.nvim_buf_get_name(args.buf)
      local roots = vim.fs.find({ "kai.toml", ".git" }, {
        upward = true,
        path = fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd(),
      })
      local root_dir = roots[1] and vim.fs.dirname(roots[1]) or vim.fn.getcwd()

      vim.lsp.start({
        name = "kaikai",
        cmd = cmd,
        root_dir = root_dir,
        settings = opts.settings or {},
        on_attach = opts.on_attach,
        capabilities = opts.capabilities,
      })
    end,
  })
end

return M
