---
name: update-orchestrator
description: "Orchestrate dependency updates across multiple projects. Use when asked to update multiple sites, batch update projects, manage updates across a portfolio of Drupal sites or Node.js projects, or run updates on several projects at once. Supports both Drupal (Composer) and Node.js (npm) projects."
allowed-tools: Bash(ddev:*), Bash(npm:*), Bash(git:*), Bash(gh:*), Bash(composer:*), Read
---

# Update Orchestrator

Orchestrate dependency updates across multiple Drupal and Node.js projects with automated discovery, user selection, and sequential execution.

## Prerequisites

- `drupal-updates` skill available (for Drupal projects)
- `node-modules-update` skill available (for Node.js projects)

## Workflow

### Step 1: Discover Projects

Run the discovery script to find all projects in the current directory:

```bash
~/.claude/skills/drupal-update-orchestrator/scripts/discover_projects.sh
```

The script scans subdirectories (1 level deep) and detects:
- **Drupal projects**: composer.json with drupal/core dependency
- **Node.js projects**: package.json without drupal/core

Output format:
```json
[
  {"path": "/Users/name/Sites/site-a", "name": "site-a", "type": "drupal", "version": "10.4.6"},
  {"path": "/Users/name/Sites/app-b", "name": "app-b", "type": "node", "version": "1.2.3"}
]
```

### Step 2: User Selection

Present the discovered projects as a numbered list showing type:

```
Available Projects:
1. [Drupal 10.4.6] site-a
2. [Drupal 10.5.2] site-b
3. [Node 1.2.3] app-c
4. [Node 2.0.0] app-d

Enter project numbers to update (e.g., 1,3 or 1-3 or all):
```

Parse user input:
- Single numbers: `1` or `3`
- Comma-separated: `1,3,5`
- Ranges: `1-3` (expands to 1,2,3)
- All: `all` or `*`

### Step 3: Sequential Updates

For each selected project, run the update in sequence:

1. **Change to project directory**
2. **Announce current project**: Display name and type
3. **Invoke appropriate skill**:
   - Drupal projects → use `drupal-updates` skill workflow
   - Node.js projects → use `node-modules-update` skill workflow
4. **Track result**: Record success or failure
5. **Continue to next project**

### Step 4: Summary

After all updates complete, display a summary:

```
=== Update Summary ===

Completed (3):
✓ site-a (Drupal) - PR created
✓ site-b (Drupal) - PR created
✓ app-c (Node) - PR created

Failed (1):
✗ app-d (Node) - Build failed

Total: 3 successful, 1 failed
```

## Scripts

### discover_projects.sh
Finds Drupal and Node.js projects in the current directory (1 level deep). Outputs JSON array with path, name, type, and version for each project.
