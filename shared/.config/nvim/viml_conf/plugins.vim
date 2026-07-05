scriptencoding utf-8

" Plugin specification and lua stuff
lua require('plugin_specs')

" Use short names for common plugin manager commands to simplify typing.
" To use these shortcuts: first activate command line with `:`, then input the
" short alias, e.g., `pi`, then press <space>, the alias will be expanded to
" the full command automatically.
call utils#Cabbrev('pi', 'Lazy install')
call utils#Cabbrev('pud', 'Lazy update')
call utils#Cabbrev('pc', 'Lazy clean')
call utils#Cabbrev('ps', 'Lazy sync')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      configurations for vim script plugin                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""UltiSnips settings"""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use YouCompleteMe
let g:UltiSnipsExpandTrigger='<c-j>'

" Do not look for SnipMate snippets
let g:UltiSnipsEnableSnipMate = 0

" Shortcut to jump forward and backward in tabstop positions
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" Configuration for custom snippets directory, see
" https://jdhao.github.io/2019/04/17/neovim_snippet_s1/ for details.
let g:UltiSnipsSnippetDirectories=['UltiSnips', 'my_snippets']

""""""""""""""""""""""""""""vim-xkbswitch settings"""""""""""""""""""""""""
let g:XkbSwitchEnabled = 1

"""""""""""""""""""""""""vim-markdown settings"""""""""""""""""""
" Disable header folding
let g:vim_markdown_folding_disabled = 1

" Whether to use conceal feature in markdown
let g:vim_markdown_conceal = 1

" Disable math tex conceal and syntax highlight
let g:tex_conceal = ''
let g:vim_markdown_math = 0

" Support front matter of various format
let g:vim_markdown_frontmatter = 1  " for YAML format
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format

" Let the TOC window autofit so that it doesn't take too much space
let g:vim_markdown_toc_autofit = 1

"""""""""""""""""""""""""markdown-preview settings"""""""""""""""""""
" Only setting this for suitable platforms
if g:is_win || g:is_mac
  " Do not close the preview tab when switching to other buffers
  let g:mkdp_auto_close = 0

  " Shortcuts to start and stop markdown previewing
  nnoremap <silent> <M-m> :<C-U>MarkdownPreview<CR>
  nnoremap <silent> <M-S-m> :<C-U>MarkdownPreviewStop<CR>
endif

""""""""""""""""""""""""unicode.vim settings""""""""""""""""""""""""""""""
nmap ga <Plug>(UnicodeGA)

"""""""""""""""""""""""""" asyncrun.vim settings """"""""""""""""""""""""""
" Automatically open quickfix window of 6 line tall after asyncrun starts
let g:asyncrun_open = 6
if g:is_win
  " Command output encoding for Windows
  let g:asyncrun_encs = 'gbk'
endif
