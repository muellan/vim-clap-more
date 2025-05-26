# vim-clap-more


A collection of additional providers for the excellent fuzzy finder/selector
VIM plugin [vim-clap](https://github.com/liuchengxu/vim-clap).

The Implementations could probably be improved, especially handling of corner cases, invalid values, etc.

The LSP providers use the Vim9script based [LSP client plugin](https://github.com/yegappan/lsp)
from [@yegappan](https://github.com/yegappan) and also reuse some code from it.
I've only tested them with a couple of language servers so far, mainly with clangd but also with
pylsp, bash-ls, vimls, markman, vscode-json-server, vscode-html-server, vscode-css-server.




## Providers

| Command           | Lists                                   | Action                                   | Dependencies                                                       |
| ----------------- | --------------------------------------- | ---------------------------------------- | ------------------------------------------------------------------ |
| `tasks`           | Tasks definitions                       | execute task                             | [asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)    |
| `lsp_symbols`     | LSP workspace symbol live query         | go to symbol definition                  | [yegappan/lsp](https://github.com/yegappan/lsp)                    |
| `lsp_doc_symbols` | LSP document symbols                    | go to symbol definition                  | [yegappan/lsp](https://github.com/yegappan/lsp)                    |
| `unicode`         | Unicode code points                     | insert selected unicode character        | [unicode-data](https://repology.org/project/unicode-data/versions) |
| `thesaurus`       | Thesaurus entries for word under cursor | replace word under cursor with selection | [aiksaurus](https://repology.org/project/aiksaurus/versions)       |

Instead of `lsp_doc_symbols` you can also use [vista.vim](https://github.com/liuchengxu/vista.vim)
which automatically enables the `Clap tags` provider to search LSP document symbols.


| Command      | Lists                                                                                          | Action                                                                       |
| ------------ | -------------------------------------------------------------------------------------------    | --------------------------------------------------------------               |
| `args`       | Arg Files from [`:args`](https://vimhelp.org/editing.txt.html#%3Aargs)                         | open file                                                                    |
| `changes`    | Change locations from [`:changes`](https://vimhelp.org/motion.txt.html#%3Achanges)             | go to change location                                                        |
| `chistory`   | Quickfix history from [`:chistory`](https://vimhelp.org/quickfix.txt.html#%3Achistory)         | load corresponding quickfist list                                            |
| `lhistory`   | Location list history from [`:lhistory`](https://vimhelp.org/quickfix.txt.html#%3Alhistory)    | load corresponding location list                                             |
| `envar`      | Environment variables and their values                                                         | insert `${VARNAME}` into current buffer                                      |
| `highlights` | Syntax highlight groups and their values                                                       | go to where active values were defined                                       |
| `messages`   | Recent messages from [`:messages`](https://vimhelp.org/message.txt.html#%3Amessages)           | insert message into current buffer                                           |
| `options`    | All VIM options and their values                                                               | toggle or prompt for new value                                               |
| `packages`   | Optional VIM packages                                                                          | [`packadd`](https://vimhelp.org/repeat.txt.html#%3Apackadd) selected package |
| `spellfix`   | Spell suggestions for word under cursor (like [`z=`](https://vimhelp.org/spell.txt.html#z%3D)) | apply spell fix to word under cursor                                         |
| `tabs`       | Tabs                                                                                           | go to tab                                                                    |
| `undo`       | Undo points from [`:undolist`](https://vimhelp.org/undo.txt.html#%3Aundolist)                  | go back to undo point                                                        |

