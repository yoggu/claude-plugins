---
name: update-orchestrator
description: "Orchestrate dependency updates across multiple projects. Use when asked to update multiple sites, batch update projects, manage updates across a portfolio of Drupal sites or Node.js projects, or run updates on several projects at once. Supports both Drupal (Composer) and Node.js (npm) projects."
allowed-tools: Bash(ddev:*), Bash(npm:*), Bash(git:*), Bash(gh:*), Bash(composer:*), Read, Task
---

# Update Orchestrator

Orchestrate dependency updates across multiple Drupal and Node.js projects using subagents for parallel execution.

## Prerequisites

- `drupal-updates` skill available (for Drupal projects)
- `node-modules-update` skill available (for Node.js projects)

## Workflow

### Step 1: Discover Projects

Run the discovery script to find all projects in the current directory. Use the base directory provided at the top of this skill prompt:

```bash
{base_directory}/scripts/discover_projects.sh
```

Replace `{base_directory}` with the actual "Base directory for this skill" path shown above.

Output format:
```json
[
  {"path": "/path/to/site-a", "name": "site-a", "type": "drupal", "version": "10.4.6"},
  {"path": "/path/to/app-b", "name": "app-b", "type": "node", "version": "1.2.3"}
]
```

### Step 2: Ask Project Type

Ask the user what type of projects to update:

```
What type of projects do you want to update?
1. Drupal projects only
2. Node.js projects only
3. Both Drupal and Node.js
```

### Step 3: Project Selection by Type

Based on user's choice, show the relevant project lists separately:

**If Drupal selected:**
```
=== Drupal Projects ===
1. [10.4.6] site-a
2. [10.5.2] site-b
3. [10.3.1] site-c

Enter project numbers to update (e.g., 1,3 or 1-3 or all):
```

**If Node.js selected:**
```
=== Node.js Projects ===
1. [1.2.3] app-a
2. [2.0.0] app-b

Enter project numbers to update (e.g., 1,3 or 1-3 or all):
```

**If both selected:** Show Drupal list first, collect selection, then show Node.js list.

Parse user input:
- Single numbers: `1` or `3`
- Comma-separated: `1,3,5`
- Ranges: `1-3` (expands to 1,2,3)
- All: `all` or `*`
- Skip: `none` or `skip` (for skipping a category when both selected)

### Step 4: Launch Subagent Updates

For each selected project, launch a subagent using the Task tool:

```
Use the Task tool with subagent_type="general-purpose" for each project:

Prompt template:
"Update the project at {path}.
Project type: {type}
Use the {skill-name} skill workflow.
After creating the PR, return the PR URL.
If the update fails, return the error message."
```

**Subagent configuration:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `run_in_background`: true (to run updates in parallel)
- Wait for all subagents to complete using TaskOutput

**Important:** Each subagent must return:
- Status: success or failure
- PR URL (if successful)
- Error message (if failed)

### Step 5: Collect Results

Use TaskOutput to collect results from all subagents. Parse each result for:
- Success/failure status
- PR URL (extract from subagent output)
- Error details if failed

### Step 6: Summary

After all updates complete, display a summary with PR links:

```
=== Update Summary ===

Drupal Projects (2):
✓ site-a
  PR: https://bitbucket.org/workspace/site-a/pull-requests/123
✓ site-b
  PR: https://bitbucket.org/workspace/site-b/pull-requests/456

Node.js Projects (1):
✓ app-a
  PR: https://github.com/org/app-a/pull/789

Failed (1):
✗ app-b (Node)
  Error: Build failed - TypeScript compilation errors

Total: 3 successful, 1 failed
```

## Scripts

### discover_projects.sh
Finds Drupal and Node.js projects in the current directory (1 level deep). Outputs JSON array with path, name, type, and version for each project.
