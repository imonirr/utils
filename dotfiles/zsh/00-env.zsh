# 00-env.zsh
# Environment variables and PATH configuration
# Loaded first to ensure all paths are available for subsequent configs

# =============================================================================
# Basic PATH Setup
# =============================================================================

# Local bin directories
export PATH="${PATH}:${DOTFILES_HOME}/.local/bin"
export PATH="${DOTFILES_HOME}/bin:$PATH"

# System binaries
export PATH="/usr/local/bin:${DOTFILES_BREW_PREFIX}/bin:$PATH"

# =============================================================================
# Hostname
# =============================================================================

export hostname=$HOST

# =============================================================================
# ibus (Input Method Framework)
# =============================================================================

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# =============================================================================
# Ruby Gems
# =============================================================================

export GEM_HOME="${DOTFILES_HOME}/gems"
export PATH="${DOTFILES_HOME}/gems/bin:$PATH"

# Ruby from Homebrew (macOS)
if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  export PATH="${DOTFILES_BREW_PREFIX}/opt/ruby/bin:$PATH"
fi

# =============================================================================
# Go
# =============================================================================

export GOPATH=${DOTFILES_HOME}/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# =============================================================================
# Rust/Cargo
# =============================================================================

export PATH=${DOTFILES_HOME}/.cargo/bin:$PATH

# =============================================================================
# Deno
# =============================================================================

export PATH="${DOTFILES_HOME}/.deno/bin:$PATH"

# =============================================================================
# Global NPM packages
# =============================================================================

export PATH=$(npm bin -g):$PATH

# =============================================================================
# Dropbox
# =============================================================================

export PATH="${PATH}:/home/monir/.dropbox-dist"

# =============================================================================
# Miscellaneous paths
# =============================================================================

export PATH="${PATH}:/opt"

# =============================================================================
# Password Store (pass with gpg)
# =============================================================================

export PASSWORD_STORE_DIR=${DOTFILES_HOME}/Dropbox/Credentials/.password-store

# =============================================================================
# icu4c (for multipass app - macOS only)
# =============================================================================

if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  export PATH="${DOTFILES_BREW_PREFIX}/opt/icu4c@76/bin:$PATH"
  export PATH="${DOTFILES_BREW_PREFIX}/opt/icu4c@76/sbin:$PATH"
  export LDFLAGS="-L${DOTFILES_BREW_PREFIX}/opt/icu4c@76/lib"
  export CPPFLAGS="-I${DOTFILES_BREW_PREFIX}/opt/icu4c@76/include"
fi
