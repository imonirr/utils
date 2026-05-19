#!/usr/bin/env bash
set -e

# Ensure we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

# Extract Jira key from branch name (e.g. ABC-123)
JIRA_KEY=$(echo "$BRANCH" | grep -o '[A-Z]\+-[0-9]\+' || true)

if [ -z "$JIRA_KEY" ]; then
    echo "❌ No Jira key found in branch name"
    exit 1
fi

echo "📌 Branch: $BRANCH"
echo "📌 Jira:   $JIRA_KEY"

# Push branch
git push -u origin "$BRANCH"

PR_DESC_FILE=".git/PR_DESCRIPTION.md"

if [ -f "$PR_DESC_FILE" ]; then
    echo "🧠 Using PR description from $PR_DESC_FILE"
    DESCRIPTION=$(cat "$PR_DESC_FILE")
else
    echo "📝 Collecting commit summary…"
    COMMITS=$(git log "$BASE_BRANCH..HEAD" --oneline)
    DESCRIPTION=$(
        cat <<EOF
## Changes
$COMMITS
EOF
    )
fi

# Get repository in format "owner/repo" - try multiple methods
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true)

# Fallback: extract from git remote URL
if [ -z "$REPO" ]; then
    REMOTE_URL=$(git config --get remote.origin.url)
    REPO=$(echo "$REMOTE_URL" | sed -n 's#.*[:/]\([^/]*\)/\([^/.]*\)\(\.git\)\?$#\1/\2#p')
fi

if [ -z "$REPO" ]; then
    echo "❌ Could not determine repository. Make sure remote is configured correctly."
    exit 1
fi

echo "📦 Repository: $REPO"

# Get PR title
PR_TITLE=$(git log -1 --pretty=%s)
echo "Creating draft PR: $PR_TITLE"

# Create draft PR in GitHub - use --repo as separate argument
PR_URL=$(
    gh pr create \
        --repo "$REPO" \
        --draft \
        --base "$BASE_BRANCH" \
        --title "$PR_TITLE" \
        --body "$DESCRIPTION"
)

if [ -z "$PR_URL" ]; then
    echo "❌ Failed to create PR"
    exit 1
fi

echo "✅ PR created:"
echo "$PR_URL"

# Open in browser (macOS & Linux compatible)
if command -v open >/dev/null; then
    open -a "Google Chrome" "$PR_URL"
elif command -v xdg-open >/dev/null; then
    xdg-open "$PR_URL"
fi
