set nocompatible
filetype off
syntax on
set number
filetype plugin indent on
set backspace=indent,eol,start

" two-spaced tabs
set tabstop=2
set softtabstop=0
set shiftwidth=2
set noexpandtab
set smarttab

" custom filetypes
autocmd BufNewFile,BufRead *.plist set syntax=xml

" vim-airline
let g:airline_powerline_fonts = 1
