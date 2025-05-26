" Author: André Müller (info@hackingcpp.com)
" Description: List 'args' files.

let s:cpo_save = &cpo
set cpo&vim

let s:args = {}


function! s:args.source() abort
  return argv()
endfunction 


function! s:args.sink(selected) abort
  let l:arg_index = index(argv(), a:selected)
  if (l:arg_index != -1)
    let l:arg_index = l:arg_index + 1
    execute "argument " . l:arg_index
  endif
endfunction


let s:args.support_open_action = v:true
let s:args.syntax = 'clap_files'

let g:clap#provider#args# = s:args

let &cpo = s:cpo_save
unlet s:cpo_save

