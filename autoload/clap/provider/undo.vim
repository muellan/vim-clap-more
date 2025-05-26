" Author: André Müller (info@hackingcpp.com)
" Description: List undo points.

let s:cpo_save = &cpo
set cpo&vim

let s:undo = {}


function! s:undo.source() abort
  let s = ''
  redir => s
  silent undolist
  redir END
  let rows = sort(split(s, "\n")[1:])
  let result = []
  for row in rows
    let row = substitute(row, '^\s*\(\d\+\)\s*\(\d\+\)\s*\([0-9/]\+ \)\=\([0-9:]\+[a-zA-Z ]*\)\s*.*$', '\1  \3\4  (\2 changes)', '')
    call add(result, row)
  endfor
  return result
endfunc


function! s:undo.sink(selected) abort
  let idx = substitute(a:selected, '^\s*\(\d\+\)\s\+.*$', '\1', '')
  execute "undo ".idx
endfunction


let g:clap#provider#undo# = s:undo


let &cpo = s:cpo_save
unlet s:cpo_save
 
