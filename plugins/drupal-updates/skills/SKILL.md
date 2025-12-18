---
name: drupal-updates
description: "Perform Drupal core and contributed module updates using Composer. Use when asked to update Drupal core, contrib modules, check for updates, run database updates, or handle patch failures."
allowed-tools: Bash(ddev:*), Bash(git:*), Bash(gh:*), Bash(bb:*), Bash(composer:*), Read
---

# Drupal Updates Skill

Perform safe, systematic Drupal updates with proper version control, database updates, and configuration export.

## Prerequisites

- DDEV or Lando local development environment
- Composer-based Drupal project (drupal/recommended-project)
- Git version control
- Drush installed

## Update Scope

By default, this skill performs:
- Patch version updates (x.x.1 → x.x.2)
- Minor version updates (x.1.x → x.2.x)

This skill does not:
- Upgrade major versions (1.x.x → 2.x.x) - these often have breaking changes
- Modify composer.json - composer.lock is the expected change when using `composer update`

For major version upgrades: User should explicitly request them. Use `composer require` which modifies composer.json.

## Initialization

**Before any update, run these steps first:**

### 1. Start Development Environment
```bash
ddev start
# or: lando start
```

### 2. Sync Production Database
Ensure you're testing against current production data.

**Find the sync method for this project by checking:**

1. **README.md**: Look for documented database sync commands
2. **Taskfile.yaml**: Check for task commands like `task run -- sync-prod-db` or `task nn-ddev-sync-db-prod`
3. **nn/ or scripts/ directory**: Look for sync scripts
4. **Drush aliases**: Check `drush/sites/*.yml` for alias names like `@prod`, `@cloud.prod`

Common patterns:
```bash
# Taskfile-based projects
task run -- sync-prod-db

# Drush alias-based projects
ddev drush sql:sync @prod @self -y
ddev drush sql:sync @cloud.prod @self -y

# Lando projects
lando drush sql:sync @prod @self -y
```

After sync, always clear cache:
```bash
ddev drush cr
```

### 3. Update Local Main Branch
Ensure your local main/master branch is up to date:
```bash
git checkout main && git pull origin main
# or: git checkout master && git pull origin master
```

### 4. Create Feature Branch
Create a unique branch with timestamp for each update session:
```bash
git checkout -b feature/drupal-updates-$(date +%Y%m%d)
```

**IMPORTANT:** Never perform updates directly on master/main branch.

---

## Update Workflow

**Ensure Initialization steps are complete before proceeding.**

### 1. Check Available Updates
```bash
ddev composer outdated "drupal/*"
```

Review output for:
- `!` = patch/minor update recommended
- `~` = major update available - skip unless explicitly requested

### 2. Update Drupal Core
Update core packages together with dependencies:
```bash
ddev composer update "drupal/core-*" --with-all-dependencies
```

### 3. Update Contributed Modules
Update all Drupal modules within existing version constraints:
```bash
ddev composer update "drupal/*" --with-all-dependencies
```

### Major Version Upgrades (When Explicitly Requested)

Do not perform major version upgrades unless the user specifically asks.

If explicitly requested:
```bash
ddev composer require drupal/MODULE_NAME:^NEW_VERSION --with-all-dependencies
```

Note: This modifies composer.json and may introduce breaking changes.

### 4. Handle Patch Failures

If patches fail during update, check composer.json `extra.patches` section. Options:
- Find updated patch from drupal.org issue queue
- Remove patch if issue is fixed in new version
- Create custom patch if needed

### 5. Run Database Updates
```bash
ddev drush updb -y
```

Review and confirm any pending updates. Address errors before proceeding.

### 6. Export Configuration
```bash
ddev drush cex -y
```

### 7. Clear Cache
```bash
ddev drush cr
```

### 8. Verify Site Status
```bash
ddev drush status
```

Check for:
- Correct Drupal version
- Database connection
- Successful bootstrap

### 9. Test the Site

Run existing Playwright tests if the project has them. Otherwise, do a smoke test to verify the homepage loads.

### 10. Commit Changes
```bash
git add composer.json composer.lock config/sync/
```

**Commit message format** - include all updated packages with version changes:
```
chore: update Drupal core and contrib modules

Updated packages:
- drupal/core: 10.4.3 → 10.5.8
- drupal/admin_toolbar: 3.4.0 → 3.5.0
- drupal/paragraphs: 1.17.0 → 1.18.0
- drupal/webform: 6.2.3 → 6.2.5
...

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Use the output from step 1 (`composer outdated "drupal/*"`) to list all packages that were updated.

### 11. Create Pull Request

Push the branch and create a pull request:

```bash
git push -u origin HEAD
```

**Detect platform and create PR:**

Check the remote URL to determine the platform:
```bash
git remote get-url origin
```

- **GitHub** (github.com): `gh pr create --fill`
- **Bitbucket** (bitbucket.org):
  ```bash
  # Detect default branch (main or master)
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
  bb pullrequest create \
    --title "chore: update Drupal core and contrib modules" \
    --source "$(git branch --show-current)" \
    --destination "$DEFAULT_BRANCH"
  ```

## Common Issues

### Module Incompatibility
If status report shows "Incompatible module":
1. Check module's drupal.org page for compatible version
2. Update to compatible version: `ddev composer require drupal/MODULE:^NEW_VERSION`

### Entity/Field Definition Mismatches
Run entity updates:
```bash
ddev drush entity:updates
```

### Security Updates Only
For security-only updates:
```bash
ddev composer audit
ddev composer update --with-all-dependencies drupal/core-*
```

## Files Modified

Expected changes (normal update):
- `composer.lock` - Locked dependency versions
- `config/sync/` - Exported configuration changes

Not expected (unless explicitly requested):
- `composer.json` - Should not be modified during normal updates
- If composer.json was modified, verify it was intentional (major version upgrade)

## Rollback

If issues occur:
```bash
git checkout composer.json composer.lock
ddev composer install
ddev drush cr
```
