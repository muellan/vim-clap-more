" Author: André Müller (info@hackingcpp.com)
" Description: List & jump to change locations.

let s:cpo_save = &cpo
set cpo&vim

let s:changes = {}


function! s:changes.source() abort
  let s = ''
  redir => s
  silent changes
  redir END
  let rows = reverse(split(s, "\n")[1:])
  let result = []
  for row in rows
    let row = substitute(row, '^\s*>\s*', '', '')
    if row != ''
      let row = substitute(row, '^\s*\(\d\+\)\(\s\+\d\+\)\(\s\+\d\+\)\s\+\(.*\)', '\2:\3  \4', '')
      call add(result, row)
    endif
  endfor
  return result
endfunc


function! s:changes.sink(selected) abort
  let row = substitute(a:selected, '^\s*\(\d\+\)\s*:\s*\(\d\+\).*', '\1 \2', '')
  let pos = split(row, ' ')
  call cursor(pos[0], pos[1])
  execute "normal! zz"
endfunction


let g:clap#provider#changes# = s:changes


let &cpo = s:cpo_save
unlet s:cpo_save

