" Author: André Müller (info@hackingcpp.com)
" Description: List & apply spell suggestions.

let s:cpo_save = &cpo
set cpo&vim

let s:spellfix = {}


function! s:spellfix.source() abort
  return spellsuggest(expand("<cword>"))
endfunction


function! s:spellfix.sink(selected)
  execute "normal ciW".a:selected
endfunction


let g:clap#provider#spellfix# = s:spellfix


let &cpo = s:cpo_save
unlet s:cpo_save

