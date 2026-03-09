# 20-oh-my-zsh.zsh
# Oh-My-Zsh framework configuration

# =============================================================================
# Oh-My-Zsh Installation Path
# =============================================================================

export ZSH=${DOTFILES_HOME}/.oh-my-zsh

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
plugins=(git node terraform tmux kubectl)

# =============================================================================
# Initialize Oh-My-Zsh
# =============================================================================

source $ZSH/oh-my-zsh.sh
