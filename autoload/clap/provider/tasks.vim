" Author: André Müller (info@hackingcpp.com)
" Description: List & execute asynchronous tasks (based on '.task' files).

let s:cpo_save = &cpo
set cpo&vim

let s:tasks = {}


function! s:tasks.source() abort
  let rows = asynctasks#source(&columns * 48 / 100)
  let source = []
  for row in rows
    let name = row[0]
    let source += [name . '  ' . row[1] . '  : ' . row[2]]
  endfor
  return source
endfunction 


function! s:tasks.sink(selected) abort
  let p1 = stridx(a:selected, '<')
  if p1 >= 0
    let name = strpart(a:selected, 0, p1)
    let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
    if name != ''
      exec "AsyncTask ". fnameescape(name)
    endif
  endif
endfunction


let g:clap#provider#tasks# = s:tasks


let &cpo = s:cpo_save
unlet s:cpo_save

