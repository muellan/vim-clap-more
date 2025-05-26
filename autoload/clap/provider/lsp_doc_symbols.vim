" Author: André Müller (info@hackingcpp.com)
" Description: List document symbols from LSP client https://github.com/yegappan/lsp

let s:cpo_save = &cpo
set cpo&vim

let s:lsp_doc_symbols = {}


function! s:lsp_doc_symbols.source() abort
  return clap#helpers#lspconnector#GetLSPDocSymbols()
endfunction


function! s:lsp_doc_symbols.sink(selected) abort
  if empty(a:selected)
    return
  endif
  let line = substitute(a:selected, '^.* (\(\d\+\))$', '\1', '')
  call cursor(line, 1)
endfunction


let g:clap#provider#lsp_doc_symbols# = s:lsp_doc_symbols


let &cpo = s:cpo_save
unlet s:cpo_save
