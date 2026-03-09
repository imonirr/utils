# 70-functions.zsh
# Utility functions for common tasks

# =============================================================================
# Port Check
# =============================================================================

# Check if a port is in use
# Usage: portcheck 8080
portcheck() {
    sudo nc localhost $1 < /dev/null; echo $?
}

# =============================================================================
# Git Update Workflow
# =============================================================================

# Stash changes, update master, return to branch, and pop stash
# Usage: ggupdate
ggupdate() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git stash &&
  git checkout main &&
  git pull &&
  git checkout "$branch" &&
  git stash pop
}

# =============================================================================
# Azure Kubernetes Service (AKS) Credential Management
# =============================================================================

# Refresh AKS credentials (force overwrite)
# Usage: aks-refresh-creds <cluster-name> <resource-group>
aks-refresh-creds() {
  az aks get-credentials \
    --name "$1" \
    --resource-group "$2" \
    --overwrite-existing
}

# Ensure AKS credentials exist (fetch if missing)
# Usage: aks-ensure-creds <cluster-name> <resource-group>
aks-ensure-creds() {
  local cluster_name="$1"
  local resource_group="$2"

  if kubectl config get-contexts "$cluster_name" >/dev/null 2>&1; then
    return 0
  fi

  echo "🔐 Fetching AKS credentials for $cluster_name..."
  az aks get-credentials \
    --name "$cluster_name" \
    --resource-group "$resource_group" \
    --overwrite-existing

  kubectl config use-context "$cluster_name" >/dev/null 2>&1
}
