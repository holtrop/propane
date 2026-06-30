" Vim syntax file for Propane
" Language: propane
" Maintainer: Josh Holtrop
" URL: https://github.com/holtrop/propane

if exists("b:current_syntax")
  finish
endif

if !exists("b:propane_subtype")
  if search('\<import\s\+\%(std\|core\)\.', 'nw') > 0
    let b:propane_subtype = "d"
  else
    let b:propane_subtype = "cpp"
  endif
endif

exe "syn include @propaneTarget syntax/".b:propane_subtype.".vim"

syn region propaneTarget matchgroup=propaneDelimiter start="<<" end=">>$" contains=@propaneTarget keepend

syn match propaneComment "#.*"
syn match propaneOperator "->"
syn match propaneFieldAlias ":[a-zA-Z0-9_]\+" contains=propaneFieldOperator
syn match propaneFieldOperator ":" contained
syn match propaneOperator "?"
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
hi def link propaneFieldOperator Operator
hi def link propaneDelimiter Delimiter
hi def link propaneFieldAlias Identifier
