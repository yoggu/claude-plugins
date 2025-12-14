#!/bin/bash
# Open a new Terminal window with interactive Claude session for Drupal updates
# Usage: run_update.sh <project_path>

PROJECT_PATH="$1"
PROJECT_NAME=$(basename "$PROJECT_PATH")

if [[ -z "$PROJECT_PATH" ]]; then
    echo "Error: No project path provided"
    exit 1
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Project directory not found: $PROJECT_PATH"
    exit 1
fi

# Open a new Terminal window with Claude in interactive mode
osascript -e "tell application \"Terminal\" to do script \"cd '$PROJECT_PATH' && claude 'Run the drupal-updates skill to update this project'\""

echo "Opened Terminal for: $PROJECT_NAME"
