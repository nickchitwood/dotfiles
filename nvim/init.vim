" Neovim Config - Some things are included so that I remember they are defaults
 
" *
" * Tabs and Indent land
" *
" autoindent - 
" smarttab - <Tab> in front of line inserts according to shiftwidth (default is 8) 
set tabstop=4 " the visible width of tabs
set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4 " number of spaces to use for indent and unindent
set shiftround " round indent to a multiple of 'shiftwidth'

" *
" * Appearance
" *
set number
set textwidth=88
set fo-=t

" *
" * Custom Mappings
" *
let mapleader = ','
