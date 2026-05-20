-- Minimal init for plenary tests. Add the repo to runtimepath and
-- load filetype detection.
local root = vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":p:h:h")
vim.opt.runtimepath:prepend(root)
vim.cmd("runtime! plugin/kaikai.lua")
vim.cmd("filetype plugin indent on")
