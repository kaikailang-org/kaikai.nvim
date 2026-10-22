-- LuaSnip snippets for kaikai.
-- Loaded by plugin/kaikai.lua on FileType=kaikai.

local has_luasnip, ls = pcall(require, "luasnip")
if not has_luasnip then
  return
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local snippets = {

  s("fn", fmt(
    "fn {}({}) : {} = {}",
    { i(1, "name"), i(2, "args"), i(3, "Unit"), i(0, "body") }
  )),

  s("fnblock", fmt(
    [[
fn {}({}) : {} {{
  {}
}}
]],
    { i(1, "name"), i(2, "args"), i(3, "Unit"), i(0, "body") }
  )),

  s("pubfn", fmt(
    [[
pub fn {}({}) : {} {{
  {}
}}
]],
    { i(1, "name"), i(2, "args"), i(3, "Unit"), i(0, "body") }
  )),

  s("match", fmt(
    [[
match {} {{
  {} -> {}
  _ -> {}
}}
]],
    { i(1, "scrutinee"), i(2, "Pat"), i(3, "expr"), i(0, "default") }
  )),

  s("match_arm", fmt(
    "{} -> {}",
    { i(1, "Pat"), i(0, "expr") }
  )),

  s("type_sum", fmt(
    [[
type {}
  = {}
  | {}
]],
    { i(1, "Name"), i(2, "VariantA"), i(0, "VariantB") }
  )),

  s("type_record", fmt(
    [[
type {} = {{
  {}: {},
  {}: {},
}}
]],
    { i(1, "Name"), i(2, "field1"), i(3, "Int"), i(4, "field2"), i(0, "String") }
  )),

  s("effect", fmt(
    [[
effect {} {{
  {}({}) : {}
}}
]],
    { i(1, "Name"), i(2, "op"), i(3), i(0, "Unit") }
  )),

  s("protocol", fmt(
    [[
protocol {} {{
  {}(x: Self) : {}
}}
]],
    { i(1, "Name"), i(2, "method"), i(0, "Unit") }
  )),

  s("impl", fmt(
    [[
impl {} for {} {{
  fn {}(x: {}) : {} {{
    {}
  }}
}}
]],
    { i(1, "Protocol"), i(2, "Type"), i(3, "method"), i(4, "Type"), i(5, "Unit"), i(0, "body") }
  )),

  s("handle", fmt(
    [[
handle {{
  {}
}} with {} {{
  {}({}) -> {}
  return({}) -> {}
}}
]],
    { i(1, "body"), i(2, "Effect"), i(3, "op"), i(4, "resume"), i(5, "resume(())"), i(6, "v"), i(0, "v") }
  )),

  s("test", fmt(
    [[
test "{}" {{
  {}
}}
]],
    { i(1, "describes the case"), i(0, "assert true") }
  )),

  s("bench", fmt(
    [[
bench "{}" {{
  {}
}}
]],
    { i(1, "measures the case"), i(0, "body") }
  )),

  s("check", fmt(
    [[
check "{}" with {}: {} {{
  {}
}}
]],
    { i(1, "states the property"), i(2, "n"), i(3, "Int"), i(0, "true") }
  )),

  s("import", fmt(
    "import {}",
    { i(0, "module.path") }
  )),

  s("lambda", fmt(
    "({}) => {}",
    { i(1, "x"), i(0, "x") }
  )),

  s("let", fmt(
    "let {} = {}",
    { i(1, "name"), i(0, "value") }
  )),
}

ls.add_snippets("kaikai", snippets)
