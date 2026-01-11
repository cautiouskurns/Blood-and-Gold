---
name: systems-bible-updater
description: Create and maintain a Systems Bible documenting all technical systems, their architectures, interactions, and implementation details. Use this when building systems, refactoring, or onboarding developers to the codebase.
domain: technical
type: updater
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Systems Bible Updater Skill

This skill creates and maintains a comprehensive Systems Bible that documents all technical systems, their architectures, APIs, data flows, and implementation details.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "document the [system] architecture"
- Asks "create systems documentation"
- Implements a new system and wants to document it
- Says "update systems bible with [feature]"
- Needs to onboard new developers
- Refactors a system and wants to update docs
- Asks "how does [system] work?"
- Wants to understand system dependencies and interactions

---

## Core Principle

**Systems Bibles are technical knowledge bases**:
- ✅ Document HOW systems work (not why - that's Design Bible)
- ✅ Capture architecture, data flows, APIs
- ✅ Enable onboarding and knowledge transfer
- ✅ Prevent knowledge silos
- ✅ Guide refactoring and debugging
- ✅ Living document updated as systems evolve

---

## Systems Bible vs Design Bible vs GDD

| Aspect | Systems Bible | Design Bible | GDD |
|--------|---------------|--------------|-----|
| **Purpose** | HOW systems work technically | WHY design decisions | WHAT features exist |
| **Audience** | Programmers | Designers | Entire team |
| **Content** | Architecture, code, data flows | Vision, pillars | Mechanics, specs |
| **Detail** | Implementation details | High-level philosophy | Feature descriptions |
| **Updates** | When refactoring/adding systems | Rarely (foundational) | Frequently |

---

## Systems Bible Structure

```markdown
# [GAME TITLE] - Systems Bible

**Version:** [X.Y]
**Engine:** Godot [Version]
**Language:** GDScript / C# / etc.
**Last Updated:** [Date]

---

## TABLE OF CONTENTS

1. [Project Architecture](#project-architecture)
2. [Core Systems](#core-systems)
3. [Managers & Autoloads](#managers--autoloads)
4. [Data Systems](#data-systems)
5. [System Interactions](#system-interactions)
6. [Performance Considerations](#performance-considerations)
7. [Debugging & Tools](#debugging--tools)
8. [Common Patterns](#common-patterns)

---

## PROJECT ARCHITECTURE

### Directory Structure

```
mech-survivors/
├── scenes/
│   ├── main/           # Main game scenes
│   ├── ui/             # UI screens
│   ├── enemies/        # Enemy scenes
│   └── weapons/        # Weapon scenes
├── scripts/
│   ├── autoload/       # Singleton managers
│   ├── systems/        # Core system scripts
│   ├── enemies/        # Enemy behavior
│   ├── weapons/        # Weapon scripts
│   └── resources/      # Custom Resource types
├── data/               # External data (JSON, Resources)
│   ├── weapons/        # WeaponData resources
│   └── enemies/        # EnemyData resources
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── docs/               # Documentation
```

### Naming Conventions

**Files:**
- Scenes: `PascalCase.tscn` (e.g., `Player.tscn`)
- Scripts: `snake_case.gd` (e.g., `player.gd`)
- Resources: `PascalCase.tres` (e.g., `MachineGun.tres`)

**Code:**
- Classes: `PascalCase` (e.g., `WeaponManager`)
- Variables: `snake_case` (e.g., `current_health`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_SPEED`)
- Signals: `snake_case` (e.g., `health_changed`)
- Private variables: `_snake_case` (e.g., `_internal_state`)

### Autoload Singletons

**Registered autoloads** (Project → Project Settings → Autoload):
1. **GameState** - Global game state, pause, score
2. **WeaponManager** - Weapon spawning and management
3. **PassiveManager** - Passive ability tracking
4. **DamageNumberManager** - Damage number display
5. **VFXManager** - Visual effects pooling

---

## CORE SYSTEMS

[Document each major system]

### System: Player Movement & Combat

**Purpose:** Handle player-controlled mech movement, collision, and weapon management

**File:** `scripts/systems/player.gd`

**Architecture:**
```
Player (CharacterBody2D)
  ├─ Components:
  │   ├─ CollisionShape2D (physics body)
  │   ├─ Sprite2D (visual)
  │   └─ WeaponAttachPoints (Node2D container)
  │
  ├─ Managed By:
  │   └─ Main scene (spawns player)
  │
  └─ Interacts With:
      ├─ WeaponManager (adds weapons)
      ├─ GameState (reports death, level-ups)
      └─ EnemyBullet (takes damage)
```

**Key Properties:**
```gdscript
@export var max_health: int = 100
@export var move_speed: float = 200.0
var current_health: int
var velocity: Vector2
var xp: int = 0
```

**Key Methods:**

#### `_physics_process(delta: float) -> void`
**Called:** Every physics frame (60 FPS)
**Purpose:** Handle movement and collision
**Logic:**
1. Read input vector from Input.get_vector()
2. Calculate velocity (input * move_speed)
3. Call move_and_slide()
4. Clamp position to world bounds

#### `take_damage(amount: int) -> void`
**Called By:** EnemyBullet collision, Enemy collision
**Purpose:** Reduce health, handle death
**Logic:**
1. current_health -= amount
2. Emit health_changed signal
3. If health <= 0 → call die()

#### `add_xp(amount: int) -> void`
**Called By:** Enemy death events
**Purpose:** Add XP, trigger level-ups
**Logic:**
1. xp += amount
2. Check if xp >= next_level_threshold
3. If yes → emit level_up signal, increment level

**Signals:**
```gdscript
signal health_changed(current: int, max: int)
signal died()
signal level_up(level: int)
```

**Dependencies:**
- WeaponManager (to spawn weapons)
- GameState (to report death)
- World bounds constant (WORLD_BOUNDS)

**Data Flow:**
```
Input → _physics_process() → velocity → move_and_slide() → position

EnemyBullet → take_damage() → health_changed → HUD update
                            → died → GameState.game_over()

Enemy kill → add_xp() → xp check → level_up → Main.show_level_up_menu()
```

**Performance Notes:**
- Movement is physics-frame based (60 FPS, not render FPS)
- Collision uses CharacterBody2D (efficient for kinematic movement)
- No expensive operations in _physics_process()

---

### System: Weapon Rule System

**Purpose:** Allow weapons to auto-target based on programmed rules

**Files:**
- `scripts/systems/weapon_manager.gd` (singleton)
- `scripts/weapons/weapon_base.gd` (base class)
- `scripts/weapons/machine_gun.gd` (example implementation)

**Architecture:**
```
WeaponManager (Autoload Singleton)
  ├─ Responsibilities:
  │   ├─ Spawn weapons on player
  │   ├─ Store weapon configurations
  │   └─ Provide weapon instances
  │
  └─ Used By:
      ├─ Player (requests weapon spawns)
      ├─ Main (level-up weapon additions)
      └─ LevelUpMenu (weapon upgrade choices)

WeaponBase (Base Class)
  ├─ Properties:
  │   ├─ target_priority: TargetPriority enum
  │   ├─ firing_condition: FiringCondition enum
  │   └─ cooldown: float
  │
  └─ Inherited By:
      ├─ MachineGun
      ├─ Railgun
      ├─ Laser
      ├─ Missiles
      └─ Flamethrower
```

**Enums:**

```gdscript
enum TargetPriority {
    CLOSEST,      # Fire at nearest enemy
    WEAKEST,      # Fire at lowest HP enemy
    STRONGEST,    # Fire at highest HP enemy
    GROUP,        # Fire at clusters (3+ enemies)
    ELITE_ONLY    # Fire only at elite/boss enemies
}

enum FiringCondition {
    ALWAYS,           # Fire whenever loaded
    OPTIMAL_RANGE,    # Only fire within ideal range
    SAVE_FOR_ELITE,   # Don't waste ammo on normal enemies
    HIGH_HEALTH_ONLY  # Only fire if target HP > 50%
}
```

**Key Methods:**

#### `WeaponBase._process(delta: float) -> void`
**Purpose:** Handle targeting and firing logic
**Logic:**
1. Update cooldown timer
2. If cooldown ready:
   a. Query all enemies in range
   b. Filter by firing_condition (is target valid?)
   c. Sort by target_priority (which target is best?)
   d. Call _fire(target)
   e. Reset cooldown

#### `WeaponBase._fire(target: Node2D) -> void`
**Purpose:** Abstract method, implemented by weapon types
**Implemented By:**
- MachineGun: Spawn bullet projectile
- Railgun: Instant raycast hit
- Laser: Enable beam, continuous damage
- Missiles: Spawn homing missile
- Flamethrower: Enable cone area, tick damage

**Targeting Algorithm:**

```gdscript
func _get_best_target() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var valid_targets = []

    # Filter by firing condition
    for enemy in enemies:
        if _is_valid_target(enemy):
            valid_targets.append(enemy)

    if valid_targets.is_empty():
        return null

    # Sort by target priority
    match target_priority:
        TargetPriority.CLOSEST:
            return _get_closest(valid_targets)
        TargetPriority.WEAKEST:
            return _get_weakest_hp(valid_targets)
        TargetPriority.STRONGEST:
            return _get_strongest_hp(valid_targets)
        TargetPriority.GROUP:
            return _get_clustered(valid_targets)
        TargetPriority.ELITE_ONLY:
            return _get_elite(valid_targets)

    return null
```

**Data Flow:**
```
LoadoutScreen → Set weapon rules (target_priority, firing_condition)
                ↓
Player spawns → WeaponManager.add_weapon()
                ↓
Weapon._process() → Query enemies → Filter by condition → Sort by priority
                ↓
_fire(target) → Spawn bullet / raycast / beam / missile
                ↓
Bullet hits enemy → Enemy.take_damage()
```

**Performance Optimization:**
- Weapons cache `get_tree().get_nodes_in_group("enemies")` result per frame
- Firing condition filter reduces sorting workload
- Cooldown prevents per-frame targeting (only when weapon ready to fire)

---

### System: Wave Spawning

**Purpose:** Spawn enemies in escalating waves over 15-minute runs

**File:** `scripts/systems/main.gd` (handles wave spawning)

**Architecture:**
```
Main Scene
  ├─ WaveSpawner (Timer-based)
  │   ├─ Tracks elapsed time
  │   ├─ Reads wave definitions
  │   └─ Spawns enemy instances
  │
  └─ Enemy Pooling (planned)
      └─ Pre-instantiate enemies for performance
```

**Wave Progression:**

| Time (min) | Enemy Types | Spawn Rate | Notes |
|------------|-------------|------------|-------|
| 0-5 | Scout only | 5/sec | Tutorial phase |
| 5-10 | Scout, Tank, Drone | 8/sec | Mixed threats |
| 10-15 | All 5 types | 12/sec | Chaos phase |
| 15 | Final Boss | 3 Elites | Victory condition |

**Spawning Logic:**

```gdscript
func _on_spawn_timer_timeout():
    var elapsed = Time.get_ticks_msec() / 1000.0
    var enemy_type = _determine_enemy_type(elapsed)
    var spawn_pos = _get_random_spawn_position()

    var enemy = enemy_type.instantiate()
    enemy.global_position = spawn_pos
    add_child(enemy)
```

**Spawn Position Algorithm:**
```gdscript
func _get_random_spawn_position() -> Vector2:
    var player_pos = player.global_position
    var offset = Vector2(randf_range(400, 600), 0).rotated(randf() * TAU)
    return player_pos + offset
```
(Spawns 400-600px away from player, random angle)

**Dependencies:**
- Enemy scenes (preloaded)
- Player position (spawn relative to player)
- GameState.elapsed_time

---

### System: XP & Level-Up

**Purpose:** Track XP, trigger level-ups, show upgrade choices

**Files:**
- `scripts/systems/player.gd` (XP tracking)
- `scripts/systems/main.gd` (level-up UI)
- `scripts/ui/level_up_menu.gd` (upgrade UI)

**Architecture:**
```
Enemy dies → Enemy.queue_free() → emits "died" signal
                ↓
Player.on_enemy_died(xp_value) → player.add_xp(xp_value)
                ↓
Player.add_xp() → check threshold → emit level_up
                ↓
Main._on_player_level_up() → pause game → show LevelUpMenu
                ↓
LevelUpMenu → show 3 random choices (weapon/upgrade/passive)
                ↓
Player selects → apply upgrade → resume game
```

**XP Curve:**

```gdscript
const XP_THRESHOLDS = [
    100,   # Level 2
    250,   # Level 3
    450,   # Level 4
    700,   # Level 5
    1000,  # Level 6
    # ... continues
]
```

**Upgrade Types:**
1. **Add Weapon:** WeaponManager.add_weapon(weapon_type)
2. **Upgrade Weapon:** weapon.damage *= 1.2 or weapon.cooldown *= 0.8
3. **Passive Buff:** player.max_health *= 1.2 or player.move_speed *= 1.2

---

## MANAGERS & AUTOLOADS

[Document each singleton manager]

### GameState (Autoload)

**Path:** `scripts/autoload/game_state.gd`

**Responsibilities:**
- Track global game state (running, paused, game_over)
- Store run statistics (time, kills, level)
- Emit pause/resume signals
- Handle game over flow

**Key Properties:**
```gdscript
var is_paused: bool = false
var is_game_over: bool = false
var elapsed_time: float = 0.0
var total_kills: int = 0
var player_level: int = 1
```

**Signals:**
```gdscript
signal game_paused()
signal game_resumed()
signal game_over(stats: Dictionary)
```

**Used By:**
- Main (tracks time, handles game over)
- PauseMenu (pause/resume)
- Player (reports death)
- Enemy (reports kills)

---

### WeaponManager (Autoload)

**Path:** `scripts/autoload/weapon_manager.gd`

**Responsibilities:**
- Preload weapon scenes
- Spawn weapons on player
- Track equipped weapons
- Provide weapon upgrade access

**Key Methods:**

#### `add_weapon(weapon_type: String, attach_point: Node2D) -> void`
**Purpose:** Instantiate and attach weapon to player
```gdscript
func add_weapon(weapon_type: String, attach_point: Node2D):
    var weapon_scene = WEAPON_SCENES[weapon_type]
    var weapon = weapon_scene.instantiate()
    attach_point.add_child(weapon)
    equipped_weapons.append(weapon)
```

#### `get_equipped_weapons() -> Array[WeaponBase]`
**Purpose:** Return list of all equipped weapons (for upgrades)

---

## DATA SYSTEMS

### Resource-Based Data (Data-Driven Design)

**Purpose:** Externalize configuration for easy balancing

**Structure:**
```
data/
├── weapons/
│   ├── MachineGun.tres (WeaponData)
│   ├── Railgun.tres
│   └── ...
└── enemies/
    ├── Scout.tres (EnemyData)
    ├── Tank.tres
    └── ...
```

**WeaponData Resource:**

```gdscript
# scripts/resources/weapon_data.gd
class_name WeaponData
extends Resource

@export var weapon_name: String
@export var damage: int
@export var fire_rate: float
@export var range: float
@export var projectile_scene: PackedScene
```

**Usage in Scripts:**

```gdscript
# Machine gun script
extends WeaponBase

@export var data: WeaponData

func _fire(target: Node2D):
    var bullet = data.projectile_scene.instantiate()
    bullet.damage = data.damage
    # ...
```

**Benefits:**
- Designers can edit .tres files in Godot editor
- No code changes for balance tweaks
- Easy to create weapon variants

---

## SYSTEM INTERACTIONS

### System Dependency Graph

```
Player
  ├─ depends on → WeaponManager (to add weapons)
  ├─ depends on → GameState (to report death)
  └─ interacts with → Enemies (collision, damage)

WeaponBase
  ├─ depends on → Enemy group (to query targets)
  └─ spawns → Bullets (projectiles)

Main
  ├─ depends on → GameState (pause, game over)
  ├─ spawns → Player
  ├─ spawns → Enemies (wave system)
  └─ manages → UI (level-up, pause menu)

GameState (Autoload)
  └─ used by → Everything (global state)
```

### Event Flow: Player Death

```
Enemy hits Player → Player.take_damage()
                        ↓
Player.current_health <= 0 → Player.die()
                        ↓
emit "died" signal → Main._on_player_died()
                        ↓
GameState.game_over() → pause game → show DeathScreen
                        ↓
DeathScreen displays stats → player clicks Retry → reload scene
```

---

## PERFORMANCE CONSIDERATIONS

### Critical Performance Paths

**Enemy Targeting (60 FPS):**
- Each weapon queries `get_tree().get_nodes_in_group("enemies")` every frame
- **Optimization:** Cache enemy list, update once per frame globally
- **Target:** <1ms for 100 enemies, 5 weapons

**Wave Spawning:**
- Instantiating enemies is expensive
- **Optimization:** Object pooling (reuse enemy instances)
- **Target:** Spawn 20 enemies/sec without frame drops

**Bullet Collision:**
- Potentially hundreds of bullets on screen
- **Optimization:** Use Area2D with collision layers, disable when off-screen
- **Target:** 500 active bullets at 60 FPS

### Profiling Tools

**Godot Profiler:** Debug → Profiler
- Monitor _process() and _physics_process() times
- Track node count

**Custom Metrics:**
```gdscript
# Add to autoload DebugStats
var enemy_count: int
var bullet_count: int
var frame_time: float
```

---

## DEBUGGING & TOOLS

### Debug Flags

**File:** `scripts/autoload/game_state.gd`

```gdscript
const DEBUG_MODE = true
const DEBUG_INVINCIBLE = false
const DEBUG_INFINITE_XP = false
```

### Debug Shortcuts

**In-game hotkeys:**
- `F1` → Toggle debug overlay (enemy count, FPS, etc.)
- `F2` → Add 100 XP (test level-ups)
- `F3` → Spawn elite enemy (test boss)
- `F4` → Toggle invincibility

### Logging Conventions

```gdscript
# Use push_warning() for expected issues
if target == null:
    push_warning("Weapon could not find target")

# Use push_error() for unexpected issues
if data == null:
    push_error("WeaponData is null - weapon not configured!")

# Use print() for debug traces (remove before release)
print("Player fired weapon: ", weapon_name)
```

---

## COMMON PATTERNS

### Signal-Based Communication

**Pattern:** Use signals for decoupled event-driven communication

**Example:**
```gdscript
# Player emits signal
signal health_changed(current: int, max: int)

func take_damage(amount: int):
    current_health -= amount
    health_changed.emit(current_health, max_health)

# HUD listens to signal
func _ready():
    player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current: int, max: int):
    health_bar.value = current / float(max)
```

### Resource-Based Configuration

**Pattern:** Use Godot Resources for data that designers tune

**Example:**
```gdscript
# Create resource class
class_name EnemyData
extends Resource

@export var enemy_name: String
@export var max_health: int
@export var move_speed: float

# Use in enemy script
@export var data: EnemyData

func _ready():
    current_health = data.max_health
    speed = data.move_speed
```

### Autoload Managers

**Pattern:** Use autoloads for global state and cross-scene managers

**When to use:**
- System persists across scenes
- Multiple scenes need access
- Exactly one instance needed

**Example:** GameState, WeaponManager, VFXManager

---

## CHANGELOG

### 2025-12-21 - Initial Systems Bible
**Added:** Core documentation for Player, Weapon, Wave, XP systems
**Purpose:** Knowledge base for onboarding and reference

### 2025-12-20 - Refactored to Data-Driven Design
**Changed:** Weapons now use WeaponData resources
**Impact:** All weapon scripts simplified, balance externalized

---

**END OF SYSTEMS BIBLE**

This document explains HOW the game works technically. For design philosophy, see Design Bible. For feature specs, see GDD.
```

---

## Workflow

### Creating New Systems Bible

1. **Scan codebase:**
   - Use Glob to find all .gd files
   - Identify core systems (player, enemies, weapons, managers)

2. **Ask user about architecture:**
   - Which systems are most important?
   - What are the autoloads/singletons?
   - Are there common patterns to document?

3. **Generate initial bible:**
   - Project architecture and directory structure
   - Core systems documentation (top 3-5 systems)
   - Managers & autoloads section
   - Common patterns

4. **Save to `docs/systems-bible.md`**

---

### Updating Existing Bible

1. **Read current systems bible**

2. **Ask what changed:**
   - New system implemented?
   - System refactored?
   - New pattern introduced?
   - Performance optimization applied?

3. **Update appropriate section:**
   - Add new system documentation
   - Update architecture diagrams
   - Add to changelog

4. **Optionally read code:**
   - Use Read tool to examine implementation
   - Extract key methods, properties, signals

---

## Example Interactions

**User:** "Document the weapon system architecture"

**Skill:**
```
I'll document the weapon system in the Systems Bible.

Let me read the weapon scripts to understand the architecture:
- Reading weapon_base.gd
- Reading weapon_manager.gd
- Reading example weapon implementations

I'll add a detailed section covering:
- Weapon architecture (base class + manager)
- Target priority and firing condition enums
- Targeting algorithm
- Data flow from loadout screen to firing
- Performance considerations

Should I also document individual weapon types (MachineGun, Railgun, etc.) or just the base system?
```

---

**User:** "Create systems bible for my game"

**Skill:**
```
I'll create a Systems Bible documenting your technical architecture.

I'm scanning the codebase... Found:
- 3 autoload singletons (GameState, WeaponManager, PassiveManager)
- 5 core systems (Player, Enemy, Weapon, Wave, XP)
- Data-driven design with Resources

I'll document:
1. Project architecture and directory structure
2. Core systems (detailed docs for each)
3. Autoload managers
4. Data systems (Resource-based configuration)
5. System interactions and dependencies
6. Performance considerations

This will save to docs/systems-bible.md
```

---

## Integration with Other Skills

### With `data-driven-refactor`
- After refactoring, update Systems Bible with new data architecture
- Document resource-based patterns

### With `gdscript-quality-checker`
- Code quality improvements should update Systems Bible
- Document new patterns introduced

### With `feature-spec-generator`
- Feature specs reference Systems Bible for implementation details
- Systems Bible documents HOW feature was implemented

### With `prototype-gdd-generator`
- GDD describes WHAT systems do
- Systems Bible describes HOW they work

---

## Quality Checklist

Before finalizing systems bible:
- ✅ All core systems documented with architecture diagrams
- ✅ Key methods include purpose, parameters, return values
- ✅ Data flows are clear (arrows showing dependencies)
- ✅ Performance considerations noted for hot paths
- ✅ Code examples are accurate (match actual implementation)
- ✅ Directory structure reflects actual project
- ✅ Autoloads/singletons all documented

---

## Example Invocations

User: "Create systems bible"
User: "Document the [system] architecture"
User: "Update systems bible - we refactored the weapon system"
User: "How does the targeting system work?"
User: "Add the new enemy AI system to systems bible"

---

## Workflow Summary

1. Check if `docs/systems-bible.md` exists
2. If new: Scan codebase for core systems, ask about architecture
3. If exists: Read current bible
4. Ask what needs documenting/updating
5. Optionally read code files to extract details
6. Update appropriate section(s) with:
   - Architecture diagrams
   - Key methods and properties
   - Data flows
   - Dependencies
   - Performance notes
7. Add changelog entry
8. Save updated systems bible
9. Confirm changes to user

---

This skill ensures technical knowledge is captured, enabling effective onboarding, debugging, and system evolution.
