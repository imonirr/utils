# 80-tmux-sessions.zsh
# Tmux session management with Azure, GitHub, and Kubernetes context switching

# =============================================================================
# Secrets Management
# =============================================================================

# Export secret variables from home directory
# This file should contain sensitive environment variables
[[ -f "${DOTFILES_HOME}/.secrets.sh" ]] && source "${DOTFILES_HOME}/.secrets.sh"

# =============================================================================
# Azure Environment Switching Functions
# =============================================================================

function azure-softcode {
    export AZURE_CONFIG_DIR=~/.Azure-Softcode
    export AZURE_ENV="Softcode"
}

function azure-sj {
    export AZURE_CONFIG_DIR=~/.Azure-SJ
    export AZURE_ENV="SJ"
    export KUBECONFIG="${DOTFILES_HOME}/.kube/config-sj"

    # AKS metadata
    AKS_SJ_NAME="aks-qa-trafik-weu"
    AKS_SJ_RG="aks-qa-trafik-weu-rg"
    aks-ensure-creds "$AKS_SJ_NAME" "$AKS_SJ_RG"
}

function azure-imonir {
    export AZURE_CONFIG_DIR=~/.Azure-Imonir
    export AZURE_ENV="Imonir"

    # export AKS_SOFTCODE_NAME="imonir-aks"
    # export AKS_SOFTCODE_RG="imonir-aks-rg"
    # export KUBECONFIG="${DOTFILES_HOME}/.kube/config-softcode"
    # aks-ensure-creds "$AKS_SOFTCODE_NAME" "$AKS_SOFTCODE_RG"
}

# =============================================================================
# GitHub Environment Switching Functions
# =============================================================================

function github-sj {
    export GH_CONFIG_DIR="${DOTFILES_HOME}/.config/gh-sj"
    export GH_ENV="SJ"
    export GH_HOST="sj.ghe.com"
    export GITHUB_ENTERPRISE_URL="https://sj.ghe.com"
    export COPILOT_ENTERPRISE_URI="sj.ghe.com"

    # Switch Copilot config via symlink
    rm -f "${DOTFILES_HOME}/.config/github-copilot"
    ln -s "${DOTFILES_HOME}/.config/github-copilot-sj" "${DOTFILES_HOME}/.config/github-copilot"

    # Switch OpenCode auth config directory
    ln -sfn "${DOTFILES_HOME}/.local/share/opencode-sj" "${DOTFILES_HOME}/.local/share/opencode"
    export OPENCODE_CONFIG_DIR="${DOTFILES_HOME}/.config/opencode-sj"
}

function github-softcode {
    export GH_CONFIG_DIR="${DOTFILES_HOME}/.config/gh-softcode"
    export GH_ENV="Softcode"

    # Switch Copilot config via symlink - use imonir Copilot
    rm -f "${DOTFILES_HOME}/.config/github-copilot"
    ln -s "${DOTFILES_HOME}/.config/github-copilot-imonir" "${DOTFILES_HOME}/.config/github-copilot"
}

function github-imonir {
    export GH_CONFIG_DIR="${DOTFILES_HOME}/.config/gh-imonir"
    export GH_ENV="Imonir"

    # Switch Copilot config via symlink
    rm -f "${DOTFILES_HOME}/.config/github-copilot"
    ln -s "${DOTFILES_HOME}/.config/github-copilot-imonir" "${DOTFILES_HOME}/.config/github-copilot"

    # Switch OpenCode auth config directory
    ln -sfn "${DOTFILES_HOME}/.local/share/opencode-imonir" "${DOTFILES_HOME}/.local/share/opencode"
    export OPENCODE_CONFIG_DIR="${DOTFILES_HOME}/.config/opencode-imonir"
}

# =============================================================================
# Session Management Functions (Combined Azure + GitHub + Tmux)
# =============================================================================

function session-sj {
    azure-sj
    github-sj

    # Source SJ-specific aliases
    if [ -f "${DOTFILES_HOME}/.zsh_aliases_sj" ]; then
      source "${DOTFILES_HOME}/.zsh_aliases_sj"
    fi

    # Source SJ work environment secrets
    if test -f "${DOTFILES_HOME}/work/sj/.env.secrets"; then
      export $(cat "${DOTFILES_HOME}/work/sj/.env.secrets" | xargs)
    fi

    # Change tmux default directory and cd to work directory
    if [[ -n "$TMUX" ]]; then
        tmux set-option default-path "${DOTFILES_HOME}/work/sj"
        cd "${DOTFILES_HOME}/work/sj"
    fi

    echo "✨ Session: SJ (Azure: SJ, AKS: SJ, GitHub: SJ, Copilot: SJ)"
}

function session-softcode {
    azure-softcode
    github-softcode

    # Change tmux default directory and cd to work directory
    if [[ -n "$TMUX" ]]; then
        tmux set-option default-path "${DOTFILES_HOME}/work/softcode"
        cd "${DOTFILES_HOME}/work/softcode"
    fi

    echo "✨ Session: Softcode (Azure: Softcode, AKS: Softcode, GitHub: Softcode, Copilot: Imonir)"
}

function session-imonir {
    azure-imonir  # Use Softcode Azure/AKS
    github-imonir

    # Change tmux default directory and cd to work directory
    if [[ -n "$TMUX" ]]; then
        tmux set-option default-path "${DOTFILES_HOME}/work/imonir"
        cd "${DOTFILES_HOME}/work/imonir"
    fi

    echo "✨ Session: Imonir (Azure: Imonir, AKS: Imonir, GitHub: Imonir, Copilot: Imonir)"
}

# =============================================================================
# Automatic Session Detection Based on Tmux Session Name
# =============================================================================

# Switch to correct az + github account based on tmux session name
if [[ -n "$TMUX" ]]; then
  case "$(tmux display-message -p '#S')" in
    sj)
      session-sj
      ;;
    softcode)
      session-softcode
      ;;
    imonir)
      session-imonir
      ;;
  esac
fi

# =============================================================================
# Command Wrappers with Safety Checks
# =============================================================================

# Prevent running az command without any context
az() {
  if [[ -z "$AZURE_CONFIG_DIR" ]]; then
    echo "❌ AZURE_CONFIG_DIR not set"
    return 1
  fi
  command az "$@"
}

# Prevent running kubectl command without any context
kubectl() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "❌ KUBECONFIG not set"
    return 1
  fi
  command kubectl "$@"
}

# Prevent running gh command without any context
gh() {
  if [[ -z "$GH_CONFIG_DIR" ]]; then
    echo "❌ GH_CONFIG_DIR not set"
    return 1
  fi
  command gh "$@"
}

# =============================================================================
# Tmux-Resurrect Environment Restoration
# =============================================================================

# Display restored environment information
if [[ -n "$TMUX" && -n "$AZURE_ENV" ]]; then
  echo "Restored Azure env: $AZURE_ENV"
fi

if [[ -n "$TMUX" && -n "$GH_ENV" ]]; then
  echo "Restored GitHub env: $GH_ENV"
fi

# =============================================================================
# Project-Specific Tool Aliases (SJ)
# =============================================================================

# Gustav script alias (SJ traffic control tools)
if test -f "${DOTFILES_HOME}/work/sj/traffic-control-tools/scripts/gustav/gustav.sh"; then
  alias gustav="${DOTFILES_HOME}/work/sj/traffic-control-tools/scripts/gustav/gustav.sh"
fi

# Gustav secrets
if test -f "${DOTFILES_HOME}/work/sj/traffic-control-tools/scripts/gustav/.env.secrets"; then
  export $(cat "${DOTFILES_HOME}/work/sj/traffic-control-tools/scripts/gustav/.env.secrets" | xargs)
fi
