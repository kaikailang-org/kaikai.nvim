" Vim syntax file
" Language:     kaikai
" Maintainer:   kaikai project (https://kaikai-lang.org)
" Filenames:    *.kai
"
" Heuristic-based highlighting tracking the stage 2 lexer in
" stage2/compiler/lex.kai. There is no semantic information: type vs.
" constructor vs. effect-label is approximated by capitalisation.
" A real LSP-driven highlighter is scheduled for milestone m17.

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" --------------------------------------------------------------------
" Comments  ('#' to end of line; '#[' opens an attribute instead)
" --------------------------------------------------------------------
syn region  kaikaiAttribute matchgroup=kaikaiAttribute start="#\[" end="\]"
      \ contains=kaikaiAttrBrackets,kaikaiConstructor,kaikaiNumber,
      \ kaikaiString,kaikaiTripleString,kaikaiChar
syn region  kaikaiAttrBrackets contained transparent start="\[" end="\]"
      \ contains=kaikaiAttrBrackets,kaikaiConstructor,kaikaiNumber,
      \ kaikaiString,kaikaiTripleString,kaikaiChar
syn match   kaikaiComment   "#\[\@!.*$" contains=kaikaiTodo
syn keyword kaikaiTodo      contained TODO FIXME XXX NOTE HACK

" --------------------------------------------------------------------
" Keywords (kept in sync with stage2/compiler/lex.kai keyword_at)
" --------------------------------------------------------------------
syn keyword kaikaiKeyword
      \ and as assert axiom bench case check const effect else ensures
      \ extern false fn for handle if impl import lazy let match
      \ not or priv protocol pub requires test theory true type
      \ unit use var when where with

syn keyword kaikaiBoolean   true false

" `pub(pkg)`: `pkg` is a keyword only inside the visibility parens.
syn match   kaikaiVisibility "\(\<pub\s*(\s*\)\@<=pkg\ze\s*)"

" 'todo!' is a single token; mark it as a runtime escape.
syn match   kaikaiTodoBang  "\<todo!"

" --------------------------------------------------------------------
" Built-in primitives and well-known stdlib type names
" --------------------------------------------------------------------
syn keyword kaikaiType
      \ Int Real Bool String Char Unit Nothing Self
      \ Byte Int32 UInt32 UInt64 Int128 BigInt Complex
      \ Option Result List Pair Map Set Seq Stack Queue Array Bytes
      \ Decimal Money Fiber Pid Regex Match Capture
      \ WallTime Instant Duration

" --------------------------------------------------------------------
" Built-in effect labels (stdlib catalog)
" --------------------------------------------------------------------
syn keyword kaikaiEffect
      \ Console Stdin Stdout Stderr File Env State
      \ Reader Writer Actor Spawn Cancel Mutable
      \ Fail Random Time Clock Ffi Process Signal Log
      \ SecureRandom Link Monitor Yield Trace
      \ NetTcp NetUdp NetUnix NetDns

" --------------------------------------------------------------------
" Constructors / capitalised callees and bare type names
" Heuristic: any identifier starting with an uppercase letter that
" isn't already a known type/effect highlights as a constructor.
" --------------------------------------------------------------------
syn match   kaikaiConstructor "\<[A-Z][A-Za-z0-9_]*\>"

" --------------------------------------------------------------------
" Numbers
"   Integers:  123, 1_000_000, 0xFF, 0b1010
"   Reals:     1.0, 1.5e-3, 2E10
"   Suffixes:  i32 u32 u64 i128 u8 (fixed width, integers only),
"              n (BigInt), d (Decimal), i (Complex)
"   Optional unit-of-measure suffix is matched separately to keep the
"   numeric literal contiguous (the '<' is matched by an operator rule).
" --------------------------------------------------------------------
syn match   kaikaiNumber    "\<\d[0-9_]*\(\.\d[0-9_]*\)\?\([eE][+-]\?\d\+\)\?[di]\?\>"
syn match   kaikaiNumber    "\<\d[0-9_]*\(i32\|u32\|u64\|i128\|u8\|n\)\>"
syn match   kaikaiNumber    "\<0[xX][0-9a-fA-F_]\+\(i32\|u32\|u64\|i128\|u8\)\?\>"
syn match   kaikaiNumber    "\<0[bB][01_]\+\(i32\|u32\|u64\|i128\|u8\)\?\>"

" --------------------------------------------------------------------
" Strings (single-line "..." and triple-quoted """...""")
"   Both support backslash escapes and #{...} interpolation.
" --------------------------------------------------------------------
syn match   kaikaiBadEscape contained "\\."
syn match   kaikaiEscape    contained "\\\([\\\"'nrt0]\|x\x\{2}\|u{\x\{1,6}}\)"
syn region  kaikaiInterpBraces contained transparent start="{" end="}"
      \ contains=@kaikaiInterpItems
syn cluster kaikaiInterpItems
      \ contains=kaikaiInterpBraces,kaikaiNumber,kaikaiKeyword,kaikaiBoolean,
      \ kaikaiType,kaikaiEffect,kaikaiConstructor,kaikaiOperator,kaikaiPipe,
      \ kaikaiString,kaikaiTripleString,kaikaiChar,kaikaiHole
syn region  kaikaiInterp    contained matchgroup=kaikaiInterpDelim
      \ start="#{" end="}"
      \ contains=kaikaiFormatSpec,@kaikaiInterpItems
syn region  kaikaiTripleString start=+"""+ end=+"""+
      \ contains=kaikaiBadEscape,kaikaiEscape,kaikaiInterp
syn region  kaikaiString    start=+"\(""\)\@!+ skip=+\\.+ end=+"+ oneline
      \ contains=kaikaiBadEscape,kaikaiEscape,kaikaiInterp

" --------------------------------------------------------------------
" Char literals: 'c', '\n', '\x41', '\u{1F600}'
" --------------------------------------------------------------------
syn match   kaikaiChar      "'\(\\\(u{\x\{1,6}}\|x\x\{2}\|.\)\|[^\\']\)'"

" --------------------------------------------------------------------
" Regex sigil: ~r/pattern/flags
" --------------------------------------------------------------------
syn match   kaikaiRegex     "\~r/\(\\.\|[^/\\]\)*/[a-z]*"

" --------------------------------------------------------------------
" Operators and punctuation
" --------------------------------------------------------------------
syn match   kaikaiOperator  "->\|=>\||>\||?\||!\|??\|:=\|==\|!=\|<=\|>=\|||\|++\|\.\.\.\|\.\."
syn match   kaikaiOperator  "[-+*/%<>=!?^|@:&$]"

" Pipe character on its own (sum-type alternation / handle clause).
syn match   kaikaiPipe      "|"

" Defined after the operators so they win at the same column.
" --------------------------------------------------------------------
" Typed holes: ?  and ?name  (not the `?` of `??` or `|?`)
" --------------------------------------------------------------------
syn match   kaikaiHole      "\([?|]\)\@<!??\@!\([a-zA-Z_][a-zA-Z0-9_]*\)\="

" A format spec closes an interpolation: `#{n:05}`, `#{s:<6}`, `#{r:8.2}`.
syn match   kaikaiFormatSpec contained ":[<>^]\=\d*\(\.\d\+\)\=\ze}"

" --------------------------------------------------------------------
" fn / type / effect declaration heads — make the bound name stand out
" --------------------------------------------------------------------
syn match   kaikaiFnName    "\(\<fn\s\+\)\@<=[a-z_][A-Za-z0-9_]*"
syn match   kaikaiTypeDecl  "\(\<\(type\|effect\|protocol\|impl\|kind\|opaque\)\s\+\)\@<=[A-Z][A-Za-z0-9_]*"

" --------------------------------------------------------------------
" Highlight links
" --------------------------------------------------------------------
hi def link kaikaiComment      Comment
hi def link kaikaiTodo         Todo
hi def link kaikaiAttribute    PreProc
hi def link kaikaiKeyword      Keyword
hi def link kaikaiBoolean      Boolean
hi def link kaikaiTodoBang     Special
hi def link kaikaiType         Type
hi def link kaikaiEffect       StorageClass
hi def link kaikaiConstructor  Identifier
hi def link kaikaiNumber       Number
hi def link kaikaiString       String
hi def link kaikaiTripleString String
hi def link kaikaiEscape       SpecialChar
hi def link kaikaiBadEscape    Error
hi def link kaikaiFormatSpec   Special
hi def link kaikaiVisibility   Keyword
hi def link kaikaiInterpDelim  Special
hi def link kaikaiChar         Character
hi def link kaikaiRegex        String
hi def link kaikaiHole         Special
hi def link kaikaiOperator     Operator
hi def link kaikaiPipe         Operator
hi def link kaikaiFnName       Function
hi def link kaikaiTypeDecl     Type

let b:current_syntax = "kaikai"

let &cpo = s:cpo_save
unlet s:cpo_save
