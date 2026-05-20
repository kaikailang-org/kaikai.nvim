-- plenary-based tests. Run with:
--   nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

local function with_tmp_buf(name, body)
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("doautocmd BufRead " .. name)
  end)
  body(buf)
  vim.api.nvim_buf_delete(buf, { force = true })
end

describe("kaikai.nvim", function()
  it("loads without error", function()
    assert.has_no.errors(function()
      require("kaikai")
    end)
  end)

  it("setup() runs with empty opts", function()
    assert.has_no.errors(function()
      require("kaikai").setup({})
    end)
  end)

  it("setup() runs with all opts disabled", function()
    assert.has_no.errors(function()
      require("kaikai").setup({
        lsp = { enabled = false },
        treesitter = { enabled = false },
        snippets = { enabled = false },
      })
    end)
  end)

  it("detects *.kai as filetype=kaikai", function()
    with_tmp_buf("/tmp/example.kai", function(buf)
      assert.are.equal("kaikai", vim.bo[buf].filetype)
    end)
  end)

  it("ftplugin sets commentstring and shiftwidth", function()
    with_tmp_buf("/tmp/example2.kai", function(buf)
      assert.are.equal("# %s", vim.bo[buf].commentstring)
      assert.are.equal(2, vim.bo[buf].shiftwidth)
      assert.is_true(vim.bo[buf].expandtab)
    end)
  end)
end)
