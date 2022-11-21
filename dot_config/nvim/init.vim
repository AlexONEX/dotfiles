call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.config/nvim/plugged')
Plug 'arcticicestudio/nord-vim'
Plug 'preservim/nerdtree'
Plug 'github/copilot.vim'
Plug 'lervag/vimtex'
	let g:tex_flavor='latex'
	let g:vimtex_view_method='zathura'
	let g:vimtex_quickfix_mode=0
	set conceallevel=1
	let g:tex_conceal='abdmg'
Plug 'sirver/ultisnips'
	let g:UltiSnipsExpandTrigger = '<tab>'
	let g:UltiSnipsJumpForwardTrigger = '<tab>'
	let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
	let g:python3_host_prog = '/usr/bin/python3'
	let g:UltiSnipsSnippetsDir = '~/.config/nvim/ultisnips'
	let g:UltiSnipsSnippetDirectories=['ultisnips']
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
call plug#end()

colorscheme nord

nnoremap <leader>n :NERDTreeToggle<CR>
"syntax enable
"setlocal spell
"set spelllang=es_ar
"set spelllang = en_us
set tabstop=2
set shiftwidth=2
set expandtab
set number
set relativenumber
"set textwidth=80

map <Space> <Leader>

inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

