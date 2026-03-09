# 50-tools.zsh
# Development tools, completions, and tool-specific aliases

# =============================================================================
# Docker Compose Aliases
# =============================================================================

alias dup='docker-compose up'
alias ddown='docker-compose down'
alias dbuild='docker-compose build'

# =============================================================================
# Spring Boot Aliases (Java)
# =============================================================================

alias sboot='mvn spring-boot:run -Dspring-boot.run.profiles=local'
alias sbootc='mvn clean compile && mvn spring-boot:run -Dspring-boot.run.profiles=local'

# Run debug mode Spring Boot
alias sbootd='mvn spring-boot:run -Dspring-boot.run.profiles=local -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005" '

# =============================================================================
# Avante (AI-powered Neovim plugin)
# =============================================================================

# Launch neovim in Avante zen mode
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# =============================================================================
# Shell Completions
# =============================================================================

# Enable bash completion for zsh
autoload -U +X bashcompinit && bashcompinit

# Azure CLI completion
source ${DOTFILES_HOME}/work/utils/az.completion

# Kubectl completion (optional - uncomment if needed)
# source <(kubectl completion zsh)

# =============================================================================
# thefuck - Command correction tool
# =============================================================================

eval $(thefuck --alias)

# =============================================================================
# OpenCode - Experimental Features
# =============================================================================

# Enable LSP integration with OpenCode
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
export OPENCODE_ENABLE_EXA=1

# Add OpenCode to PATH
export PATH="${DOTFILES_HOME}/.opencode/bin:$PATH"

# =============================================================================
# Antigravity
# =============================================================================

export PATH="${DOTFILES_HOME}/.antigravity/antigravity/bin:$PATH"

# =============================================================================
# envman
# =============================================================================

# Load envman if available
[ -s "${DOTFILES_HOME}/.config/envman/load.sh" ] && source "${DOTFILES_HOME}/.config/envman/load.sh"
