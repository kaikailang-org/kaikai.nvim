if vim.b.did_ftplugin_kaikai then
  return
end
vim.b.did_ftplugin_kaikai = true

local bo = vim.bo
local wo = vim.wo

bo.commentstring = "# %s"
bo.comments = ":#"

bo.expandtab = true
bo.shiftwidth = 2
bo.softtabstop = 2
bo.tabstop = 2

bo.suffixesadd = ".kai"

-- Ensure the parser is registered with Neovim's native tree-sitter
-- before we ask for highlighting / folding. `register()` is a no-op if
-- the parser shared object is not built yet (the user gets a warning
-- from setup()).
local ts_ok, ts = pcall(require, "kaikai.treesitter")
local has_parser = ts_ok and ts.register()

if has_parser then
  -- Start tree-sitter highlighting for this buffer. This is the
  -- Neovim 0.9+ native path — no nvim-treesitter dependency.
  pcall(vim.treesitter.start, 0, "kaikai")
  wo.foldmethod = "expr"
  wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
else
  -- Fall back to the regex syntax file shipped at syntax/kaikai.vim.
  -- It runs automatically when filetype=kaikai and no tree-sitter
  -- parser is active. Indent-based folding is the only sensible
  -- fallback without a real AST.
  wo.foldmethod = "indent"
end
wo.foldenable = false

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | ") or "")
  .. "setlocal commentstring< comments< expandtab< shiftwidth< softtabstop< tabstop< suffixesadd< foldmethod< foldexpr< foldenable<"
