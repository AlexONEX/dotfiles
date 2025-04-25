augroup shell_filetypes
  autocmd!
  autocmd BufRead,BufNewFile *.sh,*.bash,*.zsh,*.ksh,*.dash,*.profile,*.bashrc,*.zshrc,.zprofile setlocal filetype=sh
  autocmd BufRead,BufNewFile *.zsh,.zshrc,.zprofile let b:is_zsh = 1
  autocmd BufRead,BufNewFile *.bash,.bashrc,.bash_profile let b:is_bash = 1
  autocmd BufRead * 
    \ if getline(1) =~ '^#!.*zsh' |
    \   let b:is_zsh = 1 |
    \ elseif getline(1) =~ '^#!.*bash' |
    \   let b:is_bash = 1 |
    \ endif
augroup END
