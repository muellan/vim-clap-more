" Author: André Müller (info@hackingcpp.com)
" Description: List optional packages and packadd them.

let s:cpo_save = &cpo
set cpo&vim

let s:packages = {}


function! s:packages.source() abort
  return getcompletion('', 'packadd')
endfunction


function! s:packages.sink(selected) abort
    let cmd = 'packadd ' . a:selected
    call execute(cmd)
    echo cmd
endfunction


let g:clap#provider#packages# = s:packages


let &cpo = s:cpo_save
unlet s:cpo_save

