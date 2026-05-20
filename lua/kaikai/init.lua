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

  -- :KaikaiBuild — (re)build the bundled tree-sitter parser. lazy.nvim
  -- also wires this via its `build` hook, but the command is useful for
  -- manual rebuilds without re-running the package manager.
  vim.api.nvim_create_user_command("KaikaiBuild", function()
    require("kaikai.build").build()
  end, { desc = "Build the bundled tree-sitter parser for kaikai." })

  -- :KaikaiRestart — stop the running `kai lsp` client(s) for the
  -- current session. The FileType autocmd installed by
  -- `vim.lsp.enable('kaikai')` re-attaches on the next buffer event,
  -- so the server effectively restarts when you re-edit / re-open
  -- the buffer.
  --
  -- Useful after upgrading the `kai` binary (`brew upgrade kaikai`)
  -- without quitting Neovim, or to recover from a server that has
  -- desynced its document store.
  vim.api.nvim_create_user_command("KaikaiRestart", function()
    local clients = vim.lsp.get_clients({ name = "kaikai" })
    if #clients == 0 then
      vim.notify("kaikai.nvim: no running `kai lsp` client to restart.", vim.log.levels.INFO)
      return
    end
    for _, c in ipairs(clients) do
      c:stop(true) -- force = true, terminate immediately
    end
    -- Re-attach to any open kaikai buffers. The FileType autocmd
    -- doesn't refire on its own, so we kick `vim.lsp.start` manually
    -- using the registered `vim.lsp.config('kaikai', ...)` defaults.
    vim.defer_fn(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "kaikai" then
          vim.api.nvim_buf_call(buf, function()
            -- Re-trigger the FileType autocmd so `vim.lsp.enable`'s
            -- internal handler runs again on this buffer.
            vim.cmd("doautocmd FileType")
          end)
        end
      end
      vim.notify("kaikai.nvim: restarted " .. #clients .. " client(s).", vim.log.levels.INFO)
    end, 200) -- give the OS a moment to reap the stopped process
  end, { desc = "Restart the kaikai language server." })
end

return M
