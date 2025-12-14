---
name: drupal-update-orchestrator
description: "Orchestrate Drupal updates across multiple projects. Use when asked to update multiple Drupal sites, batch update Drupal projects, manage updates across a portfolio of Drupal sites, or run Drupal updates on several projects at once."
---

# Drupal Update Orchestrator

Orchestrate Drupal core and module updates across multiple projects with automated discovery, user selection, and sequential execution.

## Prerequisites

- Claude CLI installed and configured
- Config file at `~/.config/drupal-update-orchestrator/config.yml`
- `drupal-updates` skill available (for individual project updates)

## Configuration

Create the config file at `~/.config/drupal-update-orchestrator/config.yml`:

```yaml
search_directories:
  - ~/Sites
  - ~/Projects/drupal
```

See [references/config-example.yml](references/config-example.yml) for full example.

## Workflow

### Step 1: Discover Projects

Run the discovery script to find Drupal projects:

```bash
~/.claude/skills/drupal-update-orchestrator/scripts/discover_projects.sh
```

The script scans configured directories for subdirectories containing composer.json with drupal/core dependency.

Output format:
```json
[
  {"path": "/Users/name/Sites/project-a", "name": "project-a", "drupal_version": "10.4.6"},
  {"path": "/Users/name/Sites/project-b", "name": "project-b", "drupal_version": "10.5.2"}
]
```

### Step 2: User Selection

Present the discovered projects as a numbered list:

```
Available Drupal Projects:
1. project-a (Drupal 10.4.6)
2. project-b (Drupal 10.5.2)
3. project-c (Drupal 10.3.1)

Enter project numbers to update (e.g., 1,3 or 1-3 or all):
```

Parse user input:
- Single numbers: `1` or `3`
- Comma-separated: `1,3,5`
- Ranges: `1-3` (expands to 1,2,3)
- All: `all` or `*`

### Step 3: Launch Interactive Terminals

Launch each selected project in a new Terminal window with an interactive Claude session:

```bash
# Launch each update in a new Terminal window
~/.claude/skills/drupal-update-orchestrator/scripts/run_update.sh /path/to/project-a
~/.claude/skills/drupal-update-orchestrator/scripts/run_update.sh /path/to/project-b
~/.claude/skills/drupal-update-orchestrator/scripts/run_update.sh /path/to/project-c
```

The script:
1. Opens a new Terminal window
2. Changes to the project directory
3. Launches Claude with the drupal-updates skill in interactive mode
4. User can interact with each Claude session directly

**Note**: Each project opens in its own Terminal window, allowing the user to monitor progress and interact with the update process as needed.

### Step 4: Summary

After launching all terminals, display a summary of opened sessions:

```
=== Drupal Multi-Update Summary ===

Opened interactive Terminal sessions for:
- project-a
- project-b
- project-c

You can now interact with each Claude session in its own Terminal window.
```

## Scripts

### discover_projects.sh
Finds Drupal projects in configured directories. Checks composer.json for drupal/core dependency. Outputs JSON array.

### run_update.sh
Opens a new Terminal window with an interactive Claude session for a single project. The user can interact with Claude directly to guide the update process.
