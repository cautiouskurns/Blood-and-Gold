---
name: data-extractor
description: Execute data-driven refactorings from data-driven-refactor reports. Use this when the user wants to implement data extraction recommendations by creating data files and refactoring scripts.
domain: code-quality
type: executor
version: 1.1.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
---

# Data Extractor Skill

This skill executes data-driven refactorings based on recommendations from `data-driven-refactor` reports.

## When to Use This Skill

Invoke this skill when the user:
- Says "implement the data extraction recommendations"
- Asks to "create the data files from the analysis"
- Says "execute the data-driven refactor"
- Wants to "extract hardcoded values to config files"
- Says "apply the data analysis report"

## Core Principle

**Separate analysis from execution** for safety and control:
1. Analysis skill identifies data extraction opportunities
2. User reviews the report and chooses what to extract
3. Executor skill creates data files and refactors scripts
4. Changes are validated and tested
5. Execution report documents what was done

## Execution Workflow

### Step 1: Read the Report

**Ask user which report to execute:**
- List available reports from `docs/data-analysis/`
- Ask user to confirm which report (or specify report filename)
- Read the report markdown file

**Example:**
```
Available data analysis reports:
- weapon-system_data-analysis_2025-12-20.md
- full-project_data-analysis_2025-12-20.md

Which report should I execute?
```

### Step 2: Parse Recommendations

**Extract data extraction opportunities from the report:**
- Priority 1: High-value extractions (weapon stats, enemy data)
- Priority 2: Medium-value extractions (wave progression, upgrades)
- Priority 3: Nice-to-have extractions (UI constants, settings)

**For each recommendation, identify:**
- What data to extract (e.g., weapon stats)
- Recommended format (.tres, JSON, ConfigFile, GDScript)
- Source files (scripts with hardcoded values)
- Target files (where data should be stored)
- Refactoring steps (how to modify scripts)

### Step 3: Confirm Execution Plan

**Before making ANY changes, show the user:**
```markdown
## Data Extraction Execution Plan

I will perform the following data extractions:

### Priority 1: Weapon Statistics → Godot Resources

**Step 1:** Create Resource Script
- Create: `scripts/resources/weapon_data.gd`
- Define: WeaponData class with @export properties

**Step 2:** Create Data Files
- Create: `data/weapons/machine_gun.tres`
- Create: `data/weapons/railgun.tres`
- Create: `data/weapons/laser.tres`
- Create: `data/weapons/missiles.tres`
- Create: `data/weapons/flamethrower.tres`

**Step 3:** Refactor Scripts
- Modify: `scripts/weapons/machine_gun.gd` - Replace constants with resource loading
- Modify: `scripts/weapons/railgun.gd` - Replace constants with resource loading
- (... etc for all 5 weapons)

**Extracted values:**
- damage, fire_rate, range, projectile_speed (from each weapon)

---

### Priority 2: Enemy Data → Godot Resources

[Similar breakdown...]

---

**Total changes:**
- New files: 12
- Modified files: 7
- Directories created: 3

Proceed with execution?
```

**Wait for user confirmation before proceeding.**

### Step 4: Execute Data Extraction

**For each priority group, in order:**

#### Phase 1: Create Directory Structure
```gdscript
data/
├── weapons/
├── enemies/
├── waves/
└── balance/
```

#### Phase 2: Create Resource Scripts (if using .tres)
- Write the Resource class definition (WeaponData.gd, EnemyData.gd, etc.)
- Include all @export properties
- Add helpful @export_group and @export_range hints

#### Phase 3: Create Data Files
- Generate .tres files with extracted values
- OR generate JSON files with data
- OR generate ConfigFile (.cfg) with sections

#### Phase 4: Refactor Source Scripts
- Read each script that has hardcoded values
- Remove hardcoded constants
- Add @export or load() calls for data resources
- Replace references to constants with data file properties

#### Phase 5: Validation
- Check that all files were created
- Verify scripts can load data files
- Ensure no syntax errors

### Step 5: Testing Guidance

**After extraction, provide testing steps:**
```markdown
## Testing Your Data Extraction

1. **Open Godot Editor**
   - Verify new .tres files appear in FileSystem
   - Check that they can be opened and edited

2. **Assign Resources (if using .tres)**
   - Open weapon scenes
   - Assign corresponding .tres file to weapon_data property
   - Repeat for all entities

3. **Test in Game**
   - Run the game (F5)
   - Verify weapons still work correctly
   - Check that damage/stats are correct
   - Test all affected systems

4. **Tune and Iterate**
   - Try changing values in .tres files
   - Verify changes take effect in game
   - Confirm balancing workflow is easier
```

### Step 6: Generate Execution Report

**Save execution summary to:**
```
docs/refactoring/[report-name]_execution_[YYYY-MM-DD].md
```

## Data Extraction Types

### Type 1: Godot Resources (.tres)

**What to create:**
1. Resource script (e.g., `weapon_data.gd`)
2. Resource instances (e.g., `machine_gun.tres`)
3. Script modifications to load resources

**Example execution:**

**Create Resource Script:**
```gdscript
# scripts/resources/weapon_data.gd
class_name WeaponData
extends Resource

@export_group("Identity")
@export var weapon_name: String = ""

@export_group("Combat Stats")
@export var damage: int = 10
@export_range(0.1, 10.0) var fire_rate: float = 1.0
@export_range(0, 1000) var range: float = 300.0
@export var projectile_speed: float = 500.0

@export_group("References")
@export var projectile_scene: PackedScene
```

**Create .tres file:**
```
[gd_resource type="Resource" script_class="WeaponData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/weapon_data.gd" id="1"]

[resource]
script = ExtResource("1")
weapon_name = "Machine Gun"
damage = 5
fire_rate = 5.0
range = 300.0
projectile_speed = 500.0
```

**Refactor weapon script:**
```gdscript
# BEFORE
const DAMAGE = 5
const FIRE_RATE = 5.0
const RANGE = 300

func fire():
    projectile.damage = DAMAGE

# AFTER
@export var weapon_data: WeaponData

func fire():
    projectile.damage = weapon_data.damage
```

---

### Type 2: JSON Files

**What to create:**
1. JSON file with structured data
2. Autoload script to load JSON (if needed)
3. Script modifications to read from JSON

**Example execution:**

**Create JSON file:**
```json
{
  "machine_gun": {
    "damage": 5,
    "fire_rate": 5.0,
    "range": 300,
    "projectile_speed": 500
  },
  "railgun": {
    "damage": 100,
    "fire_rate": 0.5,
    "range": 600,
    "projectile_speed": 2000
  }
}
```

**Create loader autoload (if doesn't exist):**
```gdscript
# scripts/autoload/weapon_data_loader.gd
extends Node

var weapons: Dictionary = {}

func _ready():
    var file = FileAccess.open("res://data/weapons.json", FileAccess.READ)
    if file:
        var json = JSON.new()
        json.parse(file.get_as_text())
        weapons = json.data
        file.close()

func get_stat(weapon_id: String, stat: String):
    return weapons.get(weapon_id, {}).get(stat, 0)
```

**Refactor weapon script:**
```gdscript
# BEFORE
const DAMAGE = 5
func fire():
    projectile.damage = DAMAGE

# AFTER
func fire():
    var damage = WeaponDataLoader.get_stat("machine_gun", "damage")
    projectile.damage = damage
```

---

### Type 3: ConfigFile (.cfg)

**What to create:**
1. .cfg file with INI-style sections
2. Script modifications to load from config

**Example execution:**

**Create ConfigFile:**
```ini
[weapons.machine_gun]
damage = 5
fire_rate = 5.0
range = 300

[weapons.railgun]
damage = 100
fire_rate = 0.5
range = 600
```

**Refactor weapon script:**
```gdscript
# BEFORE
const DAMAGE = 5

# AFTER
var config = ConfigFile.new()
var damage: int

func _ready():
    config.load("res://data/game_balance.cfg")
    damage = config.get_value("weapons.machine_gun", "damage", 5)
```

---

### Type 4: GDScript Data Files

**What to create:**
1. GDScript file with const dictionaries
2. Script modifications to reference data file

**Example execution:**

**Create data file:**
```gdscript
# scripts/data/weapon_stats.gd
class_name WeaponStats
extends Node

const WEAPONS = {
    "machine_gun": {
        "damage": 5,
        "fire_rate": 5.0,
        "range": 300
    },
    "railgun": {
        "damage": 100,
        "fire_rate": 0.5,
        "range": 600
    }
}
```

**Refactor weapon script:**
```gdscript
# BEFORE
const DAMAGE = 5

# AFTER
func fire():
    var damage = WeaponStats.WEAPONS["machine_gun"]["damage"]
    projectile.damage = damage
```

---

## Safety Guidelines

### Before Execution
- ✅ Show complete execution plan with all files to be created/modified
- ✅ Wait for user confirmation
- ✅ Backup approach: All changes via git-trackable files

### During Execution
- ✅ Create files in logical order (directories → resource scripts → data files → refactor scripts)
- ✅ Validate each file creation before proceeding
- ✅ If error occurs, stop and report

### After Execution
- ✅ Generate execution report
- ✅ Provide testing instructions
- ✅ Recommend testing in Godot before committing

### What NOT to Do
- ❌ Don't proceed without user confirmation
- ❌ Don't delete original constants until data files are verified working
- ❌ Don't create files in wrong directories
- ❌ Don't modify scripts if data file creation failed

## Rollback Strategy

If issues arise after execution:

1. **Resource files not loading:**
   - Check file paths are correct
   - Verify .tres files are valid format
   - Check that scripts can find resources

2. **Values not matching:**
   - Compare extracted values to original constants
   - Verify data file has correct values
   - Check that scripts are reading correct properties

3. **Complete rollback needed:**
   - Use git to revert changes: `git checkout -- [files]`
   - Delete created data files
   - Original constants still in git history

## Execution Report Format

```markdown
# Data Extraction Execution Report

**Executed:** [YYYY-MM-DD HH:MM]
**Source Report:** docs/data-analysis/[report-name].md
**Executor:** Claude Code (data-extraction-executor skill)

---

## Summary

- ✅ Directories created: X
- ✅ Resource scripts created: Y
- ✅ Data files created: Z
- ✅ Scripts refactored: N
- ❌ Failed operations: M

---

## Phase 1: Directory Structure

✅ Created `data/weapons/`
✅ Created `data/enemies/`
✅ Created `scripts/resources/`

---

## Phase 2: Resource Scripts

### WeaponData Resource
**File:** scripts/resources/weapon_data.gd
**Properties:** weapon_name, damage, fire_rate, range, projectile_speed, projectile_scene
**Status:** ✅ Created successfully

### EnemyData Resource
**File:** scripts/resources/enemy_data.gd
**Properties:** enemy_name, max_health, movement_speed, attack_damage, xp_value
**Status:** ✅ Created successfully

---

## Phase 3: Data Files Created

### Weapon Data Files (5 files)
1. ✅ data/weapons/machine_gun.tres
2. ✅ data/weapons/railgun.tres
3. ✅ data/weapons/laser.tres
4. ✅ data/weapons/missiles.tres
5. ✅ data/weapons/flamethrower.tres

**Extracted values:**
- machine_gun: damage=5, fire_rate=5.0, range=300
- railgun: damage=100, fire_rate=0.5, range=600
- (... etc)

---

## Phase 4: Scripts Refactored

### scripts/weapons/machine_gun.gd
**Changes:**
- Removed: `const DAMAGE = 5`, `const FIRE_RATE = 5.0`, `const RANGE = 300`
- Added: `@export var weapon_data: WeaponData`
- Modified: `fire()` function to use `weapon_data.damage`
**Status:** ✅ Refactored successfully

[... etc for all scripts]

---

## Testing Instructions

### 1. Open Godot Editor
- Verify all .tres files appear in FileSystem
- Check that resource scripts are recognized

### 2. Assign Resources to Scenes
⚠️ **IMPORTANT:** You must assign the .tres files manually:

1. Open `scenes/weapons/machine_gun.tscn`
2. Select the root node with MachineGun script
3. In Inspector, find "Weapon Data" property
4. Drag `data/weapons/machine_gun.tres` to the property
5. Save the scene
6. Repeat for all 5 weapons

### 3. Test in Game
- Run game (F5)
- Verify weapons fire correctly
- Check damage values are correct
- Test all affected systems

### 4. Validate Data-Driven Workflow
- Open `data/weapons/machine_gun.tres` in Inspector
- Change damage from 5 to 10
- Run game again
- Verify damage changed
- ✅ Balancing workflow is now data-driven!

---

## Next Steps

- [ ] Assign .tres resources to scene instances (see instructions above)
- [ ] Test game functionality thoroughly
- [ ] Verify all extracted values are correct
- [ ] Try tuning values in .tres files to confirm workflow
- [ ] Commit changes if everything works

---

## Rollback Instructions (if needed)

If issues arise:
1. `git status` - see what changed
2. `git diff` - review changes
3. `git checkout -- [file]` - revert specific file
4. OR `git reset --hard HEAD` - revert all changes

Original constants are preserved in git history.
```

## Important Notes

- **Manual assignment required**: For .tres files, user must assign them to scenes in Godot Editor
- **Test thoroughly**: Data-driven changes affect core game behavior
- **Git-friendly**: All changes are text files, easy to review and revert
- **Incremental approach**: Start with one system (e.g., weapons), test, then do next

## Example Invocations

User: "Execute the weapon data extraction"
User: "Implement the data-driven refactoring from the analysis report"
User: "Create the data files from weapon-system_data-analysis_2025-12-20.md"
User: "Extract enemy stats to resources"

## Workflow Summary

1. User requests execution of a data analysis report
2. Skill lists available reports and asks for confirmation
3. Skill parses report and generates execution plan
4. **Skill shows plan and waits for user approval**
5. Skill creates directories, resource scripts, data files
6. Skill refactors source scripts to load from data files
7. Skill generates execution report with testing instructions
8. User assigns resources in Godot Editor (for .tres files)
9. User tests game to verify functionality
10. User enjoys data-driven balancing workflow!

This separation ensures safety while automating complex architectural refactorings.
