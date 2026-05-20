# kaikai.nvim

Official Neovim plugin for the [kaikai](https://kaikai-lang.org) programming
language: filetype detection, syntax highlighting, tree-sitter, LSP, and
snippets — batteries included.

> Requires Neovim ≥ 0.10 and the `kai` toolchain (≥ 0.76.0).

## Features

| Feature              | How                                                          |
| -------------------- | ------------------------------------------------------------ |
| Filetype detection   | `*.kai` → `filetype=kaikai`                                  |
| Buffer settings      | `commentstring = "# %s"`, 2-space indent, tree-sitter folds  |
| Syntax highlighting  | Tree-sitter (preferred) with regex fallback                  |
| LSP                  | `kai lsp` over stdio via `nvim-lspconfig` or `vim.lsp.start` |
| LSP capabilities     | hover, goto-definition, diagnostics, documentSymbol          |
| Snippets             | LuaSnip (`fn`, `match`, `type_sum`, `effect`, `handle`, …)   |
| Health check         | `:checkhealth kaikai`                                        |

## Install

Make sure the `kai` binary is on your `$PATH`. The easiest way is Homebrew:

```sh
brew install kaikailang-org/kaikai/kaikai
```

### lazy.nvim

```lua
{
  "kaikailang-org/kaikai.nvim",
  ft = "kaikai",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
    "L3MON4D3/LuaSnip",
  },
  opts = {},
}
```

### packer.nvim

```lua
use({
  "kaikailang-org/kaikai.nvim",
  ft = { "kaikai" },
  requires = {
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    require("kaikai").setup({})
  end,
})
```

### Mason

Mason support is **planned**. For now, install the kaikai toolchain via
Homebrew (see above) or build from source — the LSP ships in the same `kai`
binary as the compiler.

## Configuration

All keys are optional; defaults are shown.

```lua
require("kaikai").setup({
  lsp = {
    enabled       = true,
    cmd           = { "kai", "lsp" },
    settings      = {},
    on_attach     = nil,
    capabilities  = nil,
  },
  treesitter = {
    enabled          = true,
    ensure_installed = true,
  },
  snippets = {
    enabled = true,
  },
})
```

### Custom `on_attach` and capabilities

```lua
require("kaikai").setup({
  lsp = {
    on_attach = function(client, bufnr)
      local map = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true })
      end
      map("K",  vim.lsp.buf.hover)
      map("gd", vim.lsp.buf.definition)
      map("gO", vim.lsp.buf.document_symbol)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  },
})
```

### Custom binary path

```lua
require("kaikai").setup({
  lsp = { cmd = { "/opt/kaikai/bin/kai", "lsp" } },
})
```

## LSP capabilities

The `kai lsp` server (v2) implements:

- `textDocument/hover` — inferred type at point
- `textDocument/definition` — goto definition
- `textDocument/publishDiagnostics` — partial (T1–T5 diagnostics)
- `textDocument/documentSymbol` — outline

Completion and signature help are on the roadmap. See the upstream
[`lsp.md`](https://github.com/lnds/kaikai/blob/main/docs/lsp.md) for details.

## Tree-sitter

The plugin registers a parser config for `kaikai` pointing at
[`kaikailang-org/tree-sitter-kaikai`](https://github.com/kaikailang-org/tree-sitter-kaikai).

With `treesitter.ensure_installed = true` (default) the parser is installed on
first load via `:TSInstall! kaikai`. To install manually:

```vim
:TSInstall kaikai
```

If `nvim-treesitter` is not present, the plugin falls back to the regex
syntax shipped in `syntax/kaikai.vim`.

## Snippets

LuaSnip snippets are loaded on the first `FileType=kaikai` event. Triggers:

`fn`, `fnblock`, `pubfn`, `match`, `match_arm`, `type_sum`, `type_record`,
`effect`, `protocol`, `impl`, `handle`, `test`, `import`, `lambda`, `let`.

Disable with `snippets = { enabled = false }`.

## Health

```vim
:checkhealth kaikai
```

Checks the `kai` binary, version, tree-sitter parser, lspconfig, and LuaSnip.

## License

MIT. See [LICENSE](./LICENSE).
