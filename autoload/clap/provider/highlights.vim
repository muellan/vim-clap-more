" Author: André Müller (info@hackingcpp.com)
" Description: List highlight groups with values & jump to definition.

let s:cpo_save = &cpo
set cpo&vim

let s:highlights = {}


function! s:highlights.source() abort

  let hls = getcompletion('', 'highlight')

  " TODO Clap highlight source: use colors for highlighting
  
  let result = []
  for hl in hls
    let hlv = split(execute('silent! verbose hi '.hl), 'Last set from ')
    let hlval = trim(hlv[0])
    let hldef = ''
    if len(hlv) > 1 
      let hldef = trim(hlv[1])
      let hld = split(hldef, ' line ')
      let hldef = hld[0] . ' : ' . hld[1]
    endif
    call add(result, hlval . '  (' . hldef . ')') 
  endfor  

  return result
endfunction



function! s:highlights.sink(selected) abort
  let file = substitute(a:selected, '^.*  (\(.*\) : .*)$', '\1', '')
  let line = substitute(a:selected, '^.*  (.* : \(\d\+\))$', '\1', '')
  call clap#sink#open_file(file, line, 1)
endfunction


let g:clap#provider#highlights# = s:highlights


let &cpo = s:cpo_save
unlet s:cpo_save

