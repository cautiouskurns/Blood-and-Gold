---
name: changelog-updater
description: Create and update CHANGELOG.md files to track development progress, features, fixes, and changes. Use this when completing features, fixing bugs, or documenting project milestones.
domain: project
type: updater
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Changelog Updater Skill

This skill creates and maintains CHANGELOG.md files following best practices, tracking all development progress, features, bug fixes, and breaking changes.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "update changelog" or "add to changelog"
- Completes a feature and wants to document it
- Fixes bugs and wants to track them
- Asks "how do I track changes to my game?"
- Says "create a changelog"
- Preparing for a release and needs release notes
- Wants to document development progress

---

## Core Principle

**Changelogs are development history**:
- ✅ Track what changed, when, and why
- ✅ Help team understand project evolution
- ✅ Generate release notes automatically
- ✅ Document breaking changes
- ✅ Show progress to stakeholders
- ✅ Provide accountability and transparency

---

## Changelog Format

Following [Keep a Changelog](https://keepachangelog.com/) standard:

```markdown
# Changelog

All notable changes to [Project Name] will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in upcoming releases

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security fixes or improvements

## [1.0.0] - 2025-12-21

### Added
- Initial release
- Feature X implemented
- Feature Y implemented

### Fixed
- Bug #123: Description of fix

## [0.2.0] - 2025-12-15

### Added
- Feature Z in early prototype

### Changed
- Refactored system A for better performance

## [0.1.0] - 2025-12-10

### Added
- Project started
- Basic movement system
- Initial enemy spawning

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/user/repo/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/user/repo/releases/tag/v0.1.0
```

---

## Change Categories

### Added
**Use for:** New features, new files, new capabilities

**Examples:**
- "Added weapon rule system for tactical combat"
- "Added 5 new enemy types (Scout, Tank, Drone, Artillery, Elite)"
- "Added level-up system with 3 upgrade choices"

### Changed
**Use for:** Modifications to existing features

**Examples:**
- "Changed player movement speed from 150 to 200 px/s"
- "Changed XP curve to make early levels faster"
- "Refactored weapon system to use data-driven resources"

### Deprecated
**Use for:** Features marked for removal (still work but will be removed)

**Examples:**
- "Deprecated old enemy spawning system (use WaveManager instead)"
- "Deprecated `get_damage()` function (use `calculate_damage()` instead)"

### Removed
**Use for:** Features that have been deleted

**Examples:**
- "Removed placeholder weapon system"
- "Removed debug UI from production build"
- "Removed unused enemy types (Healer, Support)"

### Fixed
**Use for:** Bug fixes

**Examples:**
- "Fixed crash when player dies while level-up menu is open"
- "Fixed enemies spawning outside world bounds"
- "Fixed weapon not firing when target exactly at max range"

### Security
**Use for:** Security vulnerabilities fixed

**Examples:**
- "Fixed potential save file exploit allowing stat manipulation"
- "Updated dependency X to patch CVE-2025-1234"

---

## Semantic Versioning

Use [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

### Version Format: X.Y.Z

**MAJOR (X):** Breaking changes
- Increment when making incompatible changes
- Example: 1.0.0 → 2.0.0 (save file format changed, old saves incompatible)

**MINOR (Y):** New features (backwards compatible)
- Increment when adding functionality
- Example: 1.0.0 → 1.1.0 (added new weapon type)

**PATCH (Z):** Bug fixes (backwards compatible)
- Increment when fixing bugs
- Example: 1.0.0 → 1.0.1 (fixed crash bug)

### Pre-release Versions
- **Alpha:** 0.1.0, 0.2.0 (early development, unstable)
- **Beta:** 0.9.0, 0.10.0 (feature complete, testing)
- **Release Candidate:** 1.0.0-rc.1, 1.0.0-rc.2 (final testing before release)

---

## Workflow

### Creating a New Changelog

If no CHANGELOG.md exists:

1. **Ask user for project details:**
   - Project name
   - Current version (or start at 0.1.0)
   - Git repository URL (if applicable)

2. **Create CHANGELOG.md** with header and first version

3. **Ask about current state:**
   - What features are implemented?
   - What's the initial release content?

4. **Generate initial entry** for version 0.1.0 or 1.0.0

### Updating Existing Changelog

If CHANGELOG.md exists:

1. **Read current CHANGELOG.md**

2. **Ask user what changed:**
   - "What did you add/change/fix?"
   - "Is this a new version or still unreleased?"

3. **Determine version bump:**
   - Breaking change? → MAJOR
   - New feature? → MINOR
   - Bug fix only? → PATCH
   - Still in development? → Add to [Unreleased]

4. **Update changelog:**
   - Add entries to appropriate category
   - Update version number if releasing
   - Update comparison links at bottom

### Adding Entry to Unreleased Section

**When:** User completes work but hasn't released version yet

**Process:**
1. Read CHANGELOG.md
2. Add entry under `## [Unreleased]` in appropriate category
3. Use present tense ("Added weapon system" not "Add weapon system")
4. Be specific and concise

### Creating New Version Release

**When:** User says "release version X.Y.Z" or "cut a release"

**Process:**
1. Read CHANGELOG.md
2. Move all [Unreleased] entries to new version section
3. Add date to version header: `## [X.Y.Z] - YYYY-MM-DD`
4. Clear [Unreleased] section
5. Update comparison links at bottom
6. Ask if user wants to tag git commit

---

## Entry Writing Guidelines

### Be Specific
❌ Bad: "Fixed bugs"
✅ Good: "Fixed crash when enemy dies while being targeted"

❌ Bad: "Improved performance"
✅ Good: "Improved wave spawning performance by caching enemy pools (30% FPS gain)"

### Use Imperative Mood
❌ Bad: "Adds new weapon"
✅ Good: "Add new railgun weapon with pierce mechanic"

### Include Context
❌ Bad: "Changed damage value"
✅ Good: "Changed machine gun damage from 10 to 5 for better balance"

### Reference Issues/PRs
✅ "Fixed enemy pathfinding bug (#42)"
✅ "Added weapon evolution system (PR #15)"

### Group Related Changes
Instead of:
```
- Added Scout enemy
- Added Tank enemy
- Added Drone enemy
```

Better:
```
- Added 3 new enemy types: Scout (fast/weak), Tank (slow/tough), Drone (flying/medium)
```

---

## Special Cases

### Breaking Changes

**Always highlight breaking changes prominently:**

```markdown
## [2.0.0] - 2025-12-21

### ⚠️ BREAKING CHANGES
- Save file format changed - old saves will not load
- `WeaponBase.fire()` signature changed - custom weapons need update
- Deprecated `EnemyManager` removed - use `WaveManager` instead

### Changed
- Weapon system refactored to use resource-based data
```

### Migration Guides

**For major breaking changes, include migration notes:**

```markdown
## [2.0.0] - 2025-12-21

### Changed
- Weapon system now uses WeaponData resources instead of hardcoded stats

**Migration:**
1. Create WeaponData resource for each weapon
2. Replace weapon script constants with `@export var data: WeaponData`
3. See `docs/weapon-migration-guide.md` for details
```

### Comparing Git Changes

**If user has git, can generate changelog from commits:**

Use bash to get recent commits:
```bash
git log --oneline --since="7 days ago"
```

Parse commits and categorize:
- Commits starting with "feat:" → Added
- Commits starting with "fix:" → Fixed
- Commits starting with "refactor:" → Changed
- Commits starting with "docs:" → (Usually skip in user-facing changelog)

---

## Output File Location

**Primary changelog:** `CHANGELOG.md` (project root)

**Alternative locations:**
- `docs/CHANGELOG.md` (if docs folder preferred)
- `docs/changelog/YYYY-MM.md` (monthly changelogs for large projects)

---

## Integration with Other Skills

### With `prototype-gdd-generator`
- After creating GDD, add to changelog: "Added prototype design document"

### With `feature-spec-generator`
- After implementing feature, add to changelog: "Implemented [feature] per spec"

### With `gdscript-refactor-executor`
- After refactoring, add to changelog: "Refactored [system] for code quality"

### With Version Control
- Can generate release notes from changelog
- Can tag git commits with version numbers
- Can compare changelog to git history for accuracy

---

## Example Interactions

**User:** "Update changelog - I added the weapon rule system"

**Skill:**
```
I'll add this to the Unreleased section under "Added".

Should I include any specific details about the weapon rule system?
(e.g., "Added weapon rule system with 5 targeting priorities and 4 firing conditions")
```

---

**User:** "Create changelog for my game"

**Skill:**
```
I'll create a CHANGELOG.md file. A few questions:

1. Project name?
2. Current version (or should I start at 0.1.0)?
3. Git repository URL (if any)?
4. What features are currently implemented?
```

---

**User:** "Release version 1.0.0"

**Skill:**
```
I'll move all Unreleased changes to version 1.0.0 with today's date.

Looking at [Unreleased]:
- 5 Added features
- 3 Changed items
- 12 Fixed bugs

This looks like a significant release. Should I tag this as 1.0.0 or would you like a different version number?
```

---

## Quality Checklist

Before finalizing changelog update:
- ✅ Entries are specific and descriptive
- ✅ Version number follows semantic versioning
- ✅ Date is in YYYY-MM-DD format
- ✅ Breaking changes are highlighted
- ✅ Comparison links are updated (if using git)
- ✅ Categories are correct (Added/Changed/Fixed/etc.)
- ✅ Entries use consistent tense/voice

---

## Example Invocations

User: "Update changelog"
User: "Add feature X to changelog"
User: "Create a changelog for my project"
User: "Release version 1.0.0"
User: "What changed since last version?"
User: "Generate changelog from git history"

---

## Workflow Summary

1. Check if CHANGELOG.md exists
2. If new: Ask project details and create initial changelog
3. If exists: Read current changelog
4. Ask what changed (or read from git if applicable)
5. Determine version impact (unreleased vs new version)
6. Add entries to appropriate categories
7. Update version numbers and dates if releasing
8. Write updated CHANGELOG.md
9. Confirm changes to user

---

This skill ensures development progress is documented systematically, making releases transparent and history traceable.
