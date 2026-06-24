" Author: André Müller (info@hackingcpp.com)
" Description: List all misspelled words in current buffer and jump to them

if exists('g:loaded_clap_provider_spellbad')
  finish
endif
let g:loaded_clap_provider_spellbad = 1

let s:save_cpo = &cpoptions
set cpoptions&vim


highlight default link ClapSpellbadTarget IncSearch



function! s:warn(msg) abort
  echohl WarningMsg
  echomsg '[clap-spellbad] ' . a:msg
  echohl NONE
endfunction



function! s:target_bufnr() abort
  if exists('g:clap') && type(g:clap) == type({})
        \ && has_key(g:clap, 'start') && has_key(g:clap.start, 'bufnr')
    return g:clap.start.bufnr
  endif
  return bufnr('%')
endfunction



function! s:bufline_count(bufnr) abort
  let l:info = getbufinfo(a:bufnr)
  return empty(l:info) ? line('$') : l:info[0].linecount
endfunction



" collect every misspelled word from a list of lines.
function! s:collect() abort
  let l:include_caps = get(g:, 'clap_provider_spell_include_caps', 0)
  let l:items = []
  let l:last = line('$')
  let l:lnum = 1
  while l:lnum <= l:last
    let l:text = getline(l:lnum)
    let l:linelen = strlen(l:text)
    if l:linelen > 0
      call cursor(l:lnum, 1)
      let l:prev = 0
      let l:guard = 0
      while l:guard <= l:linelen
        let l:guard += 1
        let l:bad = spellbadword()
        let l:word = l:bad[0]
        " Empty result, or moved onto another line, means this line is done.
        if empty(l:word) || line('.') != l:lnum
          break
        endif
        let l:col = col('.')
        " Guard against any non-forward move (defensive; shouldn't happen).
        if l:col <= l:prev
          break
        endif
        if l:include_caps || l:bad[1] !=# 'caps'
          call add(l:items, {
                \ 'lnum': l:lnum,
                \ 'col':  l:col,
                \ 'word': l:word,
                \ 'type': l:bad[1],
                \ 'text': l:text,
                \ })
        endif
        let l:prev = l:col
        let l:next = l:col + strlen(l:word)
        if l:next > l:linelen
          break
        endif
        call cursor(l:lnum, l:next)
      endwhile
    endif
    let l:lnum += 1
  endwhile
  return l:items
endfunction



function! s:format(record) abort
  let l:context = substitute(a:record.text, '^\s*', '', '')
  return printf('%5d:%5d | %-20s | %s',
        \ a:record.lnum, a:record.col, a:record.word, l:context)
endfunction



function! s:flash(lnum, col, len) abort
  if a:len <= 0 || !exists('*timer_start') || !exists('*matchaddpos')
    return
  endif
  let l:winid = win_getid()
  let l:id = matchaddpos('ClapSpellbadTarget', [[a:lnum, a:col, a:len]])
  call timer_start(get(g:, 'clap_provider_spellbad_blink_duration', 250),
        \ function('s:flash_clear', [l:winid, l:id]))
endfunction



function! s:flash_clear(winid, id, ...) abort
  if exists('*matchdelete')
    silent! call matchdelete(a:id, a:winid)
  endif
endfunction



let s:spellbad = {}

function! s:spellbad.source() abort
  if !has('spell')
    call s:warn('this VIM was built without the +spell feature.')
    return []
  endif

  let l:bufnr = s:target_bufnr()

  let l:switched = 0
  if exists('g:clap') && has_key(g:clap, 'start')
        \ && has_key(g:clap.start, 'goto_win')
    noautocmd call g:clap.start.goto_win()
    let l:switched = 1
  endif

  try
    let l:records = s:collect()
  finally
    if l:switched && has_key(g:clap, 'input') && has_key(g:clap.input, 'goto_win')
      noautocmd call g:clap.input.goto_win()
    endif
  endtry

  return map(l:records, {_, r -> s:format(r)})
endfunction



function! s:spellbad.sink(selected) abort
  let l:m = matchlist(a:selected, '^\s*\(\d\+\)\s*:\s*\(\d\+\)\s\+|\s\+\(\S\+\)')
  if empty(l:m)
    return
  endif
  let l:lnum = str2nr(l:m[1])
  let l:col = str2nr(l:m[2])
  let l:word = l:m[3]

  execute 'normal!' l:lnum . 'G'
  call cursor(l:lnum, l:col)
  normal! zv
  normal! zz
  call s:flash(l:lnum, l:col, strlen(l:word))
endfunction



function! s:spellbad.on_move() abort
  if !exists('g:clap') || !has_key(g:clap, 'preview')
        \ || !has_key(g:clap, 'display')
    return
  endif
  let l:cur = g:clap.display.getcurline()
  let l:m = matchlist(l:cur, '^\(\d\+\):\(\d\+\):')
  if empty(l:m)
    return
  endif
  let l:lnum = str2nr(l:m[1])
  let l:bufnr = s:target_bufnr()
  let l:size = get(g:, 'clap_preview_size', 5)
  let l:total = s:bufline_count(l:bufnr)
  let l:start = max([1, l:lnum - l:size])
  let l:end = min([l:total, l:lnum + l:size])
  call g:clap.preview.show(getbufline(l:bufnr, l:start, l:end))
  call g:clap.preview.set_syntax(getbufvar(l:bufnr, '&filetype'))
endfunction



let s:spellbad.description = 'List misspelled words in the current buffer'
let s:spellbad.syntax = 'clap_spellbad'

let g:clap_provider_spellbad = s:spellbad



let &cpoptions = s:save_cpo
unlet s:save_cpo

