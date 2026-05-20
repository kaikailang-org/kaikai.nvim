local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.enabled == false then
    return
  end

  local has_ts, parsers = pcall(require, "nvim-treesitter.parsers")
  if not has_ts then
    return
  end

  local parser_config = parsers.get_parser_configs()
  parser_config.kaikai = {
    install_info = {
      url = "https://github.com/kaikailang-org/tree-sitter-kaikai",
      files = { "src/parser.c" },
      branch = "main",
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "kaikai",
  }

  if opts.ensure_installed then
    local already = parsers.has_parser and parsers.has_parser("kaikai")
    if not already then
      pcall(vim.cmd, "TSInstall! kaikai")
    end
  end
end

return M
