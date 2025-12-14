#!/bin/bash
# Discover Drupal projects in configured directories
# Outputs JSON array of project info: path, name, drupal_version

set -e

CONFIG_FILE="${HOME}/.config/drupal-update-orchestrator/config.yml"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    echo "Create it based on the example in references/config-example.yml" >&2
    exit 1
fi

# Parse search directories from YAML config (basic parsing without yq)
parse_search_dirs() {
    local in_search_dirs=false
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # Check if we're in search_directories section
        if [[ "$line" =~ ^search_directories: ]]; then
            in_search_dirs=true
            continue
        fi

        # Check if we've hit another top-level key
        if [[ "$line" =~ ^[a-z_]+: && ! "$line" =~ ^[[:space:]]+ ]]; then
            in_search_dirs=false
            continue
        fi

        # Parse list items under search_directories
        if $in_search_dirs && [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.*) ]]; then
            dir="${BASH_REMATCH[1]}"
            # Expand tilde
            dir="${dir/#\~/$HOME}"
            echo "$dir"
        fi
    done < "$CONFIG_FILE"
}

# Check if a directory contains a Drupal project
is_drupal_project() {
    local dir="$1"
    local composer_json="$dir/composer.json"

    [[ -f "$composer_json" ]] || return 1

    # Check for drupal/core in require section
    grep -q '"drupal/core"' "$composer_json" 2>/dev/null || \
    grep -q '"drupal/core-recommended"' "$composer_json" 2>/dev/null
}

# Get Drupal version from composer.lock
get_drupal_version() {
    local dir="$1"
    local composer_lock="$dir/composer.lock"

    if [[ -f "$composer_lock" ]]; then
        # Extract version from composer.lock using basic grep/sed
        grep -A 5 '"name": "drupal/core"' "$composer_lock" 2>/dev/null | \
        grep '"version"' | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/'
    else
        echo "unknown"
    fi
}

# Main discovery logic
discover_projects() {
    local first=true
    echo "["

    while IFS= read -r search_dir; do
        [[ -z "$search_dir" ]] && continue
        [[ ! -d "$search_dir" ]] && continue

        # Find immediate subdirectories
        for project_dir in "$search_dir"/*/; do
            [[ ! -d "$project_dir" ]] && continue
            project_dir="${project_dir%/}"  # Remove trailing slash

            if is_drupal_project "$project_dir"; then
                project_name=$(basename "$project_dir")
                drupal_version=$(get_drupal_version "$project_dir")

                if $first; then
                    first=false
                else
                    echo ","
                fi

                # Output JSON object
                printf '  {"path": "%s", "name": "%s", "drupal_version": "%s"}' \
                    "$project_dir" "$project_name" "$drupal_version"
            fi
        done
    done < <(parse_search_dirs)

    echo ""
    echo "]"
}

# Run discovery
discover_projects
