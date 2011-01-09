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
unlet! b:current_syntax
" Include Haml syntax highlighting
syn include @slimHaml syntax/haml.vim
unlet! b:current_syntax
" Include Erb syntax highlighting
syn include @slimErb syntax/eruby.vim
unlet! b:current_syntax

" Include HTML 
runtime! syntax/html.vim
unlet! b:current_syntax

setlocal iskeyword+=:

syn region slimInterpolation matchgroup=slimInterpolationDelimiter start="#{" end="}" contained contains=@slimRuby

syn region slimRubyOutput start="=\s*" skip=",\s*" end=" " contained contains=@slimRuby
syn region slimHtml start="^\s*[^-=]\w" end="$" contains=htmlTagName,htmlArg,htmlString,slimInterpolation,slimRubyOutput keepend

syn region slimRubyCode start="[-=]" end="$" contains=@slimRuby

syn match slimComment /^\(\s*\)[/].*\(\n\1\s.*\)*/
syn match slimText /^\(\s*\)[`|'].*\(\n\1\s.*\)*/

syn match slimFilter /\s*\w\+:\s*/ contained
syn match slimJs /^\(\s*\)\<javascript:\>.*\(\n\1\s.*\)*/ contains=@htmlJavaScript,slimFilter
syn match slimHaml /^\(\s*\)\<haml:\>.*\(\n\1\s.*\)*/ contains=@slimHaml,slimFilter
syn match slimErb  /^\(\s*\)\<erb:\>.*\(\n\1\s.*\)*/ contains=@slimErb,slimFilter

hi def link slimText                   String
hi def link slimComment                Comment
hi def link slimFilter                 Special
hi def link slimInterpolationDelimiter Delimiter

let b:current_syntax = "slim"
