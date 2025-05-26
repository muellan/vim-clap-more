" Author: André Müller (info@hackingcpp.com)
" Description: List quickfix list history.

let s:cpo_save = &cpo
set cpo&vim

let s:chistory = {}


function! s:chistory.source() abort
  let s = ''
  redir => s
  silent chistory
  redir END
  let hist = split(s, "\n")
  let n = len(hist)
  if n == 1 && hist[0] !~ "^\S*>."
    return [] 
  endif
  let m = 0
  let pos = 0
  let l = []
  for h in hist
    if h =~ "^\S*>.*" 
      let pos = 1
    else 
      if pos == 0 | let m = m + 1 | endif
    endif
    let line = split(h, ";")[1]
    " make sure command line options of common tools don't make lines too long
    let line = substitute(line, '\(rg\|fzf\|sk\|vimgrep\)\( --\S\+\)*', '\1', '')
    call add(l, line)
  endfor

  let i = 0
  let n = len(l)
  while i < m
    let l[i] = "-".(m-i).l[i]." "
    let i = i + 1
  endwhile
  let l[m] = "> ".l[m]
  let i = m+1
  while i < n
    let l[i] = "+".(i-m).l[i]." "
    let i = i + 1
  endwhile

  return l
endfunction


function! s:chistory.sink(selected) abort
  let cmd = split(a:selected, " ")[0]
  if cmd =~ '^>.*'
  else 
    if cmd =~ '^+.*'
      let cmd = substitute(cmd, '^+\(\d\+\).*', 'cnewer \1', '')
    else
      let cmd = substitute(cmd, '^-\(\d\+\).*', 'colder \1', '')
    endif
    silent execute ":".cmd
    silent execute ":copen 15"
  endif
endfunction


let g:clap#provider#chistory# = s:chistory


let &cpo = s:cpo_save
unlet s:cpo_save

