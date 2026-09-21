""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""

set nocompatible
filetype indent on

" Automatic reloading of .vimrc
autocmd! bufwritepost .vimrc source %

" Line numbers
set relativenumber
set number

" Visual style
syntax enable
set background=dark
colorscheme desert

" Encoding
set encoding=utf-8

" Colors
set term=screen-256color

" Tab behaviour
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

" No backup/swap files
set nobackup
set nowritebackup
set noswapfile
set autoread
set wildmenu

set clipboard=unnamed
set ttyfast
set backspace=indent,eol,start

" Folding
set foldmethod=indent
set foldlevel=99

" Splits
set splitbelow
set splitright

""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <SPACE> <Nop>
let mapleader = "\<Space>"

" Indentation in visual mode
vnoremap < <gv
vnoremap > >gv

" Toggle fold
nnoremap <leader>i za

" Strip trailing whitespace
noremap <leader>w :call <SID>StripTrailingWhitespaces()<CR>
noremap <silent> <F5> :call <SID>StripTrailingWhitespaces()<CR>

" Disable Ex mode
noremap Q <NOP>

" Line navigation
nnoremap H 0
nnoremap L $
nnoremap J G
nnoremap K gg

" Select whole line
nnoremap vv 0v$

""""""""""""""""""""""""""""""""""""""""""""""""""
" Navigation
""""""""""""""""""""""""""""""""""""""""""""""""""

if has('mouse')
    set mouse=a
    set ttymouse=xterm2
endif

" Move lines up/down with Alt+[jk]
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Natural line movement
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$

""""""""""""""""""""""""""""""""""""""""""""""""""
" Search
""""""""""""""""""""""""""""""""""""""""""""""""""

set ignorecase
set smartcase
set hlsearch
set incsearch

" Clear search highlight
nnoremap <CR> :noh<CR><CR>

nnoremap n nzzzv
nnoremap N Nzzzv

""""""""""""""""""""""""""""""""""""""""""""""""""
" Formatting
""""""""""""""""""""""""""""""""""""""""""""""""""

set pastetoggle=<F2>

function! <SID>StripTrailingWhitespaces()
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction

" Auto-strip on save
autocmd BufWritePre *.sh,*.py,*.js :call <SID>StripTrailingWhitespaces()

""""""""""""""""""""""""""""""""""""""""""""""""""
" Language Specific
""""""""""""""""""""""""""""""""""""""""""""""""""

highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" Run python script
autocmd FileType python nnoremap <leader>r :exec '!clear;python' shellescape(@%, 1)<CR>
