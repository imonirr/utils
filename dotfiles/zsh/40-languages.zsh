# 40-languages.zsh
# Programming language environments and version managers

# =============================================================================
# Android SDK
# =============================================================================

# React Native Android development
export ANDROID_SDK=${DOTFILES_HOME}/Android/Sdk

# Android SDK and tools (macOS)
if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  export ANDROID_HOME=${DOTFILES_HOME}/Library/Android/sdk
  export PATH=${DOTFILES_HOME}/Library/Android/sdk/platform-tools:$PATH
fi

# =============================================================================
# Node.js - NVM (Node Version Manager)
# =============================================================================

export NVM_DIR="${DOTFILES_HOME}/.nvm"

if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  # Load NVM from Homebrew
  [ -s "${DOTFILES_BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${DOTFILES_BREW_PREFIX}/opt/nvm/nvm.sh"
  [ -s "${DOTFILES_BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${DOTFILES_BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
else
  # Load NVM from standard location (Linux)
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# =============================================================================
# pnpm
# =============================================================================

export PNPM_HOME="${DOTFILES_HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# =============================================================================
# Bun
# =============================================================================

export BUN_INSTALL="${DOTFILES_HOME}/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# =============================================================================
# Deno
# =============================================================================

export PATH="${DOTFILES_HOME}/.deno/bin:$PATH"

# =============================================================================
# Java - SDKMAN
# =============================================================================

# THIS MUST BE AT THE END OF LANGUAGE CONFIGS FOR SDKMAN TO WORK
export SDKMAN_DIR="${DOTFILES_HOME}/.sdkman"
[[ -s "${DOTFILES_HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${DOTFILES_HOME}/.sdkman/bin/sdkman-init.sh"
