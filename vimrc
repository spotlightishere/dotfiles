set nocompatible
filetype off
syntax on
set number
filetype plugin indent on
set backspace=indent,eol,start

" two-spaced tabs
set tabstop=2
set softtabstop=0 noexpandtab
set shiftwidth=2
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

" custom filetypes
autocmd BufNewFile,BufRead *.plist set syntax=xml

" vim-airline
let g:airline_powerline_fonts = 1
