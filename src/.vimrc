if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible                " Use Vim defaults (much better!)
set bs=indent,eol,start         " allow backspacing over everything in insert mode

set nobackup
set nowb
set noswapfile

set directory=~/.vim/tmp,/var/tmp,/tmp
set backupdir=~/.vim/tmp,/var/tmp,/tmp

set title                   " sets terminal title: Make sure your PS1 resets the title otherwise it will say as vim puts it
set titleold=""             " Stop vim from setting: Thanks for flying VIM
set mousehide               " Hide the mouse when typing text
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
set et ts=4 sw=4 sts=4      " Setup up tab width
set ai                      " turns on autointent

" Turn off an off paste mode with F8 (must be in insert mode first)
set pastetoggle=<F8>

" Example of mapping F-keys from http://vim.wikia.com/wiki/VimTip632
" If you like :set guifont=*, you could always map a key to allow you to quickly choose a font. For example:
" map <F3> <Esc>:set guifont=*<CR>

" Clear search criteria with Tab key
nnoremap <Tab> :noh<CR>

nnoremap <F9> :w<CR>:!deploy-file %<CR>

" allow deleting selection without updating the clipboard (yank buffer)
vnoremap x "_x
vnoremap X "_X

" Map a key to delete a line without ovewriting your buffer
nnoremap <C-D> "_dd

" Don't use Ex mode, use Q for formatting
map Q gq

" easier moving of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation

" Colorscheme is option set '$_USE_COLOR_SCHEME to 0' to disable
let $_USE_COLORSCHEME = 1

if $_USE_COLORSCHEME > 0

    " Show whitespace
    " MUST be inserted BEFORE the colorscheme command
    autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
    autocmd InsertLeave * match ExtraWhitespace /\s\+$/

    " Font, colorschemes, and highlights
    if has("gui_running") || has("terminfo")
        set hlsearch
        hi clear
        set background=dark

        if has("gui_running")
            set guifont=DejaVu\ Sans\ Mono\ Book\ 12
            set guioptions=ecfgimrLta
        endif

        let g:is_posix = 1
        let do_syntax_sel_menu = 1
        set t_Co=256

        colorscheme wombat256mod

        syntax on

        filetype off
        filetype plugin indent on

        set colorcolumn=80,128
        highlight ColorColumn ctermbg=16
    endif

endif

au BufRead,BufNewFile *.xml set filetype=xhtml
" Turn off auto-commenting and some auto-wrapping
autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o
