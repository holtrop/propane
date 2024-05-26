" Vim syntax file for Propane
" Language: propane
" Maintainer: Josh Holtrop
" URL: https://github.com/holtrop/propane

if exists("b:current_syntax")
  finish
endif

if !exists("b:propane_subtype")
  let b:propane_subtype = "d"
endif

exe "syn include @propaneTarget syntax/".b:propane_subtype.".vim"

syn region propaneTarget matchgroup=propaneDelimiter start="<<" end=">>$" contains=@propaneTarget keepend

syn match propaneComment "#.*"
syn match propaneOperator "->"
syn keyword propaneKeyword ast ast_prefix ast_suffix drop module prefix ptype start token tokenid

syn region propaneRegex start="/" end="/" skip="\\/"

hi def link propaneComment Comment
hi def link propaneKeyword Keyword
hi def link propaneRegex String
hi def link propaneOperator Operator
hi def link propaneDelimiter Delimiter
