" Vim syntax file
" Language: Slim
" Maintainer: Andrew Stone <andy@stonean.com>
" Version:  1
" Last Change:  2010 Sep 25
" TODO: Feedback is welcomed.

" Quit when a syntax file is already loaded.
if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'slim'
endif

" Allows a per line syntax evaluation.
let b:ruby_no_expensive = 1

" Include Ruby syntax highlighting
syn include @slimRuby syntax/ruby.vim

" Include HTML 
runtime! syntax/html.vim
unlet! b:current_syntax

syn match slimCode /^\s*[-=#.!].*/ contained

syn match slimComment /^\(\s\+\)[/].*\(\n\1\s.*\)*/ 

syn match slimText /^\(\s\+\)[`|'].*\(\n\1\s.*\)*/ 

"syn region slimText start=/\(\s*\)[`|'].*\(\n\1\s.*\)*/ end="$"

syn region slimHtml start="^\s*[^-=]\w" end="$" contains=htmlTagName, htmlArg, htmlString

syn region slimControl start="-" end="$" contains=@slimRuby keepend


hi def link slimText                   String
hi def link slimComment                Comment

let b:current_syntax = "slim"
