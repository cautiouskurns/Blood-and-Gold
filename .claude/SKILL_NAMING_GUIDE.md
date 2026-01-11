# Claude Code Skill Naming Convention

**Version:** 1.0.0
**Last Updated:** 2025-12-20

---

## Purpose

This guide establishes a consistent naming convention for all Claude Code skills in this project. Consistent naming improves discoverability, maintainability, and team communication.

---

## Naming Pattern

```
[domain?]-[action]-[type]
```

### Components

1. **Domain** (optional): Technology, system, or area
2. **Action**: What it does (verb or noun)
3. **Type**: How it works (category)

---

## When to Include Domain

### ✅ Include Domain When:

- **Technology-specific**: `gdscript-`, `godot-`, `git-`
- **System-specific**: `combat-`, `ui-`, `balance-`, `weapon-`, `enemy-`
- **Narrow scope**: Targets specific subsystem

**Examples:**
```
gdscript-quality-checker   (GDScript-specific code analysis)
balance-weapon-analyzer    (Weapon balancing system)
asset-dependency-analyzer  (Asset management domain)
```

### ❌ Omit Domain When:

- **Cross-cutting**: Works across multiple domains
- **Project-agnostic**: Not tied to specific technology
- **Workflow-oriented**: Process rather than domain

**Examples:**
```
feature-spec-generator   (Any feature, any system)
vertical-slice-planner   (Any vertical slice)
changelog-generator      (Any project)
```

---

## Standard Skill Types

| Type | Purpose | Outputs | Examples |
|------|---------|---------|----------|
| **analyzer** | Examines code/data, provides insights | Reports, recommendations | `balance-analyzer`, `performance-analyzer` |
| **generator** | Creates new content from scratch | Files, code, documentation | `scene-generator`, `test-generator` |
| **checker** | Validates correctness, finds issues | Issue lists, warnings | `quality-checker`, `coverage-checker` |
| **validator** | Verifies compliance with rules | Pass/fail, violations | `balance-validator`, `asset-validator` |
| **extractor** | Pulls data from code to files | Data files, resources | `weapon-data-extractor`, `stat-extractor` |
| **refactor** | Transforms/improves existing code | Modified code, migration plan | `data-driven-refactor`, `pattern-refactor` |
| **executor** | Applies changes automatically | Modified files | `refactor-executor`, `migration-executor` |
| **planner** | Creates implementation roadmaps | Plans, checklists | `feature-planner`, `release-planner` |
| **helper** | Interactive guidance | Suggestions, tips | `debugging-helper`, `onboarding-helper` |
| **assistant** | Collaborative task support | Interactive support | `bug-triage-assistant`, `review-assistant` |
| **optimizer** | Improves performance/efficiency | Optimized code/settings | `scene-optimizer`, `export-optimizer` |

---

## Naming Decision Tree

```
1. Is it specific to a domain/technology?
   ├─ Yes → Use domain prefix (gdscript-quality-checker)
   └─ No  → Omit domain (feature-spec-generator)

2. What does it do?
   ├─ Examines/analyzes     → analyzer
   ├─ Creates new content   → generator
   ├─ Validates/checks      → checker/validator
   ├─ Extracts data         → extractor
   ├─ Transforms code       → refactor
   ├─ Executes changes      → executor
   ├─ Optimizes             → optimizer
   ├─ Plans implementation  → planner
   └─ Guides/assists        → helper/assistant

3. Combine: [domain?]-[action]-[type]
```

---

## Examples by Domain

### Code Quality
```
gdscript-quality-checker      (Analyzes code quality)
gdscript-performance-analyzer (Finds performance issues)
gdscript-pattern-refactor     (Applies design patterns)
gdscript-refactor-executor    (Executes refactoring)
```

### Balance & Design
```
balance-weapon-analyzer       (Analyzes weapon effectiveness)
balance-curve-validator       (Validates progression curves)
balance-dashboard-generator   (Creates balance dashboards)
data-driven-refactor          (Extracts hardcoded data)
```

### Testing
```
test-case-generator           (Generates unit tests)
test-coverage-checker         (Checks test coverage)
test-replay-analyzer          (Analyzes test replays)
ai-playtester                 (Automated playtesting)
```

### Assets
```
asset-organizer               (Organizes asset files)
asset-dependency-analyzer     (Maps asset references)
asset-import-validator        (Validates import settings)
```

### Project Management
```
feature-spec-generator        (Generates feature specs)
vertical-slice-planner        (Plans vertical slices)
changelog-generator           (Creates changelogs)
release-readiness-checker     (Pre-release validation)
```

### Godot-Specific
```
scene-optimizer               (Optimizes scene structure)
export-config-validator       (Validates export settings)
signal-connection-checker     (Finds signal issues)
```

---

## Skill Metadata Template

Every skill should include metadata in its `SKILL.md` frontmatter:

```yaml
---
name: gdscript-quality-checker
description: Analyze GDScript code for quality, best practices, and anti-patterns
domain: code-quality
type: checker
version: 1.0.0
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---
```

### Required Fields
- **name**: Skill name following naming convention
- **description**: One-sentence description
- **domain**: Primary domain (code-quality, balance, testing, assets, project)
- **type**: Skill type (analyzer, generator, checker, etc.)
- **version**: Semantic version (1.0.0)
- **allowed-tools**: List of tools this skill can use

---

## Migration Guide

### Renaming Existing Skills

When renaming a skill:

1. **Rename directory**: `mv old-name new-name`
2. **Update SKILL.md**: Change `name:` field in frontmatter
3. **Update description**: Match new name in description
4. **Update documentation**: Search for references in docs
5. **Update slash commands**: If any reference the old name
6. **Test**: Verify skill still works with new name

### Example Migration
```bash
# Old name: gdscript-refactor-check
# New name: gdscript-quality-checker

cd .claude/skills
mv gdscript-refactor-check gdscript-quality-checker
cd gdscript-quality-checker
# Edit SKILL.md to update name field
```

---

## Directory Structure

Organize skills by domain for clarity:

```
.claude/skills/
├── code-quality/
│   ├── gdscript-quality-checker/
│   ├── gdscript-performance-analyzer/
│   └── gdscript-refactor-executor/
├── balance/
│   ├── balance-weapon-analyzer/
│   ├── balance-dashboard-generator/
│   └── data-driven-refactor/
├── testing/
│   ├── test-case-generator/
│   ├── test-coverage-checker/
│   └── ai-playtester/
├── assets/
│   ├── asset-organizer/
│   └── asset-dependency-analyzer/
└── project/
    ├── feature-spec-generator/
    ├── vertical-slice-planner/
    └── changelog-generator/
```

**Note:** Currently using flat structure. Domain-based organization is optional but recommended for projects with 10+ skills.

---

## Anti-Patterns to Avoid

### ❌ Too Generic
```
helper             → What does it help with?
tool               → What kind of tool?
analyzer           → Analyzes what?
```

### ❌ Too Verbose
```
gdscript-code-quality-and-refactoring-checker  → Too long
balance-weapon-damage-effectiveness-analyzer   → Too specific
```

### ❌ Inconsistent Type
```
gdscript-refactor-check     → Should be "checker" not "check"
balance-validate-curves     → Should be "validator" not "validate"
asset-organize              → Should be "organizer" not "organize"
```

### ❌ Wrong Domain Separation
```
gdscript-balance-analyzer   → Should be "balance-weapon-analyzer" (balance is domain)
ui-gdscript-validator       → Should be "gdscript-ui-validator" (gdscript is domain)
```

---

## Examples of Well-Named Skills

### Simple & Clear
```
✅ feature-spec-generator     (Cross-cutting, clear purpose)
✅ changelog-generator         (Simple, project-agnostic)
✅ scene-optimizer             (Simple, Godot-specific)
```

### Domain-Specific
```
✅ gdscript-quality-checker    (GDScript domain, checks quality)
✅ balance-weapon-analyzer     (Balance domain, analyzes weapons)
✅ asset-dependency-analyzer   (Asset domain, analyzes dependencies)
```

### Action-Oriented
```
✅ data-driven-refactor        (Transforms code to data-driven)
✅ test-coverage-checker       (Checks test coverage)
✅ vertical-slice-planner      (Plans vertical slice implementation)
```

---

## Quick Reference

### Choosing Domain
- Specific technology? → Use it (`gdscript-`, `godot-`)
- Specific system? → Use it (`balance-`, `combat-`, `ui-`)
- General workflow? → Omit it (`feature-spec-generator`)

### Choosing Type
- Analyze & report? → `analyzer`
- Create new? → `generator`
- Validate rules? → `checker`/`validator`
- Extract data? → `extractor`
- Transform code? → `refactor`
- Execute changes? → `executor`
- Optimize? → `optimizer`
- Plan tasks? → `planner`
- Assist user? → `helper`/`assistant`

### Complete Examples
```
gdscript-quality-checker       [domain]-[action]-[type]
balance-weapon-analyzer        [domain]-[action]-[type]
feature-spec-generator         [action]-[type]
data-driven-refactor           [action]-[type]
scene-optimizer                [action]-[type]
```

---

## Version History

### 1.0.0 (2025-12-20)
- Initial naming convention established
- Defined standard skill types
- Created migration guide
- Applied to existing skills

---

## Maintenance

This guide should be reviewed and updated:
- When adding 5+ new skills
- When patterns emerge that don't fit convention
- When Godot/Claude Code introduces new capabilities
- Quarterly review of skill library

**Owner:** Project maintainer
**Last Review:** 2025-12-20
**Next Review:** 2026-03-20

---

*This is a living document. Propose changes via pull request or team discussion.*
