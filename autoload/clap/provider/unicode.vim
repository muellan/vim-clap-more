" Author: André Müller (info@hackingcpp.com)
" Description: List & insert unicode characters.

let s:cpo_save = &cpo
set cpo&vim

let s:unicode = {}


function! IsValidCodepoint(n)
  return a:n >= 0 && a:n <= 0x10FFFF && (a:n < 0xD800 || a:n > 0xDFFF)
endfunction


function! s:unicode.source() abort
  let path = ''
  if has("win32") || has("win16") || has("win64")
    let path = $HOME . "/vimfiles/"
  else
    let path = '/usr/share/unicode/'
  endif
  
  let rows = readfile(path . "UnicodeData.txt")
  let result = []
  for row in rows
    let pieces = split(row, ';')
    let code = str2nr("0x".pieces[0],16)
    if IsValidCodepoint(code)
        let char = nr2char(code,1)
        call add(result, pieces[0] ."\t". char ."\t". pieces[1] ."\t". pieces[10])
    endif
  endfor

  return result
endfunction


function! s:unicode.sink(str) abort
  execute ":normal i\<C-q>u" . split(a:str, '	')[0]
endfunction

let g:clap#provider#unicode# = s:unicode


let &cpo = s:cpo_save
unlet s:cpo_save

