set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

source ~/.vimrc
if exists('g:vscode')
    " VSCode extension
else
    " ordinary neovim
endif

autocmd TermOpen * startinsert
if has("clipboard")
    set clipboard=unnamedplus
endif
