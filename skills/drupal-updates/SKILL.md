---
name: drupal-updates
description: "Perform Drupal core and contributed module updates using Composer. Use when asked to update Drupal core, contrib modules, check for updates, run database updates, or handle patch failures."
---

# Drupal Updates Skill

Perform safe, systematic Drupal updates with proper version control, database updates, and configuration export.

## Prerequisites

- DDEV or Lando local development environment
- Composer-based Drupal project (drupal/recommended-project)
- Git version control
- Drush installed

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

### 3. Create Feature Branch
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
- `~` = major update available (requires careful review)

### 2. Update Drupal Core
Update core packages together with dependencies:
```bash
ddev composer update "drupal/core-*" --with-all-dependencies
```

### 3. Update Contributed Modules
Update all Drupal modules:
```bash
ddev composer update "drupal/*" --with-all-dependencies
```

For specific module updates:
```bash
ddev composer require drupal/MODULE_NAME:^VERSION --with-all-dependencies
```

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

Use Playwright MCP or manual testing:
- Homepage loads correctly
- Admin login works
- Content management functional
- No PHP errors in status report

### 10. Commit Changes
```bash
git add composer.json composer.lock config/sync/
git commit -m "Update Drupal core X.X.X → Y.Y.Y and contrib modules"
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

- `composer.json` - Version constraints (only if using `require`)
- `composer.lock` - Locked dependency versions
- `config/sync/` - Exported configuration changes

## Rollback

If issues occur:
```bash
git checkout composer.json composer.lock
ddev composer install
ddev drush cr
```
