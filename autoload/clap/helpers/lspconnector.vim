" Author: André Müller (info@hackingcpp.com)
" Description: vim9script functions for connecting to LSP client https://github.com/yegappan/lsp
" some code taken from https://github.com/yegappan/lsp

vim9script

if !exists('g:loaded_lsp')
    # Do not throw error as it will show up when Vim starts.
    export def GetLSPDocSymbols()
        echo 'Error: LSP client is not available'
    enddef
    finish
endif


import autoload 'lsp/lsp.vim'
import autoload 'lsp/buffer.vim' as buf
import autoload 'lsp/util.vim'
import autoload 'lsp/symbol.vim'



# -----------------------------------------------------------------------------
export def GetLSPDocSymbols(): list<string> 
    if !exists("g:loaded_lsp") || exists(":LspDocumentSymbol") != 2
        echo 'LSP client is not available'
        return []
    endif
    var fname: string = @%
    if fname->empty()
        return []
    endif
    var lspserver: dict<any> = buf.CurbufGetServerChecked('documentSymbol')
    if lspserver->empty() || !lspserver.running || !lspserver.ready
        echoerr 'LSP server not found'
        return []
    endif
    if !lspserver.isDocumentSymbolProvider
        echoerr 'LSP server does not support getting list of symbols'
        return []
    endif

    var params = {textDocument: {uri: util.LspFileToUri(fname)}}

    var reply = lspserver.rpc('textDocument/documentSymbol', params)

    if reply->empty()
        echoerr 'LSP reply is empty'
        return []
    endif
    if !reply->has_key('result')
        echoerr 'LSP reply has no result'
        return []
    endif

    reply = reply.result

    var symList: list<dict<any>> = []
    var bnr = fname->bufnr()

    if reply[0]->has_key('location')
      symList = GetSymbolsInfoTable(lspserver, bnr, reply)
    else
      GetSymbolsDocSymbol(lspserver, bnr, reply, symList)
    endif

    return symList->mapnew((_, v) => {
        var r = v.selectionRange
        if r->empty()
            r = v.range
        endif
        var linenr = r.start.line + 1
        return $'{v.name}  ({linenr})'
    })

enddef



# -----------------------------------------------------------------------------
export def GetLSPWorkspaceSymbols(query: string): list<string> 

  if !exists("g:loaded_lsp") || exists(":LspSymbolSearch") != 2
    echo 'LSP client is not available'
    return []
  endif

  var lspserver: dict<any> = buf.CurbufGetServerChecked('documentSymbol')
  if lspserver->empty() || !lspserver.running || !lspserver.ready
    echoerr 'LSP server not found'
    return []
  endif
  if !lspserver.isWorkspaceSymbolProvider
    echo 'LSP server does not support listing workspace symbols'
    return []
  endif

  var param = { query: query }
  var reply = lspserver.rpc('workspace/symbol', param)
  if reply->empty() || reply.result->empty()
    util.WarnMsg($'Symbol "{query}" is not found')
    return []
  endif

  var symInfo: list<dict<any>> = reply.result

  if lspserver.needOffsetEncoding
    symInfo->map((_, sym) => {
      if sym->has_key('location')
	      lspserver.decodeLocation(sym.location)
      endif
      return sym
    })
  endif

  var symbols: list<string> = []
  var fileName: string
  var symName: string

  for sym in symInfo
    if !sym->has_key('location')
      continue
    endif

    fileName = util.LspUriToFile(sym.location.uri)
    symName = sym.name
    if sym->has_key('containerName') && sym.containerName != ''
      symName = $'{sym.containerName}::{symName}'
    endif
    symName ..= $'  |{symbol.SymbolKindToName(sym.kind)->tolower()}|'
    var pos = sym.location.range.start
    symbols->add($'{symName}  ({fileName}:{pos.line}:{pos.character})')
  endfor

  return symbols
enddef




# -----------------------------------------------------------------------------
# Process the list of symbols (LSP interface "SymbolInformation") in
# "symbolInfoTable". For each symbol, create the name to display in the popup
# menu along with the symbol range and return the List.
def GetSymbolsInfoTable(lspserver: dict<any>,
      bnr: number,
      symbolInfoTable: list<dict<any>>): list<dict<any>>
  var symbolTable: list<dict<any>> = []
  var symbolType: string
  var name: string
  var containerName: string
  var r: dict<dict<number>>

  for syminfo in symbolInfoTable
    symbolType = symbol.SymbolKindToName(syminfo.kind)
    name = $'{syminfo.name}  |{symbolType}|'
    if syminfo->has_key('containerName') && !syminfo.containerName->empty()
      name ..= $' [{syminfo.containerName}]'
    endif
    r = syminfo.location.range
    lspserver.decodeRange(bnr, r)

    symbolTable->add({name: name, range: r, selectionRange: {}})
  endfor

  return symbolTable
enddef



# -----------------------------------------------------------------------------
# Process the list of symbols (LSP interface "DocumentSymbol") in
# "docSymbolTable". For each symbol, create the name to display in the popup
# menu along with the symbol range and return the List in "symbolTable"
def GetSymbolsDocSymbol(lspserver: dict<any>,
      bnr: number,
      docSymbolTable: list<dict<any>>,
      symbolTable: list<dict<any>>,
      parentName: string = '')
  var symbolType: string
  var name: string
  var r: dict<dict<number>>
  var sr: dict<dict<number>>
  var symInfo: dict<any>

  for syminfo in docSymbolTable
    var symName = syminfo.name
    symbolType = symbol.SymbolKindToName(syminfo.kind)->tolower()
    sr = syminfo.selectionRange
    lspserver.decodeRange(bnr, sr)
    r = syminfo.range
    lspserver.decodeRange(bnr, r)
    name = $'{symName}  |{symbolType}|'
    if parentName != ''
      name ..= $' [{parentName}]'
    endif
    symInfo = {name: name, range: r, selectionRange: sr}
    symbolTable->add(symInfo)
    if syminfo->has_key('children')
      # Process all the child symbols
      GetSymbolsDocSymbol(lspserver, bnr, syminfo.children, symbolTable,
        symName)
    endif
  endfor
enddef
