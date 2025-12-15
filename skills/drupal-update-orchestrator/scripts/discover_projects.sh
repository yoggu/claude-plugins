#!/bin/bash
# Discover Drupal and Node.js projects in the current directory (1 level deep)
# Outputs JSON array of project info: path, name, type, version

set -e

SEARCH_DIR="${1:-$(pwd)}"

# Check if a directory contains a Drupal project
is_drupal_project() {
    local dir="$1"
    local composer_json="$dir/composer.json"

    [[ -f "$composer_json" ]] || return 1

    # Check for drupal/core in require section
    grep -q '"drupal/core"' "$composer_json" 2>/dev/null || \
    grep -q '"drupal/core-recommended"' "$composer_json" 2>/dev/null
}

# Check if a directory contains a Node.js project (but not Drupal)
is_node_project() {
    local dir="$1"
    local package_json="$dir/package.json"

    [[ -f "$package_json" ]] || return 1

    # Make sure it's not a Drupal project (which may also have package.json)
    ! is_drupal_project "$dir"
}

# Get Drupal version from composer.lock
get_drupal_version() {
    local dir="$1"
    local composer_lock="$dir/composer.lock"

    if [[ -f "$composer_lock" ]]; then
        grep -A 5 '"name": "drupal/core"' "$composer_lock" 2>/dev/null | \
        grep '"version"' | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/'
    else
        echo "unknown"
    fi
}

# Get Node.js project version from package.json
get_node_version() {
    local dir="$1"
    local package_json="$dir/package.json"

    if [[ -f "$package_json" ]]; then
        grep '"version"' "$package_json" 2>/dev/null | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/'
    else
        echo "unknown"
    fi
}

# Main discovery logic
discover_projects() {
    local first=true
    echo "["

    [[ ! -d "$SEARCH_DIR" ]] && echo "]" && exit 0

    # Find immediate subdirectories
    for project_dir in "$SEARCH_DIR"/*/; do
        [[ ! -d "$project_dir" ]] && continue
        project_dir="${project_dir%/}"  # Remove trailing slash

        project_name=$(basename "$project_dir")
        project_type=""
        project_version=""

        if is_drupal_project "$project_dir"; then
            project_type="drupal"
            project_version=$(get_drupal_version "$project_dir")
        elif is_node_project "$project_dir"; then
            project_type="node"
            project_version=$(get_node_version "$project_dir")
        else
            continue  # Skip non-project directories
        fi

        if $first; then
            first=false
        else
            echo ","
        fi

        # Output JSON object
        printf '  {"path": "%s", "name": "%s", "type": "%s", "version": "%s"}' \
            "$project_dir" "$project_name" "$project_type" "$project_version"
    done

    echo ""
    echo "]"
}

# Run discovery
discover_projects
