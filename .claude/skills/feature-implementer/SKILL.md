---
name: feature-implementer
description: Implement a feature spec by creating all necessary scenes, scripts, and resources. Use this when the user wants to implement a documented feature from the docs/features/ directory.
domain: implementation
type: executor
version: 2.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
  - Grep
---

# Feature Implementer Skill

This skill takes a feature specification from `docs/features/` and implements it fully, creating all necessary Godot scenes, GDScript files, resources, and configurations. **It ensures alignment with the overall game design vision** and provides detailed output on:
- **What was created** (files, systems, integrations)
- **What changed in the game** (gameplay impact, new mechanics)
- **What the player should now see** (visible differences, new UI, behaviors)
- **How to test the implementation** (step-by-step verification)

## When to Use This Skill

Invoke this skill when the user:
- Says "implement [feature-name]" or "implement the feature spec for [X]"
- Asks to "build [feature-name] from the spec"
- Says "create the implementation for [task-id]"
- Wants to "turn this spec into code"
- Says "implement docs/features/X.md"

## How to Use This Skill

**IMPORTANT: Always announce at the start that you are using the Feature Implementer skill.**

Example: "I'm using the **Feature Implementer** skill to implement the feature specification for [feature-name]."

---

## Implementation Workflow

### Phase 1: Context Gathering

**Step 1.1: Identify the Feature Spec**
- If user provides a feature name, search `docs/features/` for matching spec
- If user provides a file path, read that file directly
- If multiple matches found, ask user to clarify

**Step 1.2: Read the Feature Spec**
- Load the complete feature specification
- Parse all sections: Purpose, How It Works, Technical Implementation, etc.
- Identify acceptance criteria for validation

**Step 1.3: Read Game Design Documents**

⚠️ **CRITICAL: Always consult the overall game design before implementing.**

Search for and read these documents to ensure alignment:
- **Prototype GDD**: `docs/*prototype-gdd*.md` or `docs/*gdd*.md`
- **Vertical Slice GDD**: `docs/*vertical-slice*.md` (if exists)
- **Design Bible**: `docs/design-bible.md` (design pillars, player fantasy)
- **Systems Bible**: `docs/systems-bible.md` (technical architecture)
- **Roadmap**: `docs/*roadmap*.md` (context on where feature fits)

**Extract from game design docs:**
- Core design pillars (ensure feature supports them)
- Player fantasy (how feature reinforces the experience)
- Existing systems (how feature integrates)
- Quality bar (visual/audio standards)
- Scope boundaries (what's IN vs OUT)

**Step 1.4: Gather Project Context**
- Read existing scripts that this feature will integrate with
- Check for autoloads in `project.godot`
- Review existing scene structures in `scenes/`
- Understand signal patterns used in the project
- Look for related features already implemented

**Step 1.5: Identify Dependencies**
- Check if dependency features are implemented
- If dependencies missing, warn user and ask how to proceed
- List what systems this feature will connect to

---

### Phase 2: Implementation Planning

**Step 2.1: Design Alignment Check**

Before planning implementation, verify alignment with game design:

```markdown
## Design Alignment Check

### Design Pillars Support
- **[Pillar 1]:** How this feature supports it: [explanation]
- **[Pillar 2]:** How this feature supports it: [explanation]

### Player Fantasy Reinforcement
- This feature reinforces the player fantasy by: [explanation]

### Scope Verification
- ✅ Feature is within vertical slice scope
- ✅ Not adding anything from "What's OUT" list
- ✅ Quality bar requirements understood

### Integration with Existing Systems
- **[Existing System 1]:** Integration approach: [description]
- **[Existing System 2]:** Integration approach: [description]
```

**Step 2.2: Create Implementation Plan**

Show user the implementation plan before writing code:

```markdown
## Implementation Plan for [Feature Name]

### Design Alignment
- Supports pillars: [list]
- Reinforces: [player fantasy element]

### Files to Create
1. `scenes/[category]/[feature].tscn` - Main scene
2. `scripts/[category]/[feature].gd` - Main script
3. `scripts/[category]/[helper].gd` - Helper scripts (if needed)
4. `data/[feature]/[config].json` - Data files (if needed)

### Files to Modify
1. `project.godot` - Add autoload (if needed)
2. `scripts/core/[existing].gd` - Add integration signals
3. `scenes/[existing].tscn` - Add node references

### Integration Points
- Connects to: [list of systems]
- Emits signals: [list of signals]
- Listens for: [list of signals]

### Implementation Order
1. Create data structures/classes
2. Create main script
3. Create scene
4. Wire up signals
5. Integrate with existing systems
6. Test basic functionality

Proceed with implementation?
```

**Wait for user confirmation before proceeding.**

---

### Phase 3: Implementation Execution

**Step 3.1: Create Directory Structure**
```
Ensure directories exist:
- scenes/[category]/
- scripts/[category]/
- data/[category]/ (if needed)
- resources/[category]/ (if needed)
```

**Step 3.2: Create Core Scripts**

Follow the Technical Implementation section from the spec:
- Create class definitions with proper `class_name`
- Add all exported properties from spec
- Implement all public methods defined in spec
- Add all signals from spec
- Include comprehensive comments

**Script Template:**
```gdscript
## [Brief description from spec]
## Part of: [Feature Name]
## Spec: docs/features/[spec-file].md
class_name FeatureName
extends [BaseClass]

# ===== SIGNALS =====
signal example_signal(param: Type)

# ===== EXPORTED PROPERTIES =====
@export var example_property: Type = default_value

# ===== INTERNAL STATE =====
var _internal_state: Type

# ===== LIFECYCLE =====
func _ready() -> void:
    _connect_signals()
    _initialize()

func _connect_signals() -> void:
    # Connect to other systems
    pass

func _initialize() -> void:
    # Setup initial state
    pass

# ===== PUBLIC API =====
func public_method() -> ReturnType:
    ## Description from spec
    pass

# ===== INTERNAL METHODS =====
func _internal_method() -> void:
    pass
```

**Step 3.3: Create Scenes**

Follow the Scene Structure section from the spec:
- Create .tscn file programmatically or describe structure
- Attach scripts to appropriate nodes
- Configure node properties as specified
- Set up UI layouts if applicable

**Step 3.4: Create Data Files**

If spec includes JSON/resource data:
- Create data files in `data/` directory
- Follow schema from spec exactly
- Include all entries defined in spec

**Step 3.5: Integration**

Connect to existing systems:
- Add signal connections
- Update autoloads if needed
- Modify `project.godot` if required
- Update existing scripts to emit/receive signals

---

### Phase 4: Implementation Report

**Generate a comprehensive report after implementation. This report should be detailed enough that anyone can understand what changed, what the player experiences, and how to verify the implementation works.**

```markdown
# Feature Implementation Report

**Feature:** [Feature Name]
**Spec File:** docs/features/[spec-file].md
**Implemented:** [YYYY-MM-DD]
**Implementer:** Claude Code (feature-implementer skill)

---

## Summary

- ✅ Scripts created: X
- ✅ Scenes created: Y
- ✅ Data files created: Z
- ✅ Files modified: N
- ⚠️ Manual steps required: M

### Design Alignment Confirmed
- ✅ Supports design pillar: [Pillar Name]
- ✅ Reinforces player fantasy: [How]
- ✅ Within scope boundaries

---

## What Was Done

### Overview
[2-3 paragraph summary of what was implemented. Describe the feature at a conceptual level - what it is, what it does, why it matters to the game. Write this for someone who hasn't read the spec.]

### Technical Changes
[List the major technical changes made: new systems added, new patterns introduced, architecture decisions made]

---

## Files Created

### Scripts

#### 1. scripts/[category]/[script].gd
**Purpose:** [Brief description]
**Key Methods:**
- `method_name()` - [What it does]
- `other_method()` - [What it does]

**Signals:**
- `signal_name` - Emitted when [condition]

**Integration:**
- Connects to: [System]
- Used by: [Other scripts]

---

### Scenes

#### 1. scenes/[category]/[scene].tscn
**Root Node:** [NodeType] with [Script]
**Structure:**
```
RootNode (Control)
├── ChildNode (VBoxContainer)
│   ├── SubChild (Label)
│   └── SubChild (Button)
└── AnotherChild (Panel)
```

**How to Use:**
- Instance this scene via `[scene].tscn`
- OR access via autoload if configured

---

### Data Files

#### 1. data/[category]/[file].json
**Contains:** [Description of data]
**Schema:**
```json
{
  "key": "value type and meaning"
}
```

---

## Files Modified

### 1. project.godot
**Changes:**
- Added autoload: `FeatureName` → `res://scripts/[path].gd`

### 2. scripts/existing/[script].gd
**Changes:**
- Added signal emission for [event]
- Added connection to [new system]

---

## What Changed in the Game

### Gameplay Impact
[Describe how this feature affects gameplay. Be specific about mechanics, interactions, and player decisions that are now different.]

**Before Implementation:**
- [What the game was like before - behaviors, limitations, missing features]

**After Implementation:**
- [What the game is like now - new capabilities, new behaviors, improved systems]

### New Mechanics Introduced
1. **[Mechanic Name]:** [Description of what it does and how it works]
2. **[Mechanic Name]:** [Description]

### Systems Affected
- **[System Name]:** [How it was affected - new signals, new data, new behaviors]
- **[System Name]:** [How it was affected]

---

## What the Player Should Now See

### Visible Differences

⚠️ **IMPORTANT: This section describes exactly what a player/tester will observe that's different.**

#### In Menus/UI
- [Describe any new UI elements, buttons, screens, indicators]
- [Describe changes to existing UI]
- [Describe new information displayed]

#### During Gameplay
- [Describe new visual feedback]
- [Describe new behaviors they'll observe]
- [Describe new interactions available]
- [Describe changes to existing gameplay flow]

#### Audio (if applicable)
- [New sounds they'll hear]
- [When sounds trigger]

### Step-by-Step: What the Player Experiences

**Scenario: [Common use case]**
1. Player does [action]
2. They see [visual result]
3. The game responds with [behavior]
4. Player can now [new capability]

**Scenario: [Another use case]**
1. [Steps...]

### What the Developer Should See

#### In Godot Editor

1. **FileSystem Panel:**
   - New folder: `scripts/[category]/`
   - New scripts: `[list of .gd files]`
   - New scenes: `[list of .tscn files]`

2. **Autoload (Project Settings > Autoload):**
   - [FeatureName] should appear in the list

3. **Scene Inspector:**
   - Opening `[scene].tscn` should show [expected structure]

#### Console Output (Debug)

Expected debug output when feature is working:
```
[FeatureName] Initialized
[FeatureName] Connected to CombatManager
[FeatureName] Ready
```

---

## How to Test

### Quick Smoke Test (2 minutes)

The fastest way to verify the feature works:

1. Open Godot Editor
2. Press F5 to run the game
3. [Step 3 - specific action to take]
4. [Step 4 - what to look for]
5. ✅ **Success if:** [What confirms it's working]
6. ❌ **Failure if:** [What indicates a problem]

### Comprehensive Testing Checklist

#### Core Functionality
- [ ] **Test 1:** [Description]
  - **Steps:** [Detailed steps to perform]
  - **Expected:** [Exact result to observe]
  - **Verified by:** [Who tested / when]

- [ ] **Test 2:** [Description]
  - **Steps:** [Detailed steps]
  - **Expected:** [Result]

#### Acceptance Criteria Verification

From the feature spec, verify each criterion:

- [ ] **Criterion 1:** [Description from spec]
  - **How to test:** [Step-by-step instructions]
  - **Expected result:** [Exact observable outcome]

- [ ] **Criterion 2:** [Description]
  - **How to test:** [Steps]
  - **Expected result:** [Outcome]

[... continue for ALL acceptance criteria from spec]

#### Edge Case Tests

- [ ] **Edge case: [Description]**
  - **How to trigger:** [Specific steps]
  - **Expected behavior:** [Graceful handling]

- [ ] **Edge case: [Description]**
  - **How to trigger:** [Steps]
  - **Expected:** [Handling]

#### Integration Tests

- [ ] **With [System 1]:**
  - **Scenario:** [What to test]
  - **Steps:** [How to test]
  - **Verify:** [Expected interaction]

- [ ] **With [System 2]:**
  - **Scenario:** [What to test]
  - **Steps:** [How to test]
  - **Verify:** [Expected behavior]

#### Negative Tests (What Should NOT Happen)

- [ ] **Should NOT:** [Undesired behavior]
  - **Test:** [How to verify it doesn't happen]

### Automated/Script Tests (if created)

```bash
# Run headless tests
"/path/to/Godot" --path . --headless res://scenes/tests/test_[feature].tscn
```

Expected output:
```
[Test output showing pass/fail]
```

---

## Manual Steps Required

⚠️ **The following steps must be completed manually:**

### 1. [Step Name]
**Why:** [Explanation of why this can't be automated]
**How:**
1. Open [file/location]
2. Do [action]
3. Save changes
**Verify:** [How to confirm step was done correctly]

### 2. [Step Name]
**Why:** [Explanation]
**How:**
1. [Steps...]
**Verify:** [Confirmation]

---

## Troubleshooting

### Issue: [Common problem]
**Symptom:** [What you see - error messages, behaviors]
**Cause:** [Why it happens]
**Fix:** [Step-by-step resolution]

### Issue: [Another problem]
**Symptom:** [What you see]
**Cause:** [Why it happens]
**Fix:** [How to resolve]

### Issue: Feature doesn't appear to work
**Symptom:** No visible change after implementation
**Possible causes:**
1. Autoload not registered in project.godot
2. Scene not instanced in game flow
3. Signals not connected
**Debug steps:**
1. Check Project Settings > Autoload
2. Check scene tree during runtime
3. Add print statements to verify code execution

---

## Next Steps

After verifying this feature works:

1. [ ] Run full playtest to check integration
2. [ ] Test with existing save files (if applicable)
3. [ ] Implement dependent features: [list]
4. [ ] Consider polish items: [list from spec]
5. [ ] Update changelog
6. [ ] Commit changes

---

## Rollback Instructions

If implementation has issues:

```bash
# See what changed
git status

# Review changes
git diff

# Revert specific file
git checkout -- [file]

# Revert all changes
git reset --hard HEAD
```

All original code preserved in git history.
```

---

## Implementation Guidelines

### Code Style

Follow project conventions:
- Use `snake_case` for functions and variables
- Use `PascalCase` for class names
- Use `SCREAMING_SNAKE_CASE` for constants
- Add type hints to all parameters and return values
- Include doc comments for public methods

### Signal Patterns

Follow existing signal patterns in the project:
```gdscript
# Define signals at top of class
signal state_changed(old_state: State, new_state: State)

# Emit with all parameters
state_changed.emit(previous, current)

# Connect using callable syntax
other_node.state_changed.connect(_on_state_changed)
```

### Scene Organization

Follow project scene organization:
```
scenes/
├── combat/       # Combat-related scenes
├── ui/           # UI screens and components
├── menus/        # Menu screens
├── entities/     # Mech, enemy scenes
└── effects/      # Visual effects
```

### Script Organization

Follow project script organization:
```
scripts/
├── core/         # Core systems (autoloads)
├── combat/       # Combat logic
├── ui/           # UI scripts
├── data/         # Data loaders
├── entities/     # Entity scripts
└── effects/      # Effect scripts
```

---

## Safety Guidelines

### Before Implementation
- ✅ Read the complete feature spec
- ✅ Identify all dependencies
- ✅ Check for existing implementations that might conflict
- ✅ Show implementation plan to user
- ✅ Wait for user confirmation

### During Implementation
- ✅ Create files in correct directories
- ✅ Follow scene structure from spec exactly
- ✅ Implement all methods defined in spec
- ✅ Add all signals defined in spec
- ✅ Validate syntax before moving to next file

### After Implementation
- ✅ Generate comprehensive implementation report
- ✅ List all files created/modified
- ✅ Provide testing instructions
- ✅ Document manual steps required
- ✅ Include troubleshooting guidance

### What NOT to Do
- ❌ Don't skip reading the full spec
- ❌ Don't implement without showing plan first
- ❌ Don't deviate from spec without noting it
- ❌ Don't leave placeholder code
- ❌ Don't forget to update project.godot for autoloads
- ❌ Don't forget signal connections

---

## Example Invocations

User: "Implement the energy system from the feature spec"
User: "Build 1.2-player-mech-energy-movement"
User: "Implement docs/features/3.2-morale-system-core.md"
User: "Create the save/load system from the spec"
User: "Turn the combat HUD spec into code"

---

## Workflow Summary

1. **User requests implementation** of a feature spec
2. **Skill identifies and reads** the feature spec file
3. **Skill gathers project context** (existing code, patterns, dependencies)
4. **Skill generates implementation plan** with all files to create/modify
5. **User confirms** the implementation plan
6. **Skill creates directories** if needed
7. **Skill creates scripts** following spec's Technical Implementation
8. **Skill creates scenes** following spec's Scene Structure
9. **Skill creates data files** if specified
10. **Skill integrates** with existing systems (signals, autoloads)
11. **Skill generates implementation report** with:
    - Summary of what was created
    - What developer should see in editor
    - What developer should see when running
    - Step-by-step testing instructions
    - Manual steps required
    - Troubleshooting guide
12. **User tests** the implementation
13. **User enjoys** the working feature!

This skill transforms documented specifications into working code while providing complete transparency about what was done and how to verify it works.
