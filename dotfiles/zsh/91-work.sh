# =============================================================================
# Project-Specific Tool Aliases (SJ)
# =============================================================================

# Gustav script alias (SJ traffic control tools)
if test -f "$HOME/work/sj/traffic-control-tools/scripts/gustav/gustav.sh"; then
    alias gustav="$HOME/work/sj/traffic-control-tools/scripts/gustav/gustav.sh"
fi

# Gustav secrets
if test -f "$HOME/work/sj/traffic-control-tools/scripts/gustav/.env.secrets"; then
    export $(cat "$HOME/work/sj/traffic-control-tools/scripts/gustav/.env.secrets" | xargs)
fi
