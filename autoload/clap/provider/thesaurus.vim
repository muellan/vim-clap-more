" Author: André Müller (info@hackingcpp.com)
" Description: List & apply thesaurus suggestions from Aiksaurus.

let s:cpo_save = &cpo
set cpo&vim

let s:thesaurus = {}


function! s:thesaurus.source() abort
  let res = []
  let h = ''
  let shellprefix = ''
  for l in systemlist((has('win32') ? 'wsl ' : '') . 'aiksaurus '. expand('<cword>'))
    if l[:3] == '=== '
      let h = '(' .. substitute(l[4:], ' =*$', ')', '')
    elseif l ==# 'Alphabetically similar known words are: '
      let h = "\U0001f52e"
    elseif l[0] =~ '\a' || (h ==# "\U0001f52e" && l[0] ==# "\t")
      call extend(res, map(split(substitute(l, '^\t', '', ''), ', '), {_, val -> val}))
    endif
  endfor
  call sort(res)
  return res
endfunction


function! s:thesaurus.sink(selected)
  execute "normal ciW".a:selected
endfunction


let g:clap#provider#thesaurus# = s:thesaurus


let &cpo = s:cpo_save
unlet s:cpo_save

