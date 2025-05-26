" Author: liuchengxu <xuliuchengxlc@gmail.com>
" Description: List all tabs.

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:tabs = {}


function! s:tabs.source() abort
  let lines = []

  for t in range(1, tabpagenr('$'))
    let numwins = tabpagewinnr(t, '$')
    call add(lines, t . "  (" . numwins . " windows)")    
  endfor

  return lines
endfunction


function! s:tabs.sink(line) abort
  let tabmatch = matchlist(a:line, '^ *\([0-9]\+\)  .*')
  let tab = tabmatch[1]
  execute tab.'tabnext'
endfunction


let g:clap#provider#tabs# = s:tabs

let &cpoptions = s:save_cpo
unlet s:save_cpo
