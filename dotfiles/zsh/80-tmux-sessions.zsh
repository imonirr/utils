# 80-tmux-sessions.zsh
# Tmux session management with Azure, GitHub, and Kubernetes context switching

# =============================================================================
# Secrets Management
# =============================================================================

# Secrets are per-session: ~/.config/session-secrets/<session>.zsh (chmod 600)
SESSION_SECRETS_DIR="$HOME/.config/session-secrets"

# Unset every variable defined in any session secrets file so contexts don't leak
function secrets-clear {
    local f name
    # ~/.envrc is sourced from profile.zsh, so include it when clearing
    for f in "$SESSION_SECRETS_DIR"/*.zsh(N) "$HOME/.envrc"(N); do
        for name in ${(f)"$(grep -oE '^(export )?[A-Za-z_][A-Za-z0-9_]*=' "$f" 2>/dev/null | sed -E 's/^export //; s/=$//')"}; do
            unset "$name"
        done
    done
}

# Load secrets for one session (work, softcode, imonir)
function secrets-load {
    local file="$SESSION_SECRETS_DIR/$1.zsh"
    [[ -r "$file" ]] || { echo "⚠️  No secrets file: $file" >&2; return 0; }
    source "$file" || echo "❌ Failed to load $file" >&2
}

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
    export KUBECONFIG="$HOME/.kube/config-sj"


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
    # export KUBECONFIG="$HOME/.kube/config-softcode"
    # aks-ensure-creds "$AKS_SOFTCODE_NAME" "$AKS_SOFTCODE_RG"
}

# =============================================================================
# GitHub Environment Switching Functions
# =============================================================================

function github-sj {
    # export GH_CONFIG_DIR="$HOME/.config/gh-sj"
    export GH_ENV="SJ"
    export GH_HOST="sj.ghe.com"
    export GITHUB_ENTERPRISE_URL="https://sj.ghe.com"
    export COPILOT_ENTERPRISE_URI="sj.ghe.com"
    export COPILOT_ENV="SJ"

    # Switch Copilot config via symlink
    # rm -f "$HOME/.config/github-copilot"
    # ln -s "$HOME/.config/github-copilot-sj" "$HOME/.config/github-copilot"

    # export OPENCODE_CONFIG=/path/to/my/custom-config.json
    # Switch OpenCode auth config directory
    # rm -f "$HOME/.local/share/opencode"
    # ln -s "$HOME/.local/share/opencode-sj" "$HOME/.local/share/opencode"

    # switch opencode config
    # rm "$HOME/.config/opencode/opencode.json"
    # ln -s "$HOME/.config/opencode-sj.json" "$HOME/.config/opencode/opencode.json"
    # export OPENCODE_CONFIG_DIR="$HOME/.config/opencode-sj"
}

function github-softcode {
    # export GH_CONFIG_DIR="$HOME/.config/gh-softcode"
    export GH_ENV="Softcode"
    export COPILOT_ENV="Imonir"

    # Switch Copilot config via symlink - use imonir Copilot
    # rm -f "$HOME/.config/github-copilot"
    # ln -s "$HOME/.config/github-copilot-imonir" "$HOME/.config/github-copilot"

    # rm -f "$HOME/.local/share/opencode"
    # ln -s "$HOME/.local/share/opencode-imonir" "$HOME/.local/share/opencode"
}

function github-imonir {
    # export GH_CONFIG_DIR="$HOME/.config/gh-imonir"
    export GH_ENV="Imonir"
    export COPILOT_ENV="Imonir"

    # Switch Copilot config via symlink
    # rm -f "$HOME/.config/github-copilot"
    # ln -s "$HOME/.config/github-copilot-imonir" "$HOME/.config/github-copilot"

    # Switch OpenCode auth config directory
    # ln -s "$HOME/.local/share/opencode-imonir" "$HOME/.local/share/opencode"
    # ln -s "$HOME/.config/opencode-imonir" "$HOME/.config/opencode"
    # export OPENCODE_CONFIG_DIR="$HOME/.config/opencode-imonir"
}

# =============================================================================
# Session Management Functions (Combined Azure + GitHub + Tmux)
# =============================================================================

function session-sj {
    azure-sj
    github-sj

    # 1. Isolate the config directories for Work
    export XDG_CONFIG_HOME="$HOME/.config-sj"
    export XDG_DATA_HOME="$HOME/.local-sj"
    export XDG_CACHE_HOME="$HOME/.cache-sj"
    export NPM_CONFIG_USERCONFIG="$HOME/.config-sj/.npmrc"
    # alias mvn="mvn -s $HOME/.config-sj/maven-settings.xml"

    # Source SJ-specific aliases
    if [ -f "$HOME/.zsh_aliases_sj" ]; then
      source "$HOME/.zsh_aliases_sj"
    fi

    # Run setup only once per session
    if [[ -n "$TMUX" ]] && [[ -z "$TMUX_SESSION_SETUP_DONE" ]]; then
        tmux set-environment TMUX_SESSION_SETUP_DONE 1
    fi

}

function session-softcode {
    azure-softcode
    github-softcode

    # 1. Isolate the config directories for Work
    export XDG_CONFIG_HOME="$HOME/.config-softcode"
    export XDG_DATA_HOME="$HOME/.local-softcode"
    export XDG_CACHE_HOME="$HOME/.cache-softcode"

    # Run setup only once per session
    if [[ -n "$TMUX" ]] && [[ -z "$TMUX_SESSION_SETUP_DONE" ]]; then
        tmux set-environment TMUX_SESSION_SETUP_DONE 1
    fi
}

function session-imonir {
    azure-imonir  # Use Softcode Azure/AKS
    github-imonir

    # 1. Isolate the config directories for Work
    export XDG_CONFIG_HOME="$HOME/.config-imonir"
    export XDG_DATA_HOME="$HOME/.local-imonir"
    export XDG_CACHE_HOME="$HOME/.cache-imonir"

    # Run setup only once per session
    if [[ -n "$TMUX" ]] && [[ -z "$TMUX_SESSION_SETUP_DONE" ]]; then
        tmux set-environment TMUX_SESSION_SETUP_DONE 1
    fi
}

# =============================================================================
# Automatic Session Detection Based on Tmux Session Name
# =============================================================================


# If not running interactively, don't do anything
# [[ $- != *i* ]] && return

# Switch to correct az + github account based on tmux session name
if [[ -n $TMUX ]]; then
# if [[ -n $TMUX ]] && [[ -z "$TMUX_SESSION_SETUP_DONE" ]]; then
  secrets-clear
  case "$(tmux display-message -p '#S')" in
    sj|sj-*)
      session-sj
      secrets-load sj
      echo "✨ Session: SJ (Azure: $AZURE_ENV, AKS: SJ, GitHub: $GH_ENV, Copilot: $COPILOT_ENV)"
      ;;
    softcode|softcode-*)
      session-softcode
      secrets-load softcode
      echo "✨ Session: Softcode (Azure: $AZURE_ENV, AKS: Softcode, GitHub: $GH_ENV, Copilot: $COPILOT_ENV)"
      ;;
    imonir|imonir-*)
      session-imonir
      secrets-load imonir
      echo "✨ Session: Imonir (Azure: $AZURE_ENV, AKS: Imonir, GitHub: $GH_ENV, Copilot: $COPILOT_ENV)"
      ;;
  esac
fi

# =============================================================================
# Command Wrappers with Safety Checks
# =============================================================================

# Prevent running az command without any context
# az() {
#   if [[ -z "$AZURE_CONFIG_DIR" ]]; then
#     echo "❌ AZURE_CONFIG_DIR not set"
#     return 1
#   fi
#   command az "$@"
# }

# Prevent running kubectl command without any context
kubectl() {
  if [[ -z "$KUBECONFIG" ]]; then
    echo "❌ KUBECONFIG not set"
    return 1
  fi
  command kubectl "$@"
}

# Prevent running gh command without any context
# gh() {
#   if [[ -z "$GH_CONFIG_DIR" ]]; then
#     echo "❌ GH_CONFIG_DIR not set"
#     return 1
#   fi
#   command gh "$@"
# }


alias work="cd $HOME/work/softcode && tmux new-session -A -s softcode"
alias softcode="cd $HOME/work/softcode && tmux new-session -A -s softcode"
alias imonir="cd $HOME/work/imonir && tmux new-session -A -s imonir"
