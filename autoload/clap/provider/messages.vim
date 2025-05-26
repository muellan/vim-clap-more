" Author: André Müller (info@hackingcpp.com)
" Description: List recent messages.

let s:cpo_save = &cpo
set cpo&vim

let s:messages = {}


function! s:messages.source() abort
  let s = ''
  redir => s
  silent messages
  redir END
  return reverse(split(s, "\n"))
endfunction


function! s:messages.sink(selected) abort
  if !empty(a:selected)
    execute('normal i' . a:selected)
  endif
endfunction


let g:clap#provider#messages# = s:messages


let &cpo = s:cpo_save
unlet s:cpo_save

