" Author: André Müller (info@hackingcpp.com)
" Description: List all misspelled words in current buffer

let s:cpo_save = &cpo
set cpo&vim

let s:spellbad = {}


function! GetMisspelledWords()
    let result = []
    " let buflines = getbufline('%', 1, '$')
    " for line in buflines
    
    let bad = spellbadword()
     
    while len(bad) > 0
        call add(result, bad[0] . '  [' . bad[1] . ']')
        let bad = spellbadword()
    endwhile

    return result
endfunction



function! s:spellbad.source() abort
    return GetMisspelledWords()
endfunction



function! s:spellbad.sink(selected)

endfunction



let g:clap#provider#spellbad# = s:spellbad


let &cpo = s:cpo_save
unlet s:cpo_save

