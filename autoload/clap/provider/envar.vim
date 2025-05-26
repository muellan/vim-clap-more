" Author: André Müller (info@hackingcpp.com)
" Description: List environment variables with their values.

let s:cpo_save = &cpo
set cpo&vim

let s:envar = {}


function! s:envar.source() abort

  let env = environ()

  " TODO Clap envar : highlight
  
  let vars = []
  for [name,value] in items(env)
    call add(vars, name . ' = "' . value . '"')
  endfor 
  
  return vars
endfunction


function! s:envar.sink(selected) abort
  let name = substitute(a:selected, '^\(\<\S\+\>\) = .*', '\1', '')
  let ins = '${' . name . '}'
  execute('normal i' . ins)
endfunction


let g:clap#provider#envar# = s:envar


let &cpo = s:cpo_save
unlet s:cpo_save

