if vim.g.loaded_kaikai then
  return
end
vim.g.loaded_kaikai = true

local group = vim.api.nvim_create_augroup("KaikaiSnippets", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "kaikai",
  once = true,
  callback = function()
    local config = (require("kaikai").config or {}).snippets
    if config and config.enabled == false then
      return
    end

    local has_luasnip = pcall(require, "luasnip")
    if not has_luasnip then
      return
    end

    local plugin_root = debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. ".."
    local snippet_file = plugin_root .. "/snippets/kaikai.lua"
    if vim.fn.filereadable(snippet_file) == 1 then
      pcall(dofile, snippet_file)
    end
  end,
})
