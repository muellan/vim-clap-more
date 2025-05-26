" Author: André Müller (info@hackingcpp.com)
" Description: List VIM options with their values and toggle or set.

let s:cpo_save = &cpo
set cpo&vim

let s:options = {}


function! s:options.source() abort

  let opts = getcompletion('', 'option')
  let result = []

  let suppressed = ['all', 'termcap']

  for optname in opts
    if index(suppressed,optname) < 0
      let value = execute('silent! echo &'.optname)
      let pad = 20 - len(optname)
      let line = optname . repeat(' ', pad) . value
      call add(result, line)
    endif
  endfor

  return result
endfunction


function! s:options.sink(selected) abort
  let optname = split(a:selected, '\s\+')[0]
  let value = execute('silent! echo &'.optname)[1:]

  if value == '1' || value == '0'
    execute('set '.optname.'!')
  else
    let result = input(':','set '.optname.'='.value)
    echo result
    execute(result)
  endif
  
  execute('set '.optname.'?') 

endfunction


let g:clap#provider#options# = s:options


let &cpo = s:cpo_save
unlet s:cpo_save

