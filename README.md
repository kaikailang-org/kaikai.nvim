# kaikai.nvim

Official Neovim plugin for the [kaikai](https://kaikai-lang.org) programming
language: filetype detection, syntax highlighting, tree-sitter, LSP, and
snippets — batteries included.

> Requires Neovim ≥ 0.11 (for `vim.lsp.config`) and the `kai` toolchain
> (≥ 0.76.0). Works on 0.9 / 0.10 with a fallback LSP path.

## Features

| Feature              | How                                                                 |
| -------------------- | ------------------------------------------------------------------- |
| Filetype detection   | `*.kai` → `filetype=kaikai`                                         |
| Buffer settings      | `commentstring = "# %s"`, 2-space indent, tree-sitter folds         |
| Syntax highlighting  | Tree-sitter (bundled parser) with regex fallback                    |
| LSP                  | `kai lsp` over stdio via `vim.lsp.config` (0.11+) or `vim.lsp.start`|
| LSP capabilities     | hover, goto-definition, diagnostics, documentSymbol                 |
| Snippets             | LuaSnip (`fn`, `match`, `type_sum`, `effect`, `handle`, …)          |
| Health check         | `:checkhealth kaikai`                                               |

## Install

Make sure the `kai` binary is on your `$PATH`. The easiest way is Homebrew:

```sh
brew install kaikailang-org/kaikai/kaikai
```

You also need a C compiler (`cc`, `clang`, or `gcc`) in your `$PATH`. It is
used once, on first install, to compile the bundled tree-sitter parser.

### lazy.nvim

```lua
{
  "kaikailang-org/kaikai.nvim",
  ft = "kaikai",
  build = function() require("kaikai.build").build() end,
  init = function()
    -- So `nvim foo.kai` from a cold start triggers the `ft` load.
    vim.filetype.add({ extension = { kai = "kaikai" } })
  end,
  dependencies = { "L3MON4D3/LuaSnip" }, -- optional, only for snippets
  opts = {},
}
```

### packer.nvim

```lua
use({
  "kaikailang-org/kaikai.nvim",
  ft = { "kaikai" },
  run = function() require("kaikai.build").build() end,
  config = function()
    vim.filetype.add({ extension = { kai = "kaikai" } })
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
    enabled = true,
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

The plugin uses Neovim 0.11's `vim.lsp.config` + `vim.lsp.enable` API
(no `require('lspconfig')` framework — that is deprecated upstream). On
Neovim 0.10 it falls back to a `FileType` autocmd that calls
`vim.lsp.start` directly.

## Tree-sitter

The plugin **bundles** its tree-sitter parser. On install (lazy.nvim's
`build` hook or `:KaikaiBuild`) we clone
[`kaikailang-org/tree-sitter-kaikai`](https://github.com/kaikailang-org/tree-sitter-kaikai)
into a temp dir, compile `src/parser.c` with your `cc`, and write the
result to `parser/kaikai.so` inside the plugin directory. Queries are
copied to `queries/kaikai/`.

At runtime we register the parser with Neovim's *native*
`vim.treesitter.language.add` — no `nvim-treesitter` plugin required. This
keeps the plugin compatible with both nvim-treesitter `master` (legacy)
and `main` (new, which dropped runtime parser registration), as well as
users who don't run nvim-treesitter at all.

To rebuild manually after a grammar update:

```vim
:KaikaiBuild
```

If the parser is missing the plugin falls back to the regex
`syntax/kaikai.vim` file.

## Snippets

LuaSnip snippets are loaded on the first `FileType=kaikai` event. Triggers:

`fn`, `fnblock`, `pubfn`, `match`, `match_arm`, `type_sum`, `type_record`,
`effect`, `protocol`, `impl`, `handle`, `test`, `import`, `lambda`, `let`.

Disable with `snippets = { enabled = false }`.

## Health

```vim
:checkhealth kaikai
```

Checks the Neovim version, `kai` binary, parser build state, C compiler
availability, and LuaSnip.

## License

MIT. See [LICENSE](./LICENSE).
