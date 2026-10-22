-- Build helper for the bundled tree-sitter parser.
--
-- Invoked from lazy.nvim's `build` hook (see README) and from the
-- :KaikaiBuild user command. Clones tree-sitter-kaikai into a temp
-- directory, compiles src/parser.c with the user's C compiler, and
-- writes the resulting shared library into <plugin_root>/parser/kaikai.so.
--
-- We deliberately compile to "kaikai.so" on every platform — Neovim's
-- tree-sitter loader hard-codes that extension regardless of host (the
-- .so suffix is a soname, not a Mach-O / ELF marker).

local M = {}

local GRAMMAR_REPO = "https://github.com/kaikailang-org/tree-sitter-kaikai.git"
local GRAMMAR_REF = "main"

local function plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fs.normalize(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source))))
end

local function parser_dir()
  return vim.fs.joinpath(plugin_root(), "parser")
end

local function out_path()
  return vim.fs.joinpath(parser_dir(), "kaikai.so")
end

local function queries_target_dir()
  return vim.fs.joinpath(plugin_root(), "queries", "kaikai")
end

local function run(cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
  return result.code == 0, (result.stdout or "") .. (result.stderr or "")
end

local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

local function pick_cc()
  -- Honor $CC, fall back to common compilers.
  local cc = vim.env.CC
  if cc and cc ~= "" then
    return cc
  end
  for _, candidate in ipairs({ "cc", "clang", "gcc" }) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

function M.build(opts)
  opts = opts or {}
  local verbose = opts.verbose ~= false

  local cc = pick_cc()
  if not cc then
    error("kaikai.nvim build: no C compiler found in PATH (set $CC or install cc / clang / gcc).")
  end

  local tmp = vim.fn.tempname()
  ensure_dir(tmp)
  if verbose then
    vim.notify("kaikai.nvim: cloning grammar into " .. tmp, vim.log.levels.INFO)
  end

  local ok, out = run({ "git", "clone", "--depth=1", "--branch=" .. GRAMMAR_REF, GRAMMAR_REPO, tmp })
  if not ok then
    error("kaikai.nvim build: git clone failed:\n" .. out)
  end

  local parser_src = vim.fs.joinpath(tmp, "src", "parser.c")
  if vim.fn.filereadable(parser_src) ~= 1 then
    error("kaikai.nvim build: " .. parser_src .. " missing in the grammar checkout.")
  end

  ensure_dir(parser_dir())
  local target = out_path()
  if verbose then
    vim.notify("kaikai.nvim: compiling parser to " .. target, vim.log.levels.INFO)
  end

  -- Flags follow tree-sitter-cli's `build --output`:
  --   -O2 -fPIC -shared -I<src> src/parser.c [src/scanner.c] -o kaikai.so
  -- The external scanner is compiled in when the grammar has one; the
  -- parser references its symbols and fails to link or load without it.
  -- On macOS we still emit a `.so` (see header comment).
  local args = {
    cc,
    "-O2",
    "-fPIC",
    "-shared",
    "-I",
    vim.fs.joinpath(tmp, "src"),
    parser_src,
  }
  local scanner_src = vim.fs.joinpath(tmp, "src", "scanner.c")
  if vim.fn.filereadable(scanner_src) == 1 then
    table.insert(args, scanner_src)
  end
  vim.list_extend(args, { "-o", target })
  ok, out = run(args)
  if not ok then
    error("kaikai.nvim build: compilation failed:\n" .. out)
  end

  -- Copy queries from the grammar into the plugin's queries/kaikai/.
  -- These ride the plugin's runtimepath entry, so Neovim picks them up
  -- automatically once the language is registered.
  local src_queries = vim.fs.joinpath(tmp, "queries")
  if vim.fn.isdirectory(src_queries) == 1 then
    ensure_dir(queries_target_dir())
    for name, type_ in vim.fs.dir(src_queries) do
      if type_ == "file" and name:match("%.scm$") then
        local src = vim.fs.joinpath(src_queries, name)
        local dst = vim.fs.joinpath(queries_target_dir(), name)
        local content = table.concat(vim.fn.readfile(src, "b"), "\n")
        vim.fn.writefile(vim.fn.split(content, "\n", true), dst, "b")
      end
    end
    if verbose then
      vim.notify("kaikai.nvim: queries copied to " .. queries_target_dir(), vim.log.levels.INFO)
    end
  end

  -- Best-effort cleanup of the temp clone.
  pcall(vim.fn.delete, tmp, "rf")

  if verbose then
    vim.notify("kaikai.nvim: build complete (" .. target .. ")", vim.log.levels.INFO)
  end
  return target
end

return M
