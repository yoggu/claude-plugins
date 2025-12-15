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

### Step 3: Interactive Project Selection

Use `AskUserQuestion` with multiple questions to show projects across tabs/pages. Each project type gets its own prompt.

**Rules:**
- Separate prompts by project type (Drupal first, then Node.js if both selected)
- Split projects into batches of 4 per page (max 4 options per question)
- Max 4 pages per prompt (max 4 questions per AskUserQuestion)
- Only add additional prompts if projects don't fit in one prompt (>16 projects of same type)
- Question text must be unique - include page number (e.g., "1/3", "2/3")

**Example for 11 Node.js projects - 3 pages in one prompt:**
```json
{
  "questions": [
    {
      "question": "Select Node.js projects to update (1/3):",
      "header": "Page 1",
      "multiSelect": true,
      "options": [
        {"label": "app-a [1.2.3]", "description": "/path/to/app-a"},
        {"label": "app-b [2.0.0]", "description": "/path/to/app-b"},
        {"label": "app-c [1.0.0]", "description": "/path/to/app-c"},
        {"label": "app-d [3.1.0]", "description": "/path/to/app-d"}
      ]
    },
    {
      "question": "Select Node.js projects to update (2/3):",
      "header": "Page 2",
      "multiSelect": true,
      "options": [
        {"label": "app-e [1.5.0]", "description": "/path/to/app-e"},
        {"label": "app-f [2.1.0]", "description": "/path/to/app-f"},
        {"label": "app-g [1.0.0]", "description": "/path/to/app-g"},
        {"label": "app-h [4.0.0]", "description": "/path/to/app-h"}
      ]
    },
    {
      "question": "Select Node.js projects to update (3/3):",
      "header": "Page 3",
      "multiSelect": true,
      "options": [
        {"label": "app-i [1.2.0]", "description": "/path/to/app-i"},
        {"label": "app-j [2.0.0]", "description": "/path/to/app-j"},
        {"label": "app-k [1.1.0]", "description": "/path/to/app-k"}
      ]
    }
  ]
}
```

- Sort projects alphabetically by name
- Include version in label, path in description
- User navigates tabs with Tab/Arrow, selects with Space, submits with Enter
- Combine selections from all pages after submission

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
