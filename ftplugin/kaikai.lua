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

local ok_ts, _ = pcall(require, "nvim-treesitter.parsers")
local has_ts_parser = false
if ok_ts then
  local parsers = require("nvim-treesitter.parsers")
  if parsers.has_parser and parsers.has_parser("kaikai") then
    has_ts_parser = true
  end
end

if has_ts_parser then
  wo.foldmethod = "expr"
  wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
else
  wo.foldmethod = "indent"
end
wo.foldenable = false

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | ") or "")
  .. "setlocal commentstring< comments< expandtab< shiftwidth< softtabstop< tabstop< suffixesadd< foldmethod< foldexpr< foldenable<"
