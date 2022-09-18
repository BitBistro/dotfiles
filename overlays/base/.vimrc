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
    set backupdir=h:\tmp,c:\tmp,c:\temp
    set directory=h:\tmp,c:\tmp,c:\temp
    set undodir=h:\tmp,c:\tmp,c:\temp
else
    set directory=~/.vim/tmp,/var/tmp,/tmp
    set backupdir=~/.vim/tmp,/var/tmp,/tmp
    set undodir=~/.vim/tmp,/var/tmp,/tmp
endif

try
    set undofile
catch
    echo "Could not create undofile"
endtry

" Options
set bs=indent,eol,start     " allow backspacing over everything in insert mode
set title                   " sets terminal title: Make sure your PS1 resets the title otherwise it will say as vim puts it
set titleold=""             " Stop vim from setting: Thanks for flying VIM
set scrolloff=5             " Keep context when scrolling
set showmatch               " Show matching brackets.
set history=1024            " number of command lines in history
set ruler                   " show the cursor position all the time
set showcmd                 " display incomplete commands
set incsearch               " do incremental searching
set ignorecase smartcase    " Do case insensitive matching unless 1 cap
set wildmenu                " turn on command line completion
set completeopt=            " don't use a pop up menu for completions
set diffopt=filler,iwhite   " Diff options
set number                  " line numbers
set numberwidth=4           " Format to 3 spaces
set noerrorbells            " don't make noise for bell
set novisualbell            " don't flash the screen on bell
set shiftround              " when at 3 spaces, and I hit > ... go to 4, not 5
set hidden                  " don't unload a buffer when no longer shown in a window
set infercase               " case inferred by default
set lbr                     " When wrapping is on, break between words
set nowrap                  " do not wrap line
set shortmess=atI           " Stifle many interruptive prompts
set tw=0                    " disable textwidth
set modeline                " enables modeline searching
set lazyredraw              " don't redraw during macros

" Mouse behavior, selection, and clipboard
behave xterm
if has("mouse")
    set mouse=a
    set mousehide=on
    set mousefocus
endif

set selection=inclusive
set selectmode=
set mousemodel=popup
set keymodel-=stopsel

if has("clipboard")
    set clipboard=unnamed
endif

if has("gtk")
    set iconstring=gtk
endif

if has("nvim")
    set iconstring=nvim
endif


" Turn off an off paste mode with F8 (must be in insert mode first)
set pastetoggle=<F2>

" Copy selected text in visual mode to yank buffer
vnoremap y ygv
vnoremap <LeftRelease> ygv
noremap <LeftRelease> ygv

" allow deleting selection without updating the clipboard (yank buffer)
nnoremap x "_x
nnoremap X "_X
vnoremap x "_x
vnoremap X "_X

" Map a ctrl+d to delete a line without ovewriting your buffer
nnoremap <C-D> "_dd

" Clear search criteria with Tab key
nnoremap <Tab> :noh<CR>


" Example of mapping F-keys from http://vim.wikia.com/wiki/VimTip632
" If you like :set guifont=*, you could always map a key to allow you to quickly choose a font. For example:
" map <F3> <Esc>:set guifont=*<CR>

" Don't use Ex mode, use Q for formatting
map Q gq

if has("gui_running") || &term =~ "xterm"
    " Map control left right, to skip by word gui and terminal input
    map <C-LEFT> b
    map <C-RIGHT> w
    map ^[[D b
    map ^[[C w
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
elseif $TERM =~ '\v^(linux|xterm-color|.*-256color|tmux|iterm|vte|gnome)(-.*)?$'
    let $_HAS_COLORS = 1
elseif has("nvim") || has("terminfo")
    let $_HAS_COLORS = 1
endif

" Font, colorschemes, and highlights
if $_HAS_COLORS > 0
    set t_Co=256
    set termguicolors
    set hlsearch
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
        set guioptions=ecfgimrLta
        " set guioptions=aefgiLmrt
    endif

    let g:is_posix = 1
    " set t_Co=16

    " color pablo

    filetype off
    filetype plugin indent on

    let do_syntax_sel_menu = 1
    set colorcolumn=80,128
    syntax on
    try
        colorscheme wombat256mod
    catch
        colorscheme pablo
    endtry
    hi ColorColumn ctermbg=236 cterm=none guibg=#2c2c2c gui=none
endif


" Adapted from https://stackoverflow.com/a/24046914
let s:comment_map = { 
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " " 
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else 
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
    echo "here"
endfunction

nnoremap <C-/> :call ToggleComment()<cr>
vnoremap <C-/> :call ToggleComment()<cr>gv

" file types
filetype on
filetype plugin on
filetype indent on

au BufRead,BufNewFile *.xml set filetype=xhtml
" Turn off auto-commenting and some auto-wrapping
autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o
autocmd BufNewFile,BufRead *.go set noexpandtab filetype=go shiftwidth=8 tabstop=8 softtabstop=8
