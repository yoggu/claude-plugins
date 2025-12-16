---
name: node-modules-update
description: "Update Node.js project dependencies using npm. Use when asked to update node modules, npm packages, dependencies, or perform npm update. Handles branch creation, dependency updates, build verification, and test execution."
allowed-tools: Bash(npm:*), Bash(git:*), Bash(gh:*), Read
---

# Node Modules Update

Perform safe, systematic Node.js dependency updates with proper version control, build verification, and testing.

## Prerequisites

- Node.js project with package.json
- npm installed
- Git version control

## Update Scope

By default, this skill performs:
- Patch version updates (x.x.1 → x.x.2)
- Minor version updates (x.1.x → x.2.x)

This skill does not:
- Upgrade major versions (1.x.x → 2.x.x) - these often have breaking changes
- Modify package.json - package-lock.json is the expected change
- Use `npm install package@version` - this modifies package.json

For major version upgrades: User should explicitly request them. These require careful review and should be handled separately.

## Initialization

**Before any update, run these steps first:**

### 1. Update Local Main Branch

Ensure your local main/master branch is up to date:
```bash
git checkout main && git pull origin main
# or: git checkout master && git pull origin master
```

This step is critical to:
- Avoid merge conflicts later
- Ensure you're building on the latest code
- Prevent duplicate or conflicting PRs

### 2. Create Feature Branch

Create a dedicated branch with date for the update:
```bash
git checkout -b chore/update-node-modules-$(date +%Y%m%d)
```

**IMPORTANT:** Never perform updates directly on master/main branch.

---

## Update Workflow

**Ensure Initialization steps are complete before proceeding.**

### 1. Check Outdated Packages

Before updating, capture the current state of outdated packages:
```bash
npm outdated
```

Save this output - you'll need it for the commit message. Note the package names and version changes (Current → Wanted).

### 2. Update Dependencies

Run npm update to upgrade packages within semver constraints:
```bash
npm update
```

Note:
- This command updates package-lock.json
- It respects semver ranges in package.json (patch/minor)
- If `npm outdated` shows packages where Current = Wanted, those are major version updates - skip them unless requested

Review output for:
- Number of packages added/removed/changed
- Any vulnerabilities found
- Funding information (optional)

### 3. Run Lint

Run linting to check for issues:
```bash
npm run lint
```

**If lint fails due to updated packages:**
1. Read the error messages to understand the issue
2. Fix the code to resolve lint errors (e.g., updated API usage, new required props)
3. Re-run lint to verify fixes
4. Only skip the update if the fix is too complex or risky

### 4. Verify Build

Run the build to ensure updated packages work correctly:
```bash
npm run build
```

**If build fails due to updated packages:**
1. Read the error messages carefully (TypeScript errors, module resolution, etc.)
2. Fix the breaking changes in the code:
   - Update type annotations if types changed
   - Adjust API calls if signatures changed
   - Update imports if package structure changed
3. Re-run the build to verify fixes
4. Only skip the update if the fix is too complex or requires significant refactoring

### 5. Run Tests

Execute the test suite to catch regressions:
```bash
npm run test
```

**If tests fail due to updated packages:**
1. Investigate if failure is related to the updates
2. Fix test code or application code as needed
3. Check changelog of updated packages for migration guides
4. Re-run tests to verify fixes
5. Only skip the update if fixes are too complex

### 6. Review Changes

Check what files were modified:
```bash
git status
```

Expected changes:
- `package-lock.json` - Updated dependency tree
- Any source files you fixed during lint/build/test steps

### 7. Commit Changes

Stage and commit the update with detailed version information:
```bash
git add package-lock.json
# Include any files you fixed:
git add <fixed-files>
```

**Commit message format** - include all updated packages with version changes:
```
chore: update node modules

Updated packages:
- next: 16.0.5 → 16.0.10
- react: 19.2.0 → 19.2.3
- typescript: 5.6.2 → 5.7.2
- eslint: 9.15.0 → 9.16.0
...

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Use the output from step 1 (`npm outdated`) to list all packages that were updated.

### 8. Create Pull Request

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
- **Bitbucket** (bitbucket.org): Open the PR URL shown in push output, or construct:
  `https://bitbucket.org/{workspace}/{repo}/pull-requests/new?source={branch}&t=1`

## Common Issues

### Peer Dependency Conflicts

If npm reports peer dependency issues:
```bash
npm update --legacy-peer-deps
```

### Major Version Updates (When Explicitly Requested)

Do not perform major version upgrades unless the user specifically asks.

If explicitly requested:
```bash
npm install package-name@latest
```

Note: This modifies package.json and may introduce breaking changes. Verify build/tests pass.

### Security Vulnerabilities

Check for and fix vulnerabilities:
```bash
npm audit
npm audit fix
```

### Lock File Conflicts

If package-lock.json has conflicts:
```bash
rm package-lock.json
npm install
```

## Files Modified

Expected changes (normal update):
- `package-lock.json` - Updated dependency tree

Not expected (unless explicitly requested):
- `package.json` - Should not be modified during normal updates
- If package.json was modified, review the commands used

## Rollback

If issues occur after update:
```bash
git checkout package-lock.json
npm install
```
