" Author: André Müller (info@hackingcpp.com)
" Description: Search workspace symbols from LSP client https://github.com/yegappan/lsp

let s:cpo_save = &cpo
set cpo&vim

let s:lsp_symbols = {}

let s:query_delay = get(g:, 'clap_provider_lsp_symbols_delay', 300)
let s:old_query = ''
let s:query_timer = -1


function! s:lsp_symbols.source() abort
  let query = g:clap.input.get()
  if empty(query)
    return []
  endif
  return clap#helpers#lspconnector#GetLSPWorkspaceSymbols(query)
endfunction



function! s:lsp_symbols.on_typed() abort

  let query = g:clap.input.get()
  if empty(query)
    return []
  endif

  try
    if has_key(g:clap.display, 'initial_size')
      let s:initial_size = g:clap.display.initial_size
      unlet g:clap.display.initial_size
    endif
      if s:old_query ==# query
        return []
      endif

      let s:old_query = query
      let syms = clap#helpers#lspconnector#GetLSPWorkspaceSymbols(query)
      call g:clap.display.set_lines_lazy(syms)

  catch /^vim-clap/
    call g:clap.display.set_lines([v:exception])
  endtry

endfunction



function! s:lsp_symbols.sink(selected) abort
  if empty(a:selected)
    return
  endif

  let pos  = substitute(a:selected, '^.* (\(.*\))$', '\1', '')
  let file = substitute(pos, '^\(.*\):\d\+:\d\+$', '\1', '')
  let line = substitute(pos, '^.*:\(\d\+\):\d\+$', '\1', '')
  let col  = substitute(pos, '^.*:\d\+:\(\d\+\)$', '\1', '')

  call clap#sink#open_file(file, line+1, col+1)
endfunction



let g:clap#provider#lsp_symbols# = s:lsp_symbols


let &cpo = s:cpo_save
unlet s:cpo_save
