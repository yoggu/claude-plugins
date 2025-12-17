#!/bin/bash
# Create a git worktree for feature development
# Usage: create-worktree.sh <feature-name>

set -e

feature="$1"

if [[ -z "$feature" ]]; then
  echo "Usage: create-worktree.sh <feature-name>"
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

# Create base + repo-specific folder
mkdir -p "$worktrees_dir" || {
  echo "Error: could not create worktrees dir: $worktrees_dir"
  exit 1
}

# If worktree already exists, bail
if [[ -e "$worktree_path" ]]; then
  echo "Error: worktree path already exists: $worktree_path"
  exit 1
fi

# Fetch latest refs to avoid branching from stale main
echo "Fetching latest refs..."
git -C "$repo_root" fetch --all --prune >/dev/null 2>&1

# Determine base branch: prefer main, fallback to master
base_branch="main"
if ! git -C "$repo_root" show-ref --verify --quiet "refs/heads/main" \
   && ! git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/main"; then
  base_branch="master"
fi

echo "Creating worktree from $base_branch..."

# Create worktree + new branch from base branch
git -C "$repo_root" worktree add -b "$feature" "$worktree_path" "$base_branch" || {
  echo "Error: git worktree add failed."
  exit 1
}

# Copy over dotfiles (hidden files/dirs) at repo root
echo "Copying dotfiles..."
shopt -s dotglob nullglob
for p in "$repo_root"/.*; do
  name="$(basename "$p")"
  case "$name" in
    .|..|.git) continue ;;
  esac
  rsync -a "$p" "$worktree_path"/
done
shopt -u dotglob nullglob

# Copy ignored files (tracked by .gitignore)
echo "Copying gitignored files..."
ignored="$(git -C "$repo_root" ls-files -o -i --exclude-standard 2>/dev/null || true)"
if [[ -n "$ignored" ]]; then
  (cd "$repo_root" && printf "%s\0" $ignored) | \
    rsync -a --from0 --files-from=- "$repo_root"/ "$worktree_path"/
fi

# Open in VS Code (new window) and start Claude extension
if command -v code >/dev/null 2>&1; then
  echo "Opening VS Code with Claude..."
  code -n "$worktree_path"
  # Wait a moment for VS Code to open, then trigger Claude
  sleep 2
  code --command claude.open 2>/dev/null || true
else
  echo "Note: 'code' command not found. Install VS Code shell command or open manually:"
  echo "  $worktree_path"
fi

echo ""
echo "✅ Worktree created at: $worktree_path"
echo "   Branch: $feature (based on $base_branch)"
