---
name: gdscript-quality-checker
description: Analyze GDScript code for quality, best practices, anti-patterns, and refactoring opportunities. Use this when the user wants to review code quality, check for Godot-specific issues, or improve code maintainability.
domain: code-quality
type: checker
version: 1.2.0
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# GDScript Quality Checker Skill

This skill analyzes GDScript files to identify code quality issues, Godot-specific anti-patterns, performance problems, and refactoring opportunities.

## When to Use This Skill

Invoke this skill when the user:
- Asks to "check code quality" or "review my code"
- Says "refactor [script_name].gd" or "analyze [script_name]"
- Wants to find code duplication or anti-patterns
- Asks "is this good GDScript?" or "how can I improve this code?"
- Requests performance analysis
- Says "check my scripts" or "code review"

## Analysis Categories

### 1. Godot-Specific Best Practices

**Check for:**

**Node References:**
- ❌ Using `get_node("NodeName")` or `$NodeName` in `_ready()` or repeatedly
- ✅ Should use `@onready var node_ref = $NodeName`

**Signals vs. Polling:**
- ❌ Checking conditions in `_process()` every frame (e.g., `if health <= 0:`)
- ✅ Should emit signals when state changes (e.g., `health_depleted.emit()`)

**Process Functions:**
- ❌ Physics operations in `_process(delta)`
- ✅ Should use `_physics_process(delta)` for physics
- ❌ Empty `_process()` or `_physics_process()` functions (remove them)

**Resource Loading:**
- ❌ Loading resources at runtime: `load("res://...")`
- ✅ Should preload: `const RESOURCE = preload("res://...")`

**Node Access:**
- ❌ Deep node paths: `get_node("../../UI/HUD/Label")`
- ✅ Should use signals or dependency injection

**Type Safety:**
- ❌ Untyped variables: `var speed = 100`
- ✅ Should type: `var speed: float = 100.0`
- ❌ Untyped function returns: `func get_damage():`
- ✅ Should type: `func get_damage() -> int:`

### 2. Performance Anti-Patterns

**Check for:**

**Expensive Operations in Loops:**
```gdscript
# ❌ Bad
for enemy in enemies:
    var player = get_tree().get_first_node_in_group("player")

# ✅ Good
var player = get_tree().get_first_node_in_group("player")
for enemy in enemies:
```

**String Operations:**
- ❌ String concatenation in loops: `str += "text"`
- ✅ Use String formatting: `"%s: %d" % [name, value]`

**Unnecessary get_tree() Calls:**
- ❌ Repeated `get_tree()` calls
- ✅ Cache in `@onready var tree = get_tree()`

**Array/Dictionary Operations:**
- ❌ Using `append()` in hot paths without pre-sizing
- ✅ Consider pre-allocating: `array.resize(expected_size)`

**Node Creation:**
- ❌ Instantiating nodes every frame
- ✅ Use object pooling for frequently created/destroyed nodes

**Type Conversions:**
- ❌ Unnecessary string/int conversions
- ✅ Keep consistent types

### 3. Code Organization Issues

**Check for:**

**Magic Numbers:**
```gdscript
# ❌ Bad
velocity.x = 200
health -= 15

# ✅ Good
const MAX_SPEED: float = 200.0
const BULLET_DAMAGE: int = 15
```

**Long Functions:**
- Functions over 30-40 lines (consider breaking up)
- Multiple responsibilities in one function

**Duplicate Code:**
- Similar code blocks across files (extract to shared function/class)
- Copy-pasted enemy/weapon logic (use inheritance or composition)

**Poor Naming:**
- Single-letter variables (except loops): `var d = 10`
- Unclear function names: `func do_thing()`
- Generic names: `var temp`, `var data`

**Missing Documentation:**
- No docstrings for public functions
- No comments explaining complex logic
- No `@export` hints for designer-facing variables

### 4. Memory Management

**Check for:**

**Signal Leaks:**
- ❌ Connecting signals without disconnecting: `signal.connect(callback)`
- ✅ Disconnect in `_exit_tree()` or use one-shot: `signal.connect(callback, CONNECT_ONE_SHOT)`

**Queue Free:**
- ❌ Calling `free()` directly (can cause crashes)
- ✅ Use `queue_free()` for safe deferred deletion

**Circular References:**
- Nodes holding references to each other without cleanup
- Signals creating circular dependencies

**Resource Cleanup:**
- Not freeing manually allocated resources
- Holding references to destroyed nodes

### 5. Error Handling

**Check for:**

**Null Checks:**
```gdscript
# ❌ Bad
var target = get_target()
target.take_damage(10)  # Crashes if null

# ✅ Good
var target = get_target()
if target:
    target.take_damage(10)
```

**Array Access:**
- ❌ Direct index access: `array[5]` (can crash)
- ✅ Check bounds: `if array.size() > 5:`

**Type Assumptions:**
- Assuming node types without verification
- Not checking `is_instance_valid()`

### 6. Code Duplication Patterns

**Look for repeated logic in:**
- Enemy scripts (movement, health, death)
- Weapon scripts (targeting, firing, cooldown)
- UI scripts (showing/hiding, updating)

**Suggest:**
- Base classes: `enemy_base.gd` with shared behavior
- Composition: Extract systems (health_component.gd, movement_component.gd)
- Utility functions: Shared helper scripts

### 7. Godot 4.x Specific Issues

**Check for:**

**Deprecated Syntax:**
- `onready var` → Should use `@onready var`
- `export var` → Should use `@export var`
- `yield()` → Should use `await`
- Old signal syntax → Should use `.emit()`

**New Features Not Used:**
- Not using typed Arrays: `var items: Array[Item]`
- Not using `@export_range`, `@export_enum` for better editor integration
- Not using `@warning_ignore` for intentional code patterns

### 8. Project-Specific Patterns (Mech Survivors)

**Check for:**

**Delta Scaling:**
- Using `delta` when should use `DeltaScale.get_scaled_delta(delta)` (for test acceleration)
- Inconsistent delta scaling across systems

**Manager Access:**
- Direct scene tree queries instead of using managers (PassiveManager, VFXManager, etc.)
- Creating VFX/damage numbers manually instead of using managers

**Weapon Pattern:**
- Weapons not following established pattern (target selection, cooldown, firing)
- Missing required methods: `fire()`, `select_target()`, `reset()`

**Enemy Pattern:**
- Enemies not inheriting from `enemy_base.gd`
- Not using shared health/damage/death systems

## How to Perform Analysis

1. **Identify scope**: Ask which files to analyze, or find all .gd files
2. **Read code**: Load script contents
3. **Run checks**: Go through all 8 analysis categories
4. **Cross-reference**: Look for duplication across multiple files
5. **Prioritize findings**: Critical bugs > Performance > Style
6. **Provide examples**: Show bad code and suggested refactor
7. **Generate report**: Create the markdown report content
8. **Display in chat**: Show the complete report to the user
9. **Save to file**: Write the exact same report to a markdown file in `docs/code-reviews/`

## Output Format

```markdown
# GDScript Refactor Report: [script_name].gd

## Summary
- Lines of code: X
- Issues found: X
- Severity: 🔴 Critical | 🟡 Warning | 🟢 Suggestion

---

## Critical Issues (Fix Immediately)
### 1. [Issue Name] - Line X
**Problem:**
```gdscript
# Current code
[problematic code]
```

**Impact:** [Why this is critical]

**Fix:**
```gdscript
# Suggested refactor
[improved code]
```

## Performance Warnings (Should Fix)
[Same format]

## Code Quality Suggestions (Nice to Have)
[Same format]

## Code Duplication Analysis
[If multiple files checked, show similar code blocks]

---

## Refactoring Recommendations

1. **[High-level refactor suggestion]**
   - Extract [X] to [Y]
   - Benefits: [Improved maintainability/performance/etc.]
   - Effort: [Low/Medium/High]

## Overall Assessment
[1-2 paragraph summary with priority recommendations]
```

## Report File Output

**CRITICAL: Every analysis must be saved to a file in addition to being shown in chat.**

### File Location
Save reports to: `docs/code-reviews/[script-name]_review_[YYYY-MM-DD].md`

**Examples:**
- Single file: `docs/code-reviews/player_review_2025-01-15.md`
- Multiple files: `docs/code-reviews/weapon-scripts_review_2025-01-15.md`
- Specific component: `docs/code-reviews/enemy-ai_review_2025-01-15.md`

### File Naming Convention
- Use the script name (without `.gd` extension)
- Convert to kebab-case if needed
- Append `_review_[date]` where date is YYYY-MM-DD format
- If reviewing multiple related scripts, use a descriptive group name

### Process
1. Generate the complete markdown report
2. Display the report in chat to the user
3. Use the Write tool to save the **exact same content** to the appropriate file path
4. Confirm to the user where the report was saved

### Report Header Addition
Add this metadata at the top of the saved file (but not in chat):

```markdown
---
review_date: YYYY-MM-DD
reviewed_files:
  - path/to/script1.gd
  - path/to/script2.gd
reviewer: Claude Code (gdscript-quality-checker skill)
---

```

Then include the full report content below the metadata.

## Analysis Rules

- **Be specific**: Reference exact line numbers and code snippets
- **Show examples**: Always show before/after code
- **Context matters**: Consider prototype vs. production quality
- **Prioritize correctly**: Game-breaking bugs before style issues
- **Explain "why"**: Don't just say "bad", explain the consequences
- **Godot-first**: Focus on Godot-specific issues before generic coding practices

## Important Notes

- Type safety is important but not critical for prototypes
- Prefer readability over micro-optimizations during prototyping
- Suggest refactors that reduce duplication (DRY principle)
- Highlight patterns that will cause bugs during playtesting
- Consider the "weekend prototype" context from CLAUDE.md

## Example Invocations

User: "Check my player.gd script"
User: "Review all weapon scripts for issues"
User: "Refactor the enemy AI code"
User: "Is my code following Godot best practices?"
User: "Find performance issues in my scripts"

## Workflow Summary

When this skill is invoked:
1. Analyze the specified GDScript file(s)
2. Generate comprehensive markdown report
3. **Display the report in chat**
4. **Save the exact same report to `docs/code-reviews/[name]_review_[date].md`**
5. Confirm file location to the user

This ensures both immediate feedback and persistent documentation of code reviews.
