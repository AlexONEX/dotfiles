" Set the comment format for Scala
set commentstring=//\ %s

" Disable inserting comment leader after hitting o or O or <Enter>
set formatoptions-=o
set formatoptions-=r

" Map F9 to compile and run the current Scala file
nnoremap <silent> <buffer> <F9> :call <SID>compile_run_scala()<CR>

function! s:compile_run_scala() abort
  let src_path = expand('%:p:~')
  let src_noext = expand('%:p:~:r')

  " Check if 'scalac' (Scala compiler) is available
  if !executable('scalac')
    echoerr 'Scala compiler (scalac) not found on the system!'
    return
  endif

  " Check if 'scala' (Scala runtime) is available
  if !executable('scala')
    echoerr 'Scala runtime (scala) not found on the system!'
    return
  endif

  call s:create_term_buf('h', 20)
  execute printf('term scalac %s && scala %s', src_path, src_noext)
  startinsert
endfunction

function s:create_term_buf(_type, size) abort
  set splitbelow
  set splitright
  if a:_type ==# 'v'
    vnew
  else
    new
  endif
  execute 'resize ' . a:size
endfunction

" For delimitMate
let b:delimitMate_matchpairs = "(:),[:],{:}"
