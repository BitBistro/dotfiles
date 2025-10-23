" Reset defaults
set nocompatible

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nobackup
set nowb
set noswapfile

" see :help feature-list
if has("win32")
    set backupdir=c:\temp
    set directory=c:\temp
    set undodir=c:\temp
else
    set directory=~/.vim/tmp,/var/tmp,/tmp
    set backupdir=~/.vim/tmp,/var/tmp,/tmp
    set undodir=~/.vim/tmp,/var/tmp,/tmp
endif

if !has("ide")
    try
        set undofile
    catch
        echo "Could not create undofile"
    endtry
endif

" Options
set bs=indent,eol,start     " allow backspacing over everything in insert mode
set completeopt=            " don't use a pop up menu for completions
set diffopt=filler,iwhite   " Diff options
set hidden                  " don't unload a buffer when no longer shown in a window
set history=1024            " number of command lines in history
set hlsearch
set ignorecase smartcase    " Do case insensitive matching unless 1 cap
set incsearch               " do incremental searching
set infercase               " case inferred by default
set lazyredraw              " don't redraw during macros
set lbr                     " When wrapping is on, break between words
set modeline                " enables modeline searching
set noerrorbells            " don't make noise for bell
set norelativenumber
set nowrap                  " do not wrap line
set number                  " line numbers
set numberwidth=4           " Format to 4 spaces
set ruler                   " show the cursor position all the time
set scrolloff=10            " Keep context when scrolling
set shiftround              " when at 3 spaces, and I hit > ... go to 4, not 5
set shortmess=atI           " Stifle many interruptive prompts
set showcmd                 " display incomplete commands
set showmatch               " Show matching brackets.
set showmode
set titleold=""             " Stop vim from setting: Thanks for flying VIM
set title                   " sets terminal title: Make sure your PS1 resets the title otherwise it will say as vim puts it
set tw=0                    " disable textwidth
set visualbell
set wildmenu                " turn on command line completion
set selection=inclusive
set selectmode=
set mousemodel=popup
set keymodel-=stopsel

if has("gtk")
    set iconstring=gtk
endif

if has("nvim")
    set iconstring=nvim
endif

" Mouse behavior, selection, and clipboard
if has("xterm")
    behave xterm
endif
if has("mouse")
    set mouse=a
    if has("mousehide")
        set mousehide=on
    endif
    set mousefocus
endif

" Turn off an off paste mode with F2 (must be in insert mode first)
if has("pastetoggle")
    set pastetoggle=<F2>
endif

" Clipboard operations
if has("clipboard")
    set clipboard+=unnamedplus

    " Copy operations
    nnoremap yy "+yy
    nnoremap Y "+y$
    vnoremap y "+ygv
    vnoremap <LeftRelease> "+ygv

    " Paste operations
    nnoremap p "+p
    vnoremap p "+p
    nnoremap P "+P
    vnoremap P "+P

    " Command mode abbreviation
    cnoreabbrev %y %y+
endif

" allow deleting selection without updating the clipboard (yank buffer)
nnoremap x "_x
nnoremap X "_X
vnoremap x "_x
vnoremap X "_X
nnoremap dd "_dd
vnoremap d "_d

" Map a ctrl+d to delete a line without ovewriting your buffer
nnoremap <C-D> "_dd

" Clear search criteria with Tab key
nnoremap <silent> <Tab> :nohlsearch<CR>

" Example of mapping F-keys from http://vim.wikia.com/wiki/VimTip632
" If you like :set guifont=*, you could always map a key to allow you to quickly choose a font. For example:
" map <F3> <Esc>:set guifont=*<CR>

" Map <C-S-F> to format all
map <C-S-F> gg=G``

if has("gui_running") || &term =~ "xterm"
    " Map control left right, to skip by word gui and terminal input
    map <C-LEFT> b
    map <C-RIGHT> w
    map <Esc>[D b
    map <Esc>[C w
endif

" Change the regexs to act like egrep instead of grep
nnoremap / /\v
nnoremap ? ?\v

" easier moving of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation

"
" Default Formats
set expandtab
set tabstop=8
set softtabstop=4
set shiftwidth=4
set autoindent

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

let $_HAS_COLORS = 0

if has("gui_running")
    let $_HAS_COLORS = 1
    set icon
    set guioptions=ecfgimrLta
elseif $TERM =~ '\v^(linux|xterm-color|.*-256color|tmux|iterm|vte|gnome)(-.*)?$'
    let $_HAS_COLORS = 1
elseif has("nvim") || has("terminfo")
    let $_HAS_COLORS = 1
endif

" Font, colorschemes, and highlights
if $_HAS_COLORS > 0
    set t_Co=256
    set termguicolors
    set background=dark

    "set t_AB=^[[48;5;%dm
    "set t_AF=^[[38;5;%dm

    " Show whitespace
    " MUST be inserted BEFORE the colorscheme command
    autocmd ColorScheme * highlight ExtraWhitespace ctermbg=236 guibg=#2c2c2c
    autocmd InsertLeave * match ExtraWhitespace /\s\+$/

    if has("gui_running")
        try
            if has("osx")
                set guifont=Monaco:h13
            else
                set guifont=DejaVu\ Sans\ Mono\ Book\ 12
            endif
        endtry
    endif

    let g:is_posix = 1
    " set t_Co=16

    " color pablo

    let do_syntax_sel_menu = 1
    set colorcolumn=80,120
    syntax on
    try
        " colorscheme wombat256mod
        colorscheme nord
    catch
        colorscheme pablo
    endtry
    highlight ColorColumn ctermbg=236 cterm=none guibg=#2c2c2c gui=none
endif

" file types
filetype on
filetype plugin on
filetype indent on

au BufRead,BufNewFile *.xml set filetype=xhtml
" Turn off auto-commenting and some auto-wrapping
autocmd FileType * setlocal formatoptions-=cro
autocmd FileType sh set expandtab filetype=sh shiftwidth=2 tabstop=2 softtabstop=2
autocmd BufNewFile,BufRead *.go set noexpandtab filetype=go shiftwidth=8 tabstop=8 softtabstop=8
autocmd BufNewFile,BufRead *.sh set expandtab filetype=sh shiftwidth=2 tabstop=2 softtabstop=2
