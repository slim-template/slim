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

syntax region slimHtml start="^\s*[^-=]\w" end="$" contains=htmlTagName, htmlArg, htmlString

syntax region slimControl  start="-" end="$"  contains=@slimRuby keepend
syntax region slimOutput   start=".*=\s" end="$"  contains=@slimRuby keepend


let b:current_syntax = "slim"
