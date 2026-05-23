# 20-oh-my-zsh.zsh
# Oh-My-Zsh framework configuration

# =============================================================================
# Oh-My-Zsh Installation Path
# =============================================================================

export ZSH=$HOME/.oh-my-zsh

# =============================================================================
# Theme
# =============================================================================

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bira"

# =============================================================================
# Plugins
# =============================================================================

# Plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Add wisely, as too many plugins slow down shell startup
plugins=(
    git
    node
    terraform
    tmux
    kubectl
    vi-mode
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# =============================================================================
# Initialize Oh-My-Zsh
# =============================================================================

source $ZSH/oh-my-zsh.sh
