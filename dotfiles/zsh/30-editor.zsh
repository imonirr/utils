# 30-editor.zsh
# Editor configuration for local and remote sessions

# =============================================================================
# Locale Settings
# =============================================================================

export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# =============================================================================
# Preferred Editor
# =============================================================================

# Use neovim-remote (nvr) when inside a neovim terminal
# This allows opening files in the parent neovim instance
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    export VISUAL="nvim"
    export EDITOR="nvim"
fi

# =============================================================================
# Compilation Flags
# =============================================================================

export ARCHFLAGS="-arch x86_64"

# =============================================================================
# SSH
# =============================================================================

export SSH_KEY_PATH="~/.ssh/id_ed25519"
