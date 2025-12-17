---
name: worktree-manager
description: "Manage git worktrees for feature development. Use when asked to create a new worktree, delete/remove a worktree, list worktrees, or work on features in isolation. Creates worktrees at ~/worktrees/{repo}/{feature}, copies .env and dotfiles, opens VS Code with Claude extension."
---

# Worktree Manager

Manage git worktrees for isolated feature development.

## Operations

### Create Worktree

Create a new worktree for feature development:

```bash
./scripts/create-worktree.sh <feature-name>
```

**What it does:**
1. Creates worktree at `~/worktrees/{repo-name}/{feature-name}`
2. Creates new branch `{feature-name}` from main/master
3. Copies all dotfiles (.env, .envrc, etc.) from main repo
4. Copies all gitignored files
5. Opens VS Code in new window
6. Starts Claude extension

**Example:**
```
User: "Create a worktree for the new payment integration"
→ Run: ./scripts/create-worktree.sh payment-integration
```

### Delete Worktree

Remove a worktree (keeps branch for merging):

```bash
./scripts/delete-worktree.sh <feature-name>
```

**What it does:**
1. Unregisters worktree from git
2. Deletes the worktree folder
3. Keeps the branch intact for merging

**Example:**
```
User: "Delete the payment-integration worktree, I'm done with it"
→ Run: ./scripts/delete-worktree.sh payment-integration
```

### List Worktrees

Show all worktrees for current repository:

```bash
./scripts/list-worktrees.sh
```

**Example:**
```
User: "What worktrees do I have?"
→ Run: ./scripts/list-worktrees.sh
```

## Workflow

**Starting a feature:**
1. User is in main repository
2. User requests worktree creation with feature name
3. Script creates isolated environment with all dependencies
4. VS Code opens in new worktree with Claude ready

**Finishing a feature:**
1. User commits and pushes changes in worktree
2. User requests worktree deletion
3. Script removes worktree folder but keeps branch
4. User can merge branch via PR from main repository

## Notes

- Worktrees are stored in `~/worktrees/{repo-name}/`
- Scripts must be run from within the main git repository (not the worktree)
- The branch is preserved on delete to allow merging via PR
