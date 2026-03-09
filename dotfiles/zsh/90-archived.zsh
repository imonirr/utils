# 90-archived.zsh
# Archived and commented code - kept for reference
# This file contains configurations that are currently unused but may be needed in the future

# =============================================================================
# Oh-My-Zsh Optional Settings (Archived)
# =============================================================================

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# =============================================================================
# Locale Settings (Archived)
# =============================================================================

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
# export LANG_ALL=en_US.UTF-8

# export LANG=en_US.iso88591
# export LC_MESSAGES="C"

# =============================================================================
# Android Development (Archived)
# =============================================================================

# Android virtual device
# export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

# Additional Android paths
# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/platform-tools

# =============================================================================
# Deno (Archived alternative location)
# =============================================================================

# export DENO_INSTALL="/home/$USER/.deno"
# export PATH="$DENO_INSTALL/bin:$PATH"

# =============================================================================
# Python - pyenv (Archived)
# =============================================================================

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"

# Load pyenv-virtualenv automatically by adding
# eval "$(pyenv virtualenv-init -)"

# alias python=python3
# export PATH="${PATH}:$HOME/Library/Python/3.9/bin"

# =============================================================================
# Java (Archived)
# =============================================================================

# export JAVA_HOME="/Users/monir/.sdkman/candidates/java/current/bin/java"

# =============================================================================
# Compiler Flags for Libraries (Archived - macOS)
# =============================================================================

# For compilers to find sqlite you may need to set:
# export LDFLAGS="-L/opt/homebrew/opt/sqlite/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/sqlite/include"
# For pkg-config to find sqlite you may need to set:
# export PKG_CONFIG_PATH="/opt/homebrew/opt/sqlite/lib/pkgconfig"

# For compilers to find zlib you may need to set:
# export LDFLAGS="-L/opt/homebrew/opt/zlib/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/zlib/include"
# For pkg-config to find zlib you may need to set:
# export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig"

# =============================================================================
# PATH Management (Archived alternative method)
# =============================================================================

# Alternative method to add to PATH (with duplicate check)
# case ":$PATH:" in
#   *":/Users/monir/bin:"*) ;;
#   *) export PATH="$PATH:/Users/monir/bin" ;;
# esac

# =============================================================================
# Terraform (Archived)
# =============================================================================

# Terraform completion (alternative method)
# complete -o nospace -C /usr/bin/terraform terraform

# You can add the current Terraform workspace in your prompt by adding $(tf_prompt_info) to your PROMPT or RPROMPT variable.
# RPROMPT='$(tf_prompt_info)'
