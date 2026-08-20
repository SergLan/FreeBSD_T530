" Основные настройки
" ========================================

" Номера строк
:set number

" =========================
" Отступы
" =========================

set autoindent
set smartindent

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Для Bash
autocmd FileType sh setlocal tabstop=4
autocmd FileType sh setlocal shiftwidth=4
autocmd FileType sh setlocal expandtab

" =========================
" Интерфейс
" =========================

set cursorline
set ruler
set showcmd
set showmode

set splitbelow
set splitright

" =========================
" История и undo
" =========================
set history=1000
set undofile

" ========================================
" NERDTree
" ========================================
" Ширина дерева
let NERDTreeWinSize = 30
" F2 — открыть/закрыть дерево
nnoremap <F2> :NERDTreeToggle<CR>
" Открывать дерево при запуске без файла
autocmd VimEnter * if argc() == 0 | NERDTree | endif

" ========================================
" Подсветка синтаксиса
" ========================================
syntax on
filetype plugin indent on

" =========================
" Поиск
" =========================

set ignorecase
set smartcase
set incsearch
set hlsearch

" ========================================
" ShellCheck
" ========================================
autocmd FileType sh setlocal makeprg=shellcheck\ -f\ gcc\ %
nnoremap <F5> :silent make %<CR>:redraw!<CR>:copen<CR>

