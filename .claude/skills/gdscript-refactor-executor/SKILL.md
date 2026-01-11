---
name: gdscript-refactor-executor
description: Execute code quality refactorings from gdscript-quality-checker reports. Use this when the user wants to implement the recommendations from a code review report.
domain: code-quality
type: executor
version: 1.1.0
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
---

# GDScript Refactor Executor Skill

This skill executes code quality refactorings based on recommendations from `gdscript-quality-checker` reports.

## When to Use This Skill

Invoke this skill when the user:
- Says "implement the refactoring recommendations"
- Asks to "apply the code review fixes"
- Says "execute the refactor report"
- Wants to "fix the issues from the code review"
- Says "apply the suggestions from [report-name]"

## Core Principle

**Separate analysis from execution** for safety:
1. Analysis skill generates recommendations
2. User reviews the report
3. User decides which fixes to apply
4. Executor skill implements changes systematically
5. Changes are validated and reported

## Execution Workflow

### Step 1: Read the Report

**Ask user which report to execute:**
- List available reports from `docs/code-reviews/`
- Ask user to confirm which report (or specify report filename)
- Read the report markdown file

**Example:**
```
Available code review reports:
- player_review_2025-12-20.md
- weapon-scripts_review_2025-12-20.md

Which report should I execute?
```

### Step 2: Parse Recommendations

**Extract actionable items from the report:**
- Critical Issues (Priority 1 - must fix)
- Performance Warnings (Priority 2 - should fix)
- Code Quality Suggestions (Priority 3 - nice to have)

**For each recommendation, identify:**
- Target file path
- Line numbers (if specified)
- Issue type (e.g., "Missing type annotation", "Deprecated syntax")
- Suggested fix (the refactored code example)

### Step 3: Confirm Execution Plan

**Before making ANY changes, show the user:**
```markdown
## Execution Plan

I will implement the following fixes:

### Priority 1: Critical Issues (3 fixes)
1. ✅ player.gd:45 - Add type annotation to `speed` variable
2. ✅ player.gd:67 - Convert `get_node()` to `@onready`
3. ✅ player.gd:89 - Add null check before accessing `target`

### Priority 2: Performance Warnings (2 fixes)
1. ✅ player.gd:102 - Cache `get_tree()` call outside loop
2. ✅ player.gd:134 - Use `@onready` for node reference

### Priority 3: Code Quality (5 fixes)
[... etc ...]

**Total changes:** 10 edits across 1 file

Proceed with execution? (I'll apply these changes systematically)
```

**Wait for user confirmation before proceeding.**

### Step 4: Execute Refactorings

**For each fix, in priority order:**

1. **Read the target file** to get current state
2. **Verify the issue exists** (line numbers may have changed)
3. **Apply the fix** using the Edit tool
4. **Mark as complete** and move to next fix

**Handle issues gracefully:**
- If line number doesn't match, search for the pattern in the file
- If code already fixed, skip and note
- If unsure, skip and note for manual review

### Step 5: Validation

**After all fixes applied:**

1. **Syntax check**: Use `gdformat` or `gdlint` if available
2. **Report what changed**: Summary of all edits made
3. **Note any skipped fixes**: Items that need manual attention
4. **Recommend testing**: Suggest running the game to verify functionality

### Step 6: Generate Execution Report

**Save execution summary to:**
```
docs/refactoring/[report-name]_execution_[YYYY-MM-DD].md
```

**Include:**
- Which report was executed
- Which fixes were applied successfully
- Which fixes were skipped (and why)
- Files modified
- Recommended next steps

## Types of Refactorings This Skill Can Execute

### 1. Type Annotations

**Before:**
```gdscript
var speed = 200
var health = 100
func get_damage():
```

**After:**
```gdscript
var speed: float = 200.0
var health: int = 100
func get_damage() -> int:
```

---

### 2. Deprecated Syntax Conversions

**Before:**
```gdscript
onready var player = $Player
export var damage = 10
```

**After:**
```gdscript
@onready var player = $Player
@export var damage: int = 10
```

---

### 3. Node Reference Optimization

**Before:**
```gdscript
func _process(delta):
    get_node("Player").position += velocity * delta
```

**After:**
```gdscript
@onready var player = $Player

func _process(delta):
    player.position += velocity * delta
```

---

### 4. Magic Numbers to Constants

**Before:**
```gdscript
func _physics_process(delta):
    velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
    if distance < 150:
        attack()
```

**After:**
```gdscript
const FRICTION_DECELERATION: float = 500.0
const ATTACK_RANGE: float = 150.0

func _physics_process(delta):
    velocity = velocity.move_toward(Vector2.ZERO, FRICTION_DECELERATION * delta)
    if distance < ATTACK_RANGE:
        attack()
```

---

### 5. Null Safety Checks

**Before:**
```gdscript
var target = get_target()
target.take_damage(10)
```

**After:**
```gdscript
var target = get_target()
if target:
    target.take_damage(10)
```

---

### 6. Performance Optimizations

**Before:**
```gdscript
for enemy in enemies:
    var player = get_tree().get_first_node_in_group("player")
    var distance = enemy.global_position.distance_to(player.global_position)
```

**After:**
```gdscript
var player = get_tree().get_first_node_in_group("player")
if player:
    for enemy in enemies:
        var distance = enemy.global_position.distance_to(player.global_position)
```

---

### 7. Signal Connection Cleanup

**Before:**
```gdscript
func _ready():
    health_changed.connect(_on_health_changed)
```

**After:**
```gdscript
func _ready():
    health_changed.connect(_on_health_changed)

func _exit_tree():
    if health_changed.is_connected(_on_health_changed):
        health_changed.disconnect(_on_health_changed)
```

---

### 8. Process Function Corrections

**Before:**
```gdscript
func _process(delta):
    velocity = move_and_slide(velocity)  # Physics in wrong function
```

**After:**
```gdscript
func _physics_process(delta):
    velocity = move_and_slide(velocity)
```

---

## Safety Guidelines

### Before Execution
- ✅ Always show execution plan and wait for confirmation
- ✅ Read the full target file before making changes
- ✅ Verify the issue still exists (code may have changed since report)

### During Execution
- ✅ Make one edit at a time (don't batch)
- ✅ Use exact string matching when possible
- ✅ If ambiguous, skip and note for manual review
- ✅ Keep track of which fixes succeeded/failed

### After Execution
- ✅ Generate execution report
- ✅ Recommend testing the game
- ✅ Note any manual follow-up needed

### What NOT to Do
- ❌ Don't make changes without user confirmation
- ❌ Don't guess at fixes if unclear
- ❌ Don't batch multiple complex refactorings
- ❌ Don't execute if report is too old (warn user if >7 days)
- ❌ Don't modify files not mentioned in the report

## Error Handling

### If line numbers don't match:
1. Search for the surrounding code context
2. If found, apply the fix
3. If not found, skip and note: "Could not locate issue - may be already fixed"

### If file was modified since report:
1. Check if the issue still exists
2. If yes, apply the fix
3. If no, skip: "Issue already resolved"

### If fix is ambiguous:
1. Skip the fix
2. Add to "Manual Review Needed" section
3. Explain why it was skipped

### If syntax error after edit:
1. Attempt to revert the edit
2. Mark fix as failed
3. Continue with remaining fixes
4. Note the failure in execution report

## Execution Report Format

```markdown
# Refactoring Execution Report

**Executed:** [YYYY-MM-DD HH:MM]
**Source Report:** docs/code-reviews/[report-name].md
**Executor:** Claude Code (gdscript-refactor-executor skill)

---

## Summary

- ✅ Fixes applied: X
- ⏭️ Fixes skipped: Y
- ❌ Fixes failed: Z
- 📁 Files modified: N

---

## Applied Fixes

### 1. player.gd:45 - Add type annotation
**Issue:** Missing type annotation on `speed` variable
**Fix:** Changed `var speed = 200` to `var speed: float = 200.0`
**Status:** ✅ Applied successfully

### 2. player.gd:67 - Convert to @onready
**Issue:** Using `get_node()` in `_ready()`
**Fix:** Converted to `@onready var health_bar = $HealthBar`
**Status:** ✅ Applied successfully

[... etc ...]

---

## Skipped Fixes

### 1. player.gd:89 - Null check
**Issue:** Missing null check before accessing target
**Reason:** Code already contains null check
**Status:** ⏭️ Already resolved

---

## Failed Fixes

### 1. weapon.gd:102 - Extract magic number
**Issue:** Magic number 500 should be constant
**Reason:** Could not locate exact line - file may have changed
**Status:** ❌ Needs manual review

---

## Modified Files

1. scripts/systems/player.gd (5 changes)
2. scripts/weapons/machine_gun.gd (2 changes)

---

## Recommendations

1. **Test the game:** Run the project to ensure functionality is preserved
2. **Manual review needed:** 1 fix requires manual attention (see Failed Fixes)
3. **Git commit:** Consider committing these refactorings separately for easy rollback

---

## Next Steps

- [ ] Test game functionality
- [ ] Review failed fixes and apply manually
- [ ] Run gdscript-refactor-check again to verify improvements
- [ ] Commit changes if everything works
```

## Important Notes

- **Incremental execution**: Apply fixes one at a time, don't batch
- **Preserve functionality**: Code behavior must remain identical
- **Testable**: After execution, user should test the game
- **Reversible**: Changes should be easy to revert via git if needed
- **Documented**: Every change is logged in the execution report

## Example Invocations

User: "Execute the player code review fixes"
User: "Apply the refactoring recommendations from the weapon scripts report"
User: "Implement the critical issues from the latest code review"
User: "Run the refactor executor on player_review_2025-12-20.md"

## Workflow Summary

1. User requests execution of a refactor report
2. Skill lists available reports and asks for confirmation
3. Skill parses the report and generates execution plan
4. **Skill shows plan and waits for user approval**
5. Skill executes fixes systematically (one at a time)
6. Skill validates changes and generates execution report
7. Skill saves execution report to `docs/refactoring/`
8. User tests the game to verify functionality

This separation ensures safety while automating tedious refactoring work.
