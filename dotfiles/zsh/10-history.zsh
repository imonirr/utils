# 10-history.zsh
# Shell history configuration

# =============================================================================
# History File Configuration
# =============================================================================

export HISTFILE=~/.zsh_history
export HISTFILESIZE=999999999
export HISTSIZE=999999999

# =============================================================================
# History Timestamp Format
# =============================================================================

# Format: "mm/dd/yyyy"
HIST_STAMPS="mm/dd/yyyy"
export HISTTIMEFORMAT="[%F %T] "

# =============================================================================
# History Options
# =============================================================================

# Immediate append - ensures commands are added to history immediately
# (otherwise, this would happen only when the shell exits, and you could
# lose history upon unexpected/unclean termination of the shell)
setopt INC_APPEND_HISTORY

# Handling duplicate commands (while searching with Ctrl+R)
setopt HIST_FIND_NO_DUPS

# Not writing duplicates to the history file
setopt HIST_IGNORE_ALL_DUPS
