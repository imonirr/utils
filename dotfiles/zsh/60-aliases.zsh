# 60-aliases.zsh
# General shell aliases and suffix aliases

# =============================================================================
# File Operations
# =============================================================================

# Move files to /tmp instead of deleting
alias trash='mv -t /tmp'

# =============================================================================
# Git Aliases
# =============================================================================

# Enhanced git log with statistics
alias glg="git log --color --all --date-order --decorate --dirstat=lines,cumulative --stat | sed 's/\([0-9] file[s]\? .*)$\)/\1\n_______\n-------/g' | \less -R"

# =============================================================================
# Editor Aliases
# =============================================================================

# Use neovim for vim
alias vim='nvim'

# =============================================================================
# Suffix Aliases
# =============================================================================

# Open files by extension with specific programs
alias -s md=vim
alias -s json=vim
alias -s {css,ts,html}=vim
alias -s {mp4}=vlc

# =============================================================================
# Shell Configuration Aliases
# =============================================================================

# Edit .zshrc in the default editor
alias ec="$EDITOR ${DOTFILES_HOME}/.zshrc"

# Source .zshrc to reload configuration
alias sc="source ${DOTFILES_HOME}/.zshrc"

# =============================================================================
# Network Utilities
# =============================================================================

# Get local IP address using Google's DNS
alias localip='dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com'
