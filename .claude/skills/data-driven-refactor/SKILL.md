---
name: data-driven-refactor
description: Analyze code to identify opportunities for data-driven design by extracting hardcoded values into JSON, .tres resources, or dedicated data files. Use this when the user wants to improve data management, make balancing easier, or separate code from configuration.
domain: code-quality
type: analyzer
version: 1.2.0
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Data-Driven Refactor Skill

This skill analyzes GDScript code to identify hardcoded configuration data that should be extracted into external data files for easier tuning, balancing, and management.

## When to Use This Skill

Invoke this skill when the user:
- Asks to "make it more data-driven" or "extract data from code"
- Says "move numbers to JSON/config files"
- Wants to improve balancing workflow
- Asks "how can I tune this without changing code?"
- Says "separate data from logic"
- Requests "create config files" or "externalize settings"

## Core Principle

**Data-driven design** means separating "what" (data) from "how" (code):
- ✅ Designers can tweak without touching code
- ✅ Balance changes don't require code review
- ✅ Easy to compare configurations (git diff)
- ✅ Runtime reloading possible
- ✅ Multiple variants/presets easy to maintain

## What to Extract

### 1. Game Balance Numbers

**Identify hardcoded values that designers might want to tune:**

```gdscript
# ❌ Hardcoded in script
const MAX_SPEED = 200.0
const BULLET_DAMAGE = 15
const FIRE_RATE = 0.2
var health = 100

# ✅ Should be externalized
```

**Common balance data:**
- Weapon stats (damage, cooldown, range, projectile speed)
- Enemy stats (health, speed, attack damage, score value)
- Player stats (health, movement speed, starting weapons)
- Wave progression (spawn rates, enemy counts, difficulty scaling)
- Upgrade values (damage multipliers, cooldown reduction)
- Economy (XP values, costs, rewards)

### 2. Configuration Settings

**System-level settings:**
- Screen shake intensity/duration
- Particle effect counts
- Audio volume levels
- UI animation speeds
- Debug flags
- Test mode settings

### 3. Content Definitions

**Structured game content:**
- Enemy type definitions (name, stats, behavior type, sprite)
- Weapon loadouts (available weapons, unlock requirements)
- Passive ability definitions
- Wave definitions (timing, enemy composition)
- Upgrade tree options

### 4. Tuning Constants

**Magic numbers scattered in code:**
```gdscript
# ❌ Magic numbers
velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
if distance < 150:
    attack()

# ✅ Should be named constants in data file
# friction_deceleration: 500
# attack_range: 150
```

## Data Storage Options (Godot-Specific)

### Option 1: Godot Resources (.tres files)

**When to use:**
- Type-safe data with autocompletion
- Want Godot editor integration
- Need inheritance/composition
- Per-instance configuration

**Example:**
```gdscript
# weapon_data.gd (Resource script)
class_name WeaponData
extends Resource

@export var weapon_name: String
@export var damage: int
@export var cooldown: float
@export var range: float
@export var projectile_scene: PackedScene
```

```gdscript
# Usage in script
@export var weapon_data: WeaponData

func fire():
    var damage = weapon_data.damage
```

**Benefits:**
- Type safety
- Editor property panel
- Can reference other resources/scenes
- Drag-and-drop in editor

**Create with:** Right-click in FileSystem → New Resource → WeaponData

---

### Option 2: JSON Files

**When to use:**
- Simple key-value data
- Want human-readable format
- Easy version control diffing
- External tools might read/write
- Quick prototyping

**Example:**
```json
// data/weapons.json
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

```gdscript
# Loading in script
var weapons_data = {}

func _ready():
    var file = FileAccess.open("res://data/weapons.json", FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    weapons_data = json.data
    file.close()
```

**Benefits:**
- Simple to edit
- Good for large datasets
- Easy to compare versions
- No Godot-specific knowledge needed

---

### Option 3: GDScript Data Files

**When to use:**
- Complex data structures
- Want code completion
- Need constants/enums
- Shared across many scripts

**Example:**
```gdscript
# data/weapon_stats.gd
class_name WeaponStats
extends Node

const WEAPONS = {
    "machine_gun": {
        "damage": 5,
        "fire_rate": 5.0,
        "range": 300,
    },
    "railgun": {
        "damage": 100,
        "fire_rate": 0.5,
        "range": 600,
    }
}
```

```gdscript
# Usage
var mg_damage = WeaponStats.WEAPONS["machine_gun"]["damage"]
```

**Benefits:**
- No runtime parsing
- Type checking
- Enums and complex types
- Fast access

---

### Option 4: ConfigFile (.cfg)

**When to use:**
- INI-style settings
- User preferences
- Save game data
- Simple key-value per section

**Example:**
```ini
; data/game_balance.cfg
[player]
max_health = 100
movement_speed = 200

[weapons.machine_gun]
damage = 5
fire_rate = 5.0
```

```gdscript
var config = ConfigFile.new()
config.load("res://data/game_balance.cfg")
var damage = config.get_value("weapons.machine_gun", "damage")
```

**Benefits:**
- Built-in Godot support
- Good for settings
- Easy save/load
- Human-readable

---

## Recommended Structure for Mech Survivors

Based on project analysis, suggest this organization:

```
data/
├── weapons/
│   ├── machine_gun.tres (WeaponData resource)
│   ├── railgun.tres
│   ├── laser.tres
│   ├── missiles.tres
│   └── flamethrower.tres
├── enemies/
│   ├── scout.tres (EnemyData resource)
│   ├── tank.tres
│   ├── drone.tres
│   ├── artillery.tres
│   └── elite.tres
├── waves/
│   └── wave_progression.json
├── balance/
│   └── game_balance.cfg
└── upgrades/
    └── passives.json
```

## Analysis Process

### Step 1: Scan for Hardcoded Values

**Look for:**
- `const` declarations with numeric values
- Direct numeric assignments in `_ready()` or init
- Exported variables with default values
- Magic numbers in calculations

**Grep patterns:**
```
const.*=.*[0-9]
@export.*=.*[0-9]
```

### Step 2: Categorize Data

Group findings by:
1. **Weapon data** (all weapon scripts)
2. **Enemy data** (all enemy scripts)
3. **Player data** (player script)
4. **Wave data** (spawn/wave manager)
5. **System settings** (managers, autoloads)
6. **UI constants** (UI scripts)

### Step 3: Identify Duplication

**Look for repeated patterns:**
- Multiple weapon scripts with same variable names
- Enemy scripts with identical stat structures
- Copied configuration blocks

This indicates a need for shared data structure.

### Step 4: Recommend Format

**Decision tree:**
- **Structured game entities** (weapons, enemies) → `.tres` Resources
- **Large lists/progression data** (waves, upgrades) → JSON
- **System settings** (debug, VFX intensity) → ConfigFile
- **Shared constants** (layers, groups) → GDScript data file

### Step 5: Provide Migration Plan

For each finding:
1. Show current hardcoded version
2. Recommend data format
3. Show data file structure
4. Show refactored code
5. Estimate effort (Low/Medium/High)

### Step 6: Generate and Save Report

1. Create comprehensive markdown analysis report
2. Display the complete report in chat
3. Save the exact same report to a markdown file in `docs/data-analysis/`
4. Confirm file location to the user

## Output Format

```markdown
# Data-Driven Refactor Analysis

## Summary
- Scripts analyzed: X
- Hardcoded values found: X
- Recommended extractions: X

---

## Priority 1: Game Balance Data (High Value)

### Weapon Statistics
**Current state:** Hardcoded in 5 weapon scripts
**Problem:** Each weapon redefines damage/cooldown/range constants
**Duplication:** Same variable names across all weapons

**Current code example:**
```gdscript
# scripts/weapons/machine_gun.gd
const DAMAGE = 5
const FIRE_RATE = 5.0
const RANGE = 300
```

**Recommended approach:** Godot Resources (.tres)

**Create resource script:**
```gdscript
# scripts/resources/weapon_data.gd
class_name WeaponData
extends Resource

@export var weapon_name: String
@export_group("Combat")
@export var damage: int
@export var fire_rate: float
@export var range: float
@export_group("Visuals")
@export var projectile_scene: PackedScene
@export var muzzle_flash: PackedScene
```

**Refactor weapon scripts:**
```gdscript
# scripts/weapons/machine_gun.gd
@export var data: WeaponData

func fire():
    var projectile = data.projectile_scene.instantiate()
    projectile.damage = data.damage
```

**Create data files:**
- `data/weapons/machine_gun.tres`
- `data/weapons/railgun.tres`
- (etc. for all 5 weapons)

**Benefits:**
- Designers can tune in Godot editor
- No code changes for balance tweaks
- Easy to create weapon variants
- Type-safe with autocompletion

**Effort:** Medium (2-3 hours)

---

## Priority 2: Enemy Definitions

[Same detailed format]

---

## Priority 3: Wave Progression

[Same format, might recommend JSON]

---

## Quick Wins (Low Effort, High Value)

### 1. Player Stats → ConfigFile
**Lines:** player.gd:15-20
**Extract:** MAX_HEALTH, MOVE_SPEED, STARTING_WEAPON
**Effort:** 15 minutes

### 2. VFX Settings → GDScript Constants
**Lines:** vfx_manager.gd:8-12
**Extract:** SCREEN_SHAKE_INTENSITY, PARTICLE_POOL_SIZE
**Effort:** 10 minutes

---

## Migration Priority Order

1. ✅ **Weapon data** → Resources (enables easy weapon balancing)
2. ✅ **Enemy data** → Resources (enables easy enemy balancing)
3. ⬆️ **Wave progression** → JSON (enables wave designer workflow)
4. ➡️ **System settings** → ConfigFile (nice to have)
5. ⬇️ **UI constants** → Keep in code (rarely changed)

## Overall Recommendation

[1-2 paragraph summary with concrete next steps]
```

## Report File Output

**CRITICAL: Every analysis must be saved to a file in addition to being shown in chat.**

### File Location
Save reports to: `docs/data-analysis/[scope]_data-analysis_[YYYY-MM-DD].md`

**Examples:**
- Single file: `docs/data-analysis/player_data-analysis_2025-12-20.md`
- Multiple files: `docs/data-analysis/weapon-system_data-analysis_2025-12-20.md`
- Full project: `docs/data-analysis/full-project_data-analysis_2025-12-20.md`

### File Naming Convention
- Use descriptive scope name (what was analyzed)
- Convert to kebab-case if needed
- Append `_data-analysis_[date]` where date is YYYY-MM-DD format
- If analyzing multiple related scripts, use a descriptive group name

### Process
1. Generate the complete markdown analysis report
2. Display the report in chat to the user
3. Use the Write tool to save the **exact same content** to the appropriate file path
4. Confirm to the user where the report was saved

### Report Header Addition
Add this metadata at the top of the saved file (but not in chat):

```markdown
---
analysis_date: YYYY-MM-DD
analyzed_files:
  - path/to/script1.gd
  - path/to/script2.gd
analyzer: Claude Code (data-driven-refactor skill)
analysis_type: Data-Driven Design Opportunities
---

```

Then include the full report content below the metadata.

## Important Guidelines

- **Don't over-extract**: Some constants are truly constant (TAU, MAX_INT)
- **Consider change frequency**: Extract data that changes often during balancing
- **Group related data**: Don't create 50 tiny files; organize logically
- **Type safety matters**: Prefer Resources over JSON when possible
- **Prototype context**: For Mech Survivors, focus on weapon/enemy/wave data first
- **Editor integration**: Resources are faster to tweak than JSON during playtesting

## Red Flags for Extraction

**Definitely extract when you see:**
- Same constant names across multiple scripts
- Numbers in comments like "TODO: tune this"
- Repeated if/else chains checking hardcoded values
- Balance changes requiring code edits
- Difficulty creating variants (Elite vs Normal enemy)

## Example Invocations

User: "Make weapon stats data-driven"
User: "Extract enemy data to JSON"
User: "How can I make balancing easier?"
User: "Move all the numbers out of the code"
User: "Create config files for weapons"
User: "Separate game data from scripts"

## Workflow Summary

When this skill is invoked:
1. Scan specified GDScript file(s) for hardcoded configuration values
2. Categorize findings and recommend data storage formats
3. Generate comprehensive markdown analysis report
4. **Display the report in chat**
5. **Save the exact same report to `docs/data-analysis/[scope]_data-analysis_[date].md`**
6. Confirm file location to the user

This ensures both immediate feedback and persistent documentation of data-driven design recommendations.
