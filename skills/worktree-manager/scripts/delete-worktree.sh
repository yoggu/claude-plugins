#!/bin/bash
# Delete a git worktree (keeps the branch for merging)
# Usage: delete-worktree.sh <feature-name>

set -e

feature="$1"

if [[ -z "$feature" ]]; then
  echo "Usage: delete-worktree.sh <feature-name>"
  exit 1
fi

# Ensure we're inside a git repo
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: not inside a git repository."
  exit 1
}

repo_name="$(basename "$repo_root")"
worktrees_dir="$HOME/worktrees/${repo_name}"
worktree_path="${worktrees_dir}/${feature}"

if [[ ! -d "$worktree_path" ]]; then
  echo "Error: worktree not found at: $worktree_path"
  exit 1
fi

# Safety: refuse to delete if path looks weird
if [[ "$worktree_path" == "/" || "$worktree_path" == "$HOME" ]]; then
  echo "Error: refusing to delete unsafe path: $worktree_path"
  exit 1
fi

# Remove the worktree registration but KEEP the branch
echo "Removing worktree registration..."
git -C "$repo_root" worktree remove --force "$worktree_path" 2>/dev/null || true

# Ensure folder is gone (without touching the branch)
if [[ -d "$worktree_path" ]]; then
  rm -rf "$worktree_path" || {
    echo "Error: failed to delete folder: $worktree_path"
    exit 1
  }
fi

echo ""
echo "✅ Deleted worktree folder: $worktree_path"
echo "   Branch '$feature' was NOT deleted (ready for merging)"
