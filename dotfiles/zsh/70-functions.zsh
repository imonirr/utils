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
  git checkout main &&
  git pull &&
  git checkout "$branch" &&
  git rebase main
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


create_worktree() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -z "$branch" ]] && echo "❌ Not in a git repository" && return 1

  if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    echo "⚠️  Cannot create worktree from main/master branch"
    return 1
  fi

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  [[ -z "$repo_root" ]] && echo "❌ Could not find git repository root" && return 1

  local repo_name
  repo_name=$(basename "$repo_root")

  local issue_number
  issue_number=$(echo "$branch" | grep -oE '/[A-Z]+-[0-9]+' | grep -oE '[0-9]+$')
  if [[ -z "$issue_number" ]]; then
    echo "❌ Could not extract issue number from branch: $branch"
    return 1
  fi

  local worktree_name="${repo_name}-${issue_number}"
  local worktree_path="${repo_root}/../worktree/${worktree_name}"

  echo "📦 Repository: $repo_name"
  echo "🌿 Branch:     $branch"
  echo "🎫 Issuke:      #$issue_number"
  echo ""

  mkdir -p "$(dirname "$worktree_path")"
  echo "📁 Directory ready: $(dirname "$worktree_path")"

  echo "🔄 Switching to main branch..."
  if git -C "$repo_root" checkout main 2>/dev/null; then
    echo "✅ Switched to main"
  elif git -C "$repo_root" checkout master 2>/dev/null; then
    echo "✅ Switched to master"
  else
    echo "❌ Failed to checkout main or master"
    return 1
  fi

  echo ""
  echo "🔨 Creating worktree for branch: $branch"
  if ! git -C "$repo_root" worktree add "$worktree_path" "$branch"; then
    echo "❌ Failed to create worktree"
    return 1
  fi

  local abs_worktree_path
  abs_worktree_path=$(cd "$worktree_path" && pwd)
  echo "✅ Worktree created!"
  echo "📍 Path: $abs_worktree_path"
  echo ""

  # Copy AGENTS.md if it exists
  if [[ -f "${repo_root}/AGENTS.md" ]]; then
    echo "📄 Copying AGENTS.md..."
    cp "${repo_root}/AGENTS.md" "${abs_worktree_path}/AGENTS.md" \
      && echo "✅ AGENTS.md copied" || echo "❌ Failed to copy AGENTS.md"
  fi

  # Run install based on project type
  if [[ -f "${abs_worktree_path}/package.json" ]]; then
    echo "📦 Running npm install..."
    npm install --prefix "$abs_worktree_path" \
      && echo "✅ npm install completed" || echo "❌ npm install failed"
  elif [[ -f "${abs_worktree_path}/pom.xml" ]]; then
    echo "📦 Running mvn install..."
    (cd "$abs_worktree_path" && mvn install) \
      && echo "✅ mvn install completed" || echo "❌ mvn install failed"
  fi

  echo ""
  echo "📂 Switching to worktree..."
  cd "$abs_worktree_path" || return 1
  echo "✅ Done! Now in: $(pwd)"
}

alias gwt='create_worktree'
