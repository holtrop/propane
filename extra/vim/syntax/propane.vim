" Vim syntax file for Propane
" Language: propane
" Maintainer: Josh Holtrop
" URL: https://github.com/holtrop/propane

if exists("b:current_syntax")
  finish
endif

" Guess the language of the user code blocks from their contents so that the
" matching syntax file can be included below. b:propane_subtype may also be set
" before this file is sourced to select the language explicitly.
if !exists("b:propane_subtype")
  " Rust markers. Each keyword requires the syntax that follows it in Rust so
  " that a plain identifier of the same name in another language does not match
  " (`int fn = 3;' in C, for example). Type names are only accepted within a
  " `ptype' statement for the same reason.
  let s:rust = '\<let\s\+\%(mut\s\+\)\?\w'
  let s:rust .= '\|\<fn\s\+\w\+\s*('
  let s:rust .= '\|&mut\>\|\<pub\s\+\w\|\<impl\s\+\w'
  let s:rust .= '\|#\[\|\<use\s\+\%(std\|core\)::'
  let s:rust .= '\|\<ptype\>[^;]*\<\%(isize\|usize\|i8\|i16\|i32\|i64\|i128'
  let s:rust .= '\|u8\|u16\|u32\|u64\|u128\|f32\|f64\|String\)\>'
  if search(s:rust, 'nw') > 0
    let b:propane_subtype = "rust"
  elseif search('\<import\s\+\%(std\|core\)\.', 'nw') > 0
    let b:propane_subtype = "d"
  else
    let b:propane_subtype = "cpp"
  endif
  unlet s:rust
endif

exe "syn include @propaneTarget syntax/".b:propane_subtype.".vim"

syn region propaneTarget matchgroup=propaneDelimiter start="<<" end=">>$" contains=@propaneTarget keepend

syn match propaneComment "#.*"
syn match propaneFieldAlias ":[a-zA-Z0-9_]\+" contains=propaneFieldOperator
syn match propaneFieldOperator ":" contained
syn match propaneOperator "?"
" The right-hand side of a rule (after '->' up to '<<' or ';') lists symbol
" names that may coincide with propane keywords (e.g. 'start', 'token',
" 'tree'). Wrap it in a region that excludes keyword matches so those names
" are not highlighted as keywords. The '<<' is left unconsumed so the
" propaneTarget region can still match it.
syn region propaneRuleRhs matchgroup=propaneOperator start="->" end="\ze<<" end=";" contains=propaneFieldAlias,propaneRuleOperator,propaneComment keepend
syn match propaneRuleOperator "?" contained
" Keywords that introduce a user-defined name. The name is consumed by
" propaneName via nextgroup so a name matching a keyword (e.g. 'token start')
" is not highlighted as a keyword. These must be a match (not syn keyword)
" because a syn keyword always wins over a contained nextgroup match.
syn match propaneNameDecl "\<\%(tokenid\|token\|lex_fn\|module\|start\|tree_prefix\|tree_suffix\)\>" nextgroup=propaneName skipwhite
syn match propaneName "\<\h\w*\>" contained
syn match propaneKeyword "\<\%(context_user_fields\|drop\|free_token_node\|noline\|on_token_node\|prefix\|ptype\|token_user_fields\|tree\)\>"

syn region propaneRegex start="/" end="/" skip="\v\\\\|\\/"

hi def link propaneComment Comment
hi def link propaneKeyword Keyword
hi def link propaneNameDecl Keyword
hi def link propaneRegex String
hi def link propaneOperator Operator
hi def link propaneRuleOperator Operator
hi def link propaneFieldOperator Operator
hi def link propaneDelimiter Delimiter
hi def link propaneFieldAlias Identifier
