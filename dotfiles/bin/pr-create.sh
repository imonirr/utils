#!/usr/bin/env bash
set -e

BRANCH=$(git branch --show-current)
BASE_BRANCH="master"

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

# Create draft PR in Azure DevOps

PR_URL=$(
    az repos pr create \
        --draft \
        --source-branch "$BRANCH" \
        --target-branch "$BASE_BRANCH" \
        --title "$(git log -1 --pretty=%s)" \
        --description "$DESCRIPTION" \
        --query "webUrl" \
        --output tsv
)

echo "✅ PR created:"
echo "$PR_URL"

# Open in browser (macOS & Linux compatible)
if command -v open >/dev/null; then
    open -a "Google Chrome" "$PR_URL"
elif command -v xdg-open >/dev/null; then
    xdg-open "$PR_URL"
fi
