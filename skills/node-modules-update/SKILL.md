---
name: node-modules-update
description: "Update Node.js project dependencies using npm. Use when asked to update node modules, npm packages, dependencies, or perform npm update. Handles branch creation, dependency updates, build verification, and test execution."
---

# Node Modules Update

Perform safe, systematic Node.js dependency updates with proper version control, build verification, and testing.

## Prerequisites

- Node.js project with package.json
- npm installed
- Git version control

## Update Workflow

### 1. Create Feature Branch

Create a dedicated branch for the update:
```bash
git checkout -b chore/update-node-modules
```

### 2. Update Dependencies

Run npm update to upgrade packages within semver constraints:
```bash
npm update
```

Review output for:
- Number of packages added/removed/changed
- Any vulnerabilities found
- Funding information (optional)

### 3. Verify Build

Run the build to ensure updated packages work correctly:
```bash
npm run build
```

Check for:
- Successful compilation
- No TypeScript errors
- No build warnings (if critical)

### 4. Run Tests

Execute the test suite to catch regressions:
```bash
npm run test
```

If tests fail:
- Investigate if failure is related to updates
- Check changelog of updated packages for breaking changes
- Consider pinning problematic packages

### 5. Review Changes

Check what files were modified:
```bash
git status
```

Expected changes:
- `package-lock.json` - Updated dependency tree

### 6. Commit Changes

Stage and commit the update:
```bash
git add package-lock.json
git commit -m "chore: update node modules"
```

## Common Issues

### Peer Dependency Conflicts

If npm reports peer dependency issues:
```bash
npm update --legacy-peer-deps
```

### Major Version Updates

For major version upgrades (breaking changes), use:
```bash
npm outdated
npm install package-name@latest
```

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

- `package-lock.json` - Locked dependency versions (always)
- `package.json` - Only if using `npm install` with specific versions

## Rollback

If issues occur after update:
```bash
git checkout package-lock.json
npm install
```
