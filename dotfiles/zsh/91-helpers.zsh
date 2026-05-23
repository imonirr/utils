# Open current command line in Neovim with Ctrl+V
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^v' edit-command-line

bindkey -v
