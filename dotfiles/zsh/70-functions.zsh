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
  local issue_key="$1"
  local base_branch="$2"

  if [[ -z "$issue_key" || -z "$base_branch" ]]; then
    echo "❌ Usage: create_worktree <ISSUE-KEY> <base-branch>"
    return 1
  fi

  # git-common-dir resolves to the bare repo's .git dir, regardless of which
  # worktree (main, dev, other-issue, ...) you're currently in.
  local git_common_dir
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  [[ -z "$git_common_dir" ]] && echo "❌ Not in a git repository" && return 1

  local container
  container=$(cd "$(dirname "$git_common_dir")" && pwd)

  local repo_name
  repo_name=$(basename "$container")

  local worktree_path="${container}/${issue_key}"
  if [[ -e "$worktree_path" ]]; then
    echo "❌ Worktree path already exists: $worktree_path"
    return 1
  fi

  echo "📦 Repository: $repo_name"
  echo "🎫 Issue:      $issue_key"
  echo "🌿 Base:       $base_branch"
  echo ""

  echo "🔄 Fetching latest ${base_branch}..."
  if ! git --git-dir="$git_common_dir" fetch origin "+refs/heads/${base_branch}:refs/remotes/origin/${base_branch}"; then
    echo "❌ Failed to fetch ${base_branch} from origin"
    return 1
  fi

  echo ""
  echo "🔨 Creating worktree: $issue_key"
  if ! git --git-dir="$git_common_dir" worktree add -b "$issue_key" "$worktree_path" "origin/${base_branch}"; then
    echo "❌ Failed to create worktree"
    return 1
  fi

  local abs_worktree_path
  abs_worktree_path=$(cd "$worktree_path" && pwd)
  echo "✅ Worktree created!"
  echo "📍 Path: $abs_worktree_path"
  echo ""

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


checkout_worktree() {
  local branch="$1"

  if [[ -z "$branch" ]]; then
    echo "❌ Usage: checkout_worktree <branch-name>"
    return 1
  fi

  # git-common-dir resolves to the bare repo's .git dir, regardless of which
  # worktree (main, dev, other-issue, ...) you're currently in.
  local git_common_dir
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  [[ -z "$git_common_dir" ]] && echo "❌ Not in a git repository" && return 1

  local container
  container=$(cd "$(dirname "$git_common_dir")" && pwd)

  local repo_name
  repo_name=$(basename "$container")

  # Use only the last path component of the branch name as folder name
  local folder_name="${branch##*/}"
  local worktree_path="${container}/${folder_name}"
  if [[ -e "$worktree_path" ]]; then
    echo "❌ Worktree path already exists: $worktree_path"
    return 1
  fi

  echo "📦 Repository: $repo_name"
  echo "🌿 Branch:     $branch"
  echo "📍 Folder:     $folder_name"
  echo ""

  echo "🔄 Fetching latest ${branch}..."
  if ! git --git-dir="$git_common_dir" fetch origin "+refs/heads/${branch}:refs/remotes/origin/${branch}"; then
    echo "❌ Failed to fetch ${branch} from origin"
    return 1
  fi

  echo ""
  echo "🔨 Creating worktree: $folder_name"
  # If a local branch with this name already exists, just check it out;
  # otherwise create a local tracking branch from origin/<branch>.
  if git --git-dir="$git_common_dir" show-ref --verify --quiet "refs/heads/${branch}"; then
    if ! git --git-dir="$git_common_dir" worktree add "$worktree_path" "$branch"; then
      echo "❌ Failed to create worktree"
      return 1
    fi
  else
    if ! git --git-dir="$git_common_dir" worktree add -b "$branch" "$worktree_path" "origin/${branch}"; then
      echo "❌ Failed to create worktree"
      return 1
    fi
  fi

  local abs_worktree_path
  abs_worktree_path=$(cd "$worktree_path" && pwd)
  echo "✅ Worktree created!"
  echo "📍 Path: $abs_worktree_path"
  echo ""

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
alias gcwt='checkout_worktree'

alias tmux-save='tmux list-sessions -F "#{session_name}" > ~/.tmux_sessions_last.txt'
