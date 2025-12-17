#!/bin/bash
# List all git worktrees for the current repository
# Usage: list-worktrees.sh

# Ensure we're inside a git repo
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: not inside a git repository."
  exit 1
}

repo_name="$(basename "$repo_root")"
worktrees_dir="$HOME/worktrees/${repo_name}"

echo "Worktrees for: $repo_name"
echo "─────────────────────────────────────────"
echo ""

# Use git worktree list for accurate information
git -C "$repo_root" worktree list --porcelain | while read -r line; do
  case "$line" in
    worktree\ *)
      path="${line#worktree }"
      ;;
    HEAD\ *)
      head="${line#HEAD }"
      ;;
    branch\ *)
      branch="${line#branch refs/heads/}"
      echo "📁 $path"
      echo "   Branch: $branch"
      echo ""
      ;;
    detached)
      echo "📁 $path"
      echo "   Branch: (detached HEAD at $head)"
      echo ""
      ;;
  esac
done

# Also check if there are worktrees in ~/worktrees/{repo} not registered
if [[ -d "$worktrees_dir" ]]; then
  registered=$(git -C "$repo_root" worktree list --porcelain | grep "^worktree " | sed 's/worktree //')
  for dir in "$worktrees_dir"/*/; do
    [[ -d "$dir" ]] || continue
    dir="${dir%/}"
    if ! echo "$registered" | grep -q "^${dir}$"; then
      echo "⚠️  $dir"
      echo "   (unregistered - may need cleanup)"
      echo ""
    fi
  done
fi
