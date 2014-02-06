set nocompatible                " choose no compatibility with legacy vi
syntax enable

filetype off
set runtimepath+=~/editor_configs/vim/vundle
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'guns/vim-clojure-static'
Bundle 'kien/ctrlp.vim'
Bundle 'guns/vim-sexp'
Bundle 'tpope/vim-sexp-mappings-for-regular-people'
Bundle 'tpope/vim-fireplace'
Bundle 'tpope/vim-surround'


set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set laststatus=2  " always show the status bar


"" CtrlP
let g:ctrlp_root_markers = ['.ctrlp-root']
let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'
let g:ctrlp_map = 'p'

autocmd BufRead,BufNewFile {*.cljs,*.edn,*.cljx} setlocal filetype=clojure


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keybindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","
let maplocalleader = ","

nmap <F1> <nop>

" CtrlP maps
map <leader>p :CtrlP<cr>
map <leader>js :CtrlP app/assets/javascripts<cr>

