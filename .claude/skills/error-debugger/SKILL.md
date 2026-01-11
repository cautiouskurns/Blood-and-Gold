---
name: error-debugger
description: Debug errors from screenshots with deep analysis to fix the immediate issue and proactively identify related errors. Use this when the user provides an error screenshot, says "debug this", or wants to fix runtime/compile errors.
domain: debugging
type: debugger
version: 1.0.0
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash
  - Task
---

# Error Debugger Skill

This skill analyzes error screenshots to fix the immediate issue and proactively identify related errors that might emerge, reducing the need for repeated debugging cycles.

## When to Use This Skill

Invoke this skill when the user:
- Provides a screenshot of an error (console, editor, runtime)
- Says "debug this", "fix this error", or "what's wrong?"
- Has a Godot error message they need help with
- Wants to understand why something isn't working
- Shows a crash log or stack trace

## Core Philosophy

**Fix Once, Fix Completely:**
1. Fix the immediate error shown in the screenshot
2. Trace the error to its root cause
3. Identify related code paths that might have similar issues
4. Find dependent systems that could break as a result
5. Prevent the "fix one bug, create three more" cycle

## Analysis Process

### Phase 1: Screenshot Analysis

When presented with an error screenshot:

1. **Extract Error Information:**
   - Error type (Parser error, Runtime error, Signal error, Null reference, etc.)
   - Error message text
   - File path and line number
   - Stack trace (if visible)
   - Any context visible in the screenshot

2. **Classify Error Severity:**
   - 🔴 **Critical**: Crashes, data loss, blocks gameplay
   - 🟡 **Warning**: Incorrect behavior, may cause issues
   - 🟢 **Info**: Minor issue, easy fix

### Phase 2: Locate and Understand the Error

1. **Read the problematic file** at the indicated line
2. **Read surrounding context** (50+ lines around the error)
3. **Understand what the code is trying to do**
4. **Identify the specific cause of the error**

### Phase 3: Fix the Immediate Error

1. **Determine the fix** for the exact error
2. **Apply the fix** using Edit tool
3. **Verify the fix** makes sense in context

### Phase 4: Deep Analysis - Related Errors

This is the CRITICAL differentiator. After fixing the immediate error:

#### 4.1 Same-File Analysis
```
Look for in the same file:
- Similar patterns that have the same bug
- Other places using the same variable/function incorrectly
- Missing null checks elsewhere
- Inconsistent type usage
- Similar logic that could fail the same way
```

#### 4.2 Call Chain Analysis
```
Trace outward from the error:
- What calls this function? Do callers pass correct parameters?
- What does this function call? Could those fail?
- What signals connect here? Are they properly connected?
- What scene tree dependencies exist? Are they guaranteed?
```

#### 4.3 Pattern Search
```
Search the codebase for:
- Same anti-pattern used elsewhere
- Similar function names that might have same issue
- Same problematic API usage
- Related class implementations
```

#### 4.4 Dependency Analysis
```
Consider:
- If this function now works correctly, do its callers expect that?
- Does fixing this break any assumptions elsewhere?
- Are there tests that depend on the old (broken) behavior?
- What systems depend on the fixed behavior?
```

### Phase 5: Apply All Fixes

For each related issue found:
1. **Document the issue**
2. **Apply the fix** if straightforward
3. **Flag for review** if complex or risky
4. **Update tests** if needed

## Error Type Patterns

### Null Reference Errors
```gdscript
# Error: Invalid get index 'X' (on base: 'Nil')
# Or: Attempted to call function on a null instance

# Search Pattern:
# Find all uses of the null variable
# Check ALL places where this could be null
# Add null guards everywhere needed
```

**Related Issues to Check:**
- Other variables initialized the same way
- Same pattern in sibling classes
- Scene tree nodes that might not exist
- Resources that might fail to load

### Parser/Syntax Errors
```gdscript
# Error: Parse Error: Expected "X" but got "Y"
# Or: Unexpected token

# Usually isolated, but check:
# - Was this from a copy-paste?
# - Is the same mistake elsewhere?
# - Did a refactor break multiple places?
```

### Signal Connection Errors
```gdscript
# Error: Signal "X" is not present in object

# Related Issues to Check:
# - Is the signal defined?
# - Is the node the right type?
# - Are other signals connected correctly?
# - Scene tree order issues?
```

### Type Errors
```gdscript
# Error: Invalid type in function "X" parameter

# Related Issues to Check:
# - Other calls to same function
# - Similar function calls with same parameter pattern
# - Array/Dictionary type assumptions
```

### Load/Preload Errors
```gdscript
# Error: Unable to load resource at path "X"

# Related Issues to Check:
# - Other resources loaded from same directory
# - Path typos elsewhere
# - Missing export configurations
# - Case sensitivity issues (cross-platform)
```

### Scene Tree Errors
```gdscript
# Error: Node not found: "X"

# Related Issues to Check:
# - Timing issues (node not ready)
# - Scene structure changes
# - @onready vs. manual get_node
# - Dynamic node creation/deletion
```

## Output Format

After fixing, provide a summary:

```markdown
# Debug Report

## Error Fixed
**File:** `path/to/file.gd:123`
**Error:** [Original error message]
**Cause:** [What caused it]
**Fix:** [What was changed]

---

## Related Issues Found and Fixed

### Issue 1: [Description]
**File:** `path/to/other_file.gd:45`
**Problem:** [Same pattern / related issue]
**Fix:** [What was changed]

### Issue 2: [Description]
...

---

## Potential Issues Flagged (Need Review)

### Warning 1: [Description]
**File:** `path/to/file.gd:89`
**Concern:** [Why this might be a problem]
**Recommendation:** [What to check or fix]

---

## Prevention Tips

1. [How to avoid this error in future]
2. [Pattern or practice to adopt]
```

## Search Strategies by Error Type

### For Null Reference Errors
```bash
# Find all uses of the null variable
Grep: variable_name
Grep: .get_node.*NodeName
Grep: \$NodeName

# Find similar access patterns
Grep: \.property_name
Grep: get_node\(
```

### For Missing Method/Property Errors
```bash
# Find all calls to missing method
Grep: \.method_name\(

# Find class definition
Grep: class_name ClassName
Grep: func method_name
```

### For Signal Errors
```bash
# Find signal definition
Grep: signal signal_name

# Find all connections
Grep: \.connect\(.*signal_name
Grep: signal_name\.connect
```

### For Resource Load Errors
```bash
# Find all loads of similar resources
Grep: load\("res://
Grep: preload\("res://

# Check resource exists
Glob: **/resource_name*
```

## Important Guidelines

1. **ALWAYS read the file first** - Never guess at the code
2. **Fix the immediate error FIRST** - Then look for related issues
3. **Be thorough but not paranoid** - Focus on likely related issues
4. **Explain your reasoning** - Help the user understand the fix
5. **Apply fixes directly** - Don't just suggest, actually fix
6. **Test awareness** - Mention if the user should test something specific
7. **Don't over-engineer** - Simple fixes are better than complex ones

## Example Invocations

User: "Debug this" [with screenshot of error]
User: "Fix this error" [with screenshot]
User: "Why is this crashing?" [with error output]
User: "Help me fix this" [with console screenshot]
User: "What's wrong with my code?" [with error screenshot]

## Workflow Summary

When this skill is invoked:
1. **Read the screenshot** - Extract all error information
2. **Locate the error** - Read the file and surrounding context
3. **Fix the immediate error** - Apply the direct fix
4. **Deep analysis** - Search for related issues
5. **Fix related issues** - Apply fixes to all found problems
6. **Report** - Provide summary of all fixes and warnings
7. **Prevention tips** - Help avoid similar errors in future

This ensures single-pass debugging that catches cascading issues before they manifest.
