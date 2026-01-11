---
name: version-control-helper
description: Guide users through git workflows, best practices, commit messages, branching strategies, and resolving common version control issues. Use this when users need help with git operations or workflow decisions.
domain: project
type: helper
version: 1.0.0
allowed-tools:
  - Bash
  - Read
---

# Version Control Helper Skill

This skill provides guidance on git workflows, commit strategies, branch management, and resolving common version control issues for game development projects.

---

## When to Use This Skill

Invoke this skill when the user:
- Asks "how do I use git for game dev?"
- Says "help me with git" or "explain git workflow"
- Needs commit message suggestions
- Asks about branching strategies
- Has merge conflicts and needs help
- Wants to organize git history
- Asks "should I commit this?"
- Says "what's a good git workflow for solo/team dev?"

---

## Core Principle

**Git enables safe iteration and collaboration**:
- ✅ Commit often, push less often
- ✅ Write meaningful commit messages
- ✅ Branch for features, merge when stable
- ✅ Keep history clean and readable
- ✅ Never lose work
- ✅ Enable collaboration and code review

---

## Commit Message Guidelines

### Format: Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **refactor:** Code refactoring (no behavior change)
- **perf:** Performance improvement
- **docs:** Documentation changes
- **style:** Code formatting (no logic change)
- **test:** Adding or updating tests
- **chore:** Build process, dependencies, tooling
- **art:** Art asset additions/changes
- **audio:** Audio asset additions/changes
- **balance:** Game balance tweaks

### Examples

**Good commit messages:**
```
feat(weapons): add railgun with pierce mechanic

- Damage: 100
- Fire rate: 0.5/s
- Range: 600px
- Pierces up to 3 enemies

Closes #42
```

```
fix(player): prevent movement while paused

Player could move during pause menu if input buffered.
Now movement input is ignored when game_paused == true.

Fixes #38
```

```
refactor(enemies): extract hardcoded stats to resources

Converted all 5 enemy types to use EnemyData resources:
- Scout, Tank, Drone, Artillery, Elite
- Enables easy balancing without code changes

Related to #25
```

**Bad commit messages:**
```
❌ "fixed stuff"
❌ "wip"
❌ "update"
❌ "asdf"
❌ "final final FINAL version"
```

### Subject Line Rules

- Use imperative mood ("add feature" not "added feature")
- Don't capitalize first letter (unless proper noun)
- No period at end
- Max 50 characters for subject
- Wrap body at 72 characters

---

## Branching Strategies

### Solo Developer (Simple Flow)

```
main
  └─ feature/weapon-system
  └─ fix/enemy-spawning
```

**Strategy:**
- `main` = stable, working game
- Feature branches for new systems
- Merge to main when feature works
- Tag releases on main

**Commands:**
```bash
# Start new feature
git checkout -b feature/weapon-rules

# Work and commit
git add .
git commit -m "feat(weapons): add target priority system"

# Merge when done
git checkout main
git merge feature/weapon-rules
git branch -d feature/weapon-rules
```

---

### Small Team (Git Flow Lite)

```
main (production)
  └─ develop (integration)
      └─ feature/player-movement
      └─ feature/enemy-ai
      └─ fix/collision-bug
```

**Strategy:**
- `main` = releases only (tagged)
- `develop` = active development
- Feature branches off `develop`
- Merge to `develop`, then `main` for releases

**Commands:**
```bash
# Start feature
git checkout develop
git checkout -b feature/wave-spawning

# Work and commit
git commit -m "feat(waves): implement time-based spawning"

# Merge to develop
git checkout develop
git merge feature/wave-spawning

# Release (when ready)
git checkout main
git merge develop
git tag -a v1.0.0 -m "Release 1.0.0"
```

---

### Release Branches (Larger Projects)

```
main
  └─ develop
      ├─ release/1.0
      ├─ feature/new-weapon
      └─ hotfix/crash-fix
```

**Strategy:**
- `release/X.Y` branches for stabilization
- Hotfixes branch from `main` for urgent production fixes
- Features continue on `develop` during release stabilization

---

## When to Commit

### Commit Frequency

**Good times to commit:**
- ✅ Feature complete and working
- ✅ Bug fixed and tested
- ✅ End of work session (even if incomplete)
- ✅ Before risky refactoring
- ✅ After code review changes

**When NOT to commit:**
- ❌ Code doesn't compile
- ❌ Game crashes on start
- ❌ In middle of refactoring (use WIP commit, amend later)

### Atomic Commits

**One commit = one logical change**

✅ Good:
```
feat(player): add dash ability
fix(enemies): correct pathfinding edge case
refactor(weapons): extract data to resources
```

❌ Bad:
```
"updated player, fixed enemies, changed weapons, added UI"
```

---

## .gitignore for Godot Projects

**Essential .gitignore:**

```
# Godot-specific ignores
.import/
export.cfg
export_presets.cfg

# Godot 4+ specific
.godot/

# Builds
builds/
exports/

# Logs
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Addons (if external)
addons/

# Sensitive data
*.secret
credentials.json
.env
```

---

## Common Scenarios & Solutions

### Scenario 1: "I made a mistake in last commit"

**If not pushed yet:**
```bash
# Fix files, then amend commit
git add .
git commit --amend --no-edit

# Or change commit message too
git commit --amend -m "fix(player): correct movement speed"
```

**If already pushed:**
```bash
# Create new commit fixing the issue
git add .
git commit -m "fix(player): correct movement speed regression from previous commit"
```

---

### Scenario 2: "I need to undo last commit"

**Keep changes, undo commit:**
```bash
git reset --soft HEAD~1
```

**Discard changes and commit:**
```bash
git reset --hard HEAD~1
```

---

### Scenario 3: "I have merge conflicts"

**Resolve conflicts:**
```bash
git status  # See which files have conflicts

# Edit files, look for:
# <<<<<<< HEAD
# Your changes
# =======
# Their changes
# >>>>>>> branch-name

# Choose which version to keep, or combine them

git add <resolved-files>
git commit -m "merge: resolve conflicts in enemy system"
```

**Abort merge:**
```bash
git merge --abort
```

---

### Scenario 4: "I want to save work but not commit"

**Use git stash:**
```bash
# Stash changes
git stash save "WIP: weapon rule system half done"

# Do other work, switch branches, etc.

# Restore stashed changes
git stash pop
```

---

### Scenario 5: "I committed to wrong branch"

**If not pushed:**
```bash
# Note the commit hash
git log  # Copy commit hash

# Undo commit on current branch
git reset --hard HEAD~1

# Switch to correct branch
git checkout correct-branch

# Apply commit
git cherry-pick <commit-hash>
```

---

### Scenario 6: "I need to work on old version"

**Create branch from old commit/tag:**
```bash
# View history
git log --oneline

# Checkout old commit
git checkout <commit-hash>

# Create branch from it
git checkout -b hotfix/old-version-bug
```

---

## Git Workflow Recommendations by Team Size

### Solo Developer
- Use `main` + feature branches
- Commit frequently to feature branches
- Merge to `main` when stable
- Tag releases on `main`

### 2-3 Developers
- Use `main` + `develop` + feature branches
- Pull requests for code review (GitHub/GitLab)
- Merge to `develop`, periodically merge to `main` for releases

### 4+ Developers
- Use Git Flow (main, develop, feature, release, hotfix)
- Enforce PR reviews before merging
- CI/CD pipeline for automated testing
- Protected `main` branch (no direct commits)

---

## Game Dev Specific Tips

### Binary Assets

**Problem:** Large binary files (sprites, audio) bloat git history

**Solution: Git LFS** (Large File Storage)
```bash
# Install git-lfs
git lfs install

# Track large file types
git lfs track "*.png"
git lfs track "*.wav"
git lfs track "*.ogg"

# Add .gitattributes
git add .gitattributes
git commit -m "chore: configure git lfs for binary assets"
```

### Godot-Specific Considerations

**Commit .import folder?**
- ❌ Don't commit `.import/` (regenerated by Godot)
- ✅ Do commit source assets (images, audio)
- ✅ Godot will regenerate imports on other machines

**Scene conflicts:**
- `.tscn` files are text-based, merge carefully
- Use "Tools → Reload from Disk" in Godot after git operations

**Export presets:**
- ❌ Don't commit `export_presets.cfg` (contains local paths)
- ✅ Document export settings in README

---

## Tagging Releases

**Create annotated tag:**
```bash
git tag -a v1.0.0 -m "Release 1.0.0 - Initial release"
```

**Push tags:**
```bash
git push origin v1.0.0

# Or push all tags
git push --tags
```

**Tag naming:**
- Use semantic versioning: `v1.0.0`, `v1.1.0`, `v2.0.0`
- Pre-releases: `v1.0.0-alpha.1`, `v1.0.0-beta.2`, `v1.0.0-rc.1`

---

## Suggested Git Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    # Quick status
    s = status -s

    # Pretty log
    lg = log --oneline --graph --decorate --all

    # Last commit
    last = log -1 HEAD --stat

    # Undo last commit (keep changes)
    undo = reset --soft HEAD~1

    # Amend last commit
    amend = commit --amend --no-edit

    # Show changes
    d = diff
    ds = diff --staged
```

---

## Pre-Commit Hooks (Advanced)

**Prevent commits that:**
- Have syntax errors (GDScript linting)
- Have merge conflict markers
- Are too large
- Have debug code (e.g., `print("DEBUG:")`)

**Example hook:** `.git/hooks/pre-commit`
```bash
#!/bin/bash
# Check for debug print statements
if git diff --cached | grep -i "print.*debug"; then
    echo "Error: Debug print statements found"
    exit 1
fi
```

---

## GitHub/GitLab Integration

### Pull Request Template

Create `.github/pull_request_template.md`:
```markdown
## What does this PR do?
[Brief description]

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactor
- [ ] Documentation

## Testing
- [ ] Tested in-game
- [ ] No console errors
- [ ] Doesn't break existing features

## Screenshots
[If UI/visual changes]
```

### Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`

---

## Troubleshooting Common Issues

### "I have uncommitted changes and can't switch branches"
```bash
# Stash changes
git stash

# Switch branch
git checkout other-branch

# Return and restore
git checkout original-branch
git stash pop
```

### "My repo is huge from binary assets"
```bash
# Use git-lfs (see above)
# Or use BFG Repo-Cleaner to remove large files from history
```

### "I accidentally committed secrets"
```bash
# If not pushed: amend commit
git reset HEAD~1
# Remove secrets, then commit again

# If pushed: rotate secrets immediately, then:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret" \
  --prune-empty --tag-name-filter cat -- --all
```

---

## Example Invocations

User: "How do I use git for my game?"
User: "What's a good commit message for adding a weapon?"
User: "I have merge conflicts, help!"
User: "Should I commit .import folder?"
User: "What branching strategy for solo dev?"
User: "How do I undo last commit?"

---

## Workflow Summary

1. User asks git-related question
2. Assess user's situation (solo/team, experience level, specific issue)
3. Provide tailored guidance with commands
4. Explain rationale (why this approach is recommended)
5. Show examples specific to game dev / Godot
6. Suggest preventive measures (hooks, aliases, workflows)

---

This skill helps users maintain clean git history, collaborate effectively, and never lose work during game development.
