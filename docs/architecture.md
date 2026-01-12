# BLOOD & GOLD - Architecture Document

**Version:** 0.1.0
**Engine:** Godot 4.5
**Last Updated:** 2026-01-11
**Phase:** 1 - Combat Foundation (In Progress)

---

## TABLE OF CONTENTS

1. [High-Level Architecture](#high-level-architecture)
2. [Main Scene Tree](#main-scene-tree)
3. [System Scene Trees](#system-scene-trees)
4. [Data Architecture](#data-architecture)
5. [Resource Definitions](#resource-definitions)
6. [Signal Map](#signal-map)
7. [Group Registry](#group-registry)
8. [Autoload Registry](#autoload-registry)
9. [Collision Layers](#collision-layers)
10. [File Structure](#file-structure)

---

## HIGH-LEVEL ARCHITECTURE

### Game Structure Overview

```mermaid
graph TB
    subgraph BLOOD_AND_GOLD["BLOOD & GOLD - Party-Based Tactical CRPG"]
        subgraph Autoloads["Autoloads (Managers)"]
            GM[GameManager]
            TM[TurnManager]
            CM[CombatManager]
            LM[LoyaltyManager]
        end

        subgraph Scenes["Game Scenes"]
            Combat[Combat Scene]
            Camp[Camp Scene]
            Management[Management Scene]
        end

        subgraph Combat_Sub["Combat Components"]
            CG[CombatGrid]
            Units[Units]
            TurnOrder[Turn Order]
            CombatUI[Combat UI]
        end

        subgraph Camp_Sub["Camp Components"]
            Dialogue[Dialogue]
            CampUI[Camp UI]
            Loyalty[Loyalty System]
        end

        subgraph Management_Sub["Management Components"]
            Contracts[Contract Board]
            Fort[Fort Upgrades]
            Merchant[Merchant]
        end
    end

    Combat --> Combat_Sub
    Camp --> Camp_Sub
    Management --> Management_Sub

    Autoloads --> Scenes
```

### Core Game Loop

```mermaid
graph LR
    A[Contract Selection] --> B[Combat Battle]
    B --> C[Camp Scene]
    C --> D[Fort Upgrades]
    D --> A

    style A fill:#4a6741,stroke:#3d5636,color:#fff
    style B fill:#8b0000,stroke:#5c0000,color:#fff
    style C fill:#4a5568,stroke:#2d3748,color:#fff
    style D fill:#744210,stroke:#5c3d0e,color:#fff
```

### Layer Architecture

```mermaid
graph TB
    subgraph Layers["Application Layers"]
        L4["Layer 4: Debug Layer<br/>(Dev tools, profiling)"]
        L3["Layer 3: UI Layer<br/>(HUD, menus, dialogs)"]
        L2["Layer 2: Game Scenes<br/>(Combat, Camp, Management)"]
        L1["Layer 1: Main Scene<br/>(Scene management, transitions)"]
        L0["Layer 0: Autoloads<br/>(Global state, managers)"]
    end

    L4 --> L3 --> L2 --> L1 --> L0

    style L0 fill:#1a365d,stroke:#2c5282,color:#fff
    style L1 fill:#2c5282,stroke:#3182ce,color:#fff
    style L2 fill:#3182ce,stroke:#4299e1,color:#fff
    style L3 fill:#4299e1,stroke:#63b3ed,color:#fff
    style L4 fill:#63b3ed,stroke:#90cdf4,color:#000
```

---

## MAIN SCENE TREE

### Main.tscn (Entry Point)

```mermaid
graph TB
    Main["Main (Node2D)<br/>res://scenes/main/Main.tscn"]
    BG["Background (ColorRect)<br/>z_index: -100<br/>Color: #0d1117<br/>Size: 1920x1080"]
    CG["CombatGrid (Instance)<br/>res://scenes/combat/CombatGrid.tscn"]

    Main --> BG
    Main --> CG

    style Main fill:#2d3748,stroke:#4a5568,color:#fff
    style BG fill:#0d1117,stroke:#1a202c,color:#fff
    style CG fill:#4a6741,stroke:#3d5636,color:#fff
```

### Scene Hierarchy

```mermaid
graph TB
    subgraph scenes["res://scenes/"]
        main["main/<br/>Main.tscn ✓"]
        combat["combat/<br/>CombatGrid.tscn ✓"]
        player["player/<br/>(planned)"]
        enemies["enemies/<br/>(planned)"]
        weapons["weapons/<br/>(planned)"]
        effects["effects/<br/>(planned)"]
        levels["levels/<br/>(planned)"]
        UI["UI/<br/>(planned)"]
    end

    main -.->|"entry point"| combat

    style main fill:#48bb78,stroke:#38a169,color:#fff
    style combat fill:#48bb78,stroke:#38a169,color:#fff
    style player fill:#a0aec0,stroke:#718096,color:#fff
    style enemies fill:#a0aec0,stroke:#718096,color:#fff
    style weapons fill:#a0aec0,stroke:#718096,color:#fff
    style effects fill:#a0aec0,stroke:#718096,color:#fff
    style levels fill:#a0aec0,stroke:#718096,color:#fff
    style UI fill:#a0aec0,stroke:#718096,color:#fff
```

---

## SYSTEM SCENE TREES

### CombatGrid.tscn (Implemented)

```mermaid
graph TB
    CG["CombatGrid (Node2D)<br/>Script: combat_grid.gd<br/>Class: CombatGrid"]
    TML["TileMapLayer<br/>Renders grid tiles<br/>(walkable/obstacle)"]

    CG --> TML

    style CG fill:#4a6741,stroke:#3d5636,color:#fff
    style TML fill:#2d3436,stroke:#1a1a2e,color:#fff
```

**CombatGrid Properties:**

| Property | Type | Value | Purpose |
|----------|------|-------|---------|
| GRID_WIDTH | const int | 12 | Grid columns |
| GRID_HEIGHT | const int | 12 | Grid rows |
| TILE_SIZE | const int | 64 | Pixels per tile |
| TILE_WALKABLE | const int | 0 | Walkable tile type |
| TILE_OBSTACLE | const int | 1 | Obstacle tile type |

**CombatGrid Colors:**

| Color | Hex | Purpose |
|-------|-----|---------|
| COLOR_WALKABLE | #4a6741 | Walkable tile fill |
| COLOR_WALKABLE_BORDER | #3d5636 | Walkable tile border |
| COLOR_OBSTACLE | #2d3436 | Obstacle tile fill |
| COLOR_OBSTACLE_BORDER | #1a1a2e | Obstacle tile border |
| COLOR_BACKGROUND | #0d1117 | Grid background |

**CombatGrid Public API:**

```gdscript
# Tile queries
get_tile_type(coords: Vector2i) -> int
is_walkable(coords: Vector2i) -> bool
is_obstacle(coords: Vector2i) -> bool

# Coordinate conversion
world_to_grid(world_pos: Vector2) -> Vector2i
grid_to_world(grid_coords: Vector2i) -> Vector2

# Grid info
get_grid_size() -> Vector2i
get_tile_size() -> int
get_grid_pixel_size() -> Vector2

# Tile modification
set_tile_walkable(coords: Vector2i) -> void
set_tile_obstacle(coords: Vector2i) -> void
clear_grid() -> void
```

---

### Planned Scene Trees

#### Unit Inheritance Hierarchy

```mermaid
graph TB
    Unit["Unit (CharacterBody2D)<br/>Base class for all units"]
    PM["PartyMember<br/>Player character + companions"]
    Soldier["Soldier<br/>NPC soldiers under command"]
    Enemy["Enemy<br/>AI-controlled opponents"]

    Unit --> PM
    Unit --> Soldier
    Unit --> Enemy

    style Unit fill:#4a5568,stroke:#2d3748,color:#fff
    style PM fill:#3182ce,stroke:#2c5282,color:#fff
    style Soldier fill:#38a169,stroke:#2f855a,color:#fff
    style Enemy fill:#e53e3e,stroke:#c53030,color:#fff
```

#### Unit.tscn (Planned)

```mermaid
graph TB
    Unit["Unit (CharacterBody2D)<br/>Groups: [units]"]
    Sprite["Sprite2D<br/>Unit visual"]
    Collision["CollisionShape2D<br/>CircleShape2D"]
    Selection["SelectionIndicator<br/>Visible: false"]
    Health["HealthBar<br/>ProgressBar"]
    Anim["AnimationPlayer<br/>idle, walk, attack, hurt, death"]

    Unit --> Sprite
    Unit --> Collision
    Unit --> Selection
    Unit --> Health
    Unit --> Anim

    style Unit fill:#4a5568,stroke:#2d3748,color:#fff
```

#### PartyMember.tscn (Planned)

```mermaid
graph TB
    PM["PartyMember (extends Unit)<br/>Groups: [units, party, player_controlled]"]
    Inherited["[Inherited from Unit]"]
    Abilities["AbilityContainer (Node)<br/>Ability nodes"]
    Stats["StatsComponent (Node)<br/>stats_component.gd"]

    PM --> Inherited
    PM --> Abilities
    PM --> Stats

    style PM fill:#3182ce,stroke:#2c5282,color:#fff
```

#### Soldier.tscn (Planned)

```mermaid
graph TB
    S["Soldier (extends Unit)<br/>Groups: [units, soldiers, player_controlled]"]
    Inherited["[Inherited from Unit]"]
    Orders["OrderFollower (Node)<br/>order_follower.gd<br/>current_order: SoldierOrder"]

    S --> Inherited
    S --> Orders

    style S fill:#38a169,stroke:#2f855a,color:#fff
```

#### Enemy.tscn (Planned)

```mermaid
graph TB
    E["Enemy (extends Unit)<br/>Groups: [units, enemies]"]
    Inherited["[Inherited from Unit]"]
    AI["AIController (Node)<br/>enemy_ai.gd<br/>behavior_type: BehaviorType"]

    E --> Inherited
    E --> AI

    style E fill:#e53e3e,stroke:#c53030,color:#fff
```

---

## DATA ARCHITECTURE

### Game Data Overview

```mermaid
graph TB
    subgraph DataLayer["DATA LAYER"]
        subgraph Resources[".tres Resources"]
            CharData[CharacterData]
            WeaponData[WeaponData]
            AbilityData[AbilityData]
            EnemyData[EnemyData]
        end

        subgraph JSON[".json Files"]
            Dialogue[Dialogue Trees]
            Contracts[Contract Definitions]
            Localization[Localization]
        end

        subgraph Scenes[".tscn Scenes"]
            CombatMaps[Combat Maps]
            UnitScenes[Unit Scenes]
            EffectScenes[Effect Scenes]
            UIScenes[UI Scenes]
        end
    end

    style CharData fill:#805ad5,stroke:#6b46c1,color:#fff
    style WeaponData fill:#805ad5,stroke:#6b46c1,color:#fff
    style AbilityData fill:#805ad5,stroke:#6b46c1,color:#fff
    style EnemyData fill:#805ad5,stroke:#6b46c1,color:#fff
    style Dialogue fill:#d69e2e,stroke:#b7791f,color:#fff
    style Contracts fill:#d69e2e,stroke:#b7791f,color:#fff
    style Localization fill:#d69e2e,stroke:#b7791f,color:#fff
    style CombatMaps fill:#3182ce,stroke:#2c5282,color:#fff
    style UnitScenes fill:#3182ce,stroke:#2c5282,color:#fff
    style EffectScenes fill:#3182ce,stroke:#2c5282,color:#fff
    style UIScenes fill:#3182ce,stroke:#2c5282,color:#fff
```

### Data Types Registry

| Data Type | Format | Location | Purpose | Status |
|-----------|--------|----------|---------|--------|
| CharacterData | .tres | `resources/data/characters/` | Party member stats, abilities | Planned |
| WeaponData | .tres | `resources/data/weapons/` | Weapon stats, damage types | Planned |
| ArmorData | .tres | `resources/data/armor/` | Armor stats, movement penalty | Planned |
| AbilityData | .tres | `resources/data/abilities/` | Ability effects, costs | Planned |
| EnemyData | .tres | `resources/data/enemies/` | Enemy stats, behavior | Planned |
| SoldierData | .tres | `resources/data/soldiers/` | Soldier types, stats | Planned |
| ContractData | .json | `resources/data/contracts/` | Contract objectives, rewards | Planned |
| DialogueData | .json | `resources/data/dialogue/` | Dialogue trees, choices | Planned |

---

## RESOURCE DEFINITIONS

### CharacterData.tres Schema (Planned)

```gdscript
class_name CharacterData
extends Resource

# Identity
@export var id: String                    # "player", "thorne", "lyra", "matthias"
@export var display_name: String          # "Thorne Blackwood"
@export var portrait: Texture2D

# Base Stats (D&D-style)
@export var strength: int                 # STR: Melee damage, carry weight
@export var dexterity: int                # DEX: Initiative, ranged, defense
@export var constitution: int             # CON: HP, resistances
@export var intelligence: int             # INT: Ability power
@export var wisdom: int                   # WIS: Detection, willpower
@export var charisma: int                 # CHA: Dialogue, leadership

# Derived Stats
@export var max_hp: int                   # CON-based
@export var movement_speed: int           # Tiles per turn (4-6)
@export var initiative_bonus: int         # DEX modifier

# Combat
@export var abilities: Array[AbilityData] # 4 abilities per character
@export var starting_weapon: WeaponData
@export var starting_armor: ArmorData

# Companion-specific
@export var loyalty_triggers_positive: Array[String]  # ["honor", "protecting_team"]
@export var loyalty_triggers_negative: Array[String]  # ["betrayal", "cruelty"]
```

### WeaponData.tres Schema (Planned)

```gdscript
class_name WeaponData
extends Resource

@export var id: String                    # "iron_sword"
@export var display_name: String          # "Iron Sword"
@export var description: String

# Combat Stats
@export var damage_dice: String           # "1d8"
@export var damage_bonus: int             # +0 to +3
@export var damage_type: DamageType       # SLASHING, PIERCING, BLUDGEONING
@export var range: int                    # 1 for melee, 8-10 for ranged
@export var is_ranged: bool               # true for bows/crossbows

# Special Properties
@export var crit_range: int               # 20 (normal) or 19-20 (improved)
@export var armor_bonus: int              # +2 vs armored for maces
@export var reach: bool                   # Spears can attack 2 tiles away
@export var reload: bool                  # Crossbows skip turn after shot

# Economy
@export var cost: int                     # Gold cost
@export var icon: Texture2D
```

### AbilityData.tres Schema (Planned)

```gdscript
class_name AbilityData
extends Resource

@export var id: String                    # "power_attack"
@export var display_name: String          # "Power Attack"
@export var description: String           # "Deal +50% damage but -2 to hit"

# Targeting
@export var target_type: TargetType       # SELF, ALLY, ENEMY, TILE, AOE
@export var range: int                    # Tiles
@export var aoe_radius: int               # For AOE abilities

# Effects
@export var damage_multiplier: float      # 1.5 for Power Attack
@export var hit_modifier: int             # -2 for Power Attack
@export var status_effect: StatusEffect   # STUN, BLEED, SLOW, etc.
@export var status_duration: int          # Turns

# Cooldown
@export var cooldown_turns: int           # 0 = no cooldown
@export var uses_per_battle: int          # -1 = unlimited

# Visuals
@export var icon: Texture2D
@export var animation: String             # Animation name to play
```

### SoldierOrder Enum (Planned)

```gdscript
enum SoldierOrder {
    ADVANCE,      # Move toward nearest enemy, engage in melee
    HOLD_LINE,    # Stay in position, attack enemies in range
    FOCUS_FIRE,   # All soldiers target designated enemy
    RETREAT,      # Fall back toward map edge
    PROTECT       # Guard a specific party member
}
```

---

## SIGNAL MAP

### Signal Flow Overview

```mermaid
graph LR
    subgraph Managers["Autoload Managers"]
        GM[GameManager]
        TM[TurnManager]
        CM[CombatManager]
        LM[LoyaltyManager]
    end

    subgraph Entities["Game Entities"]
        Units[Units]
        Party[Party Members]
        Soldiers[Soldiers]
        Enemies[Enemies]
    end

    subgraph UI["UI Layer"]
        HUD[Combat HUD]
        Menus[Menus]
    end

    GM -->|"game_paused<br/>game_resumed"| TM
    GM -->|"scene_changed"| UI
    TM -->|"turn_started<br/>turn_ended"| Units
    CM -->|"unit_attacked<br/>unit_died"| Entities
    CM -->|"damage_dealt"| HUD
    LM -->|"loyalty_changed"| Menus
    Units -->|"health_changed<br/>died"| CM
    Party -->|"ability_used"| CM
    Soldiers -->|"order_completed"| CM
    Enemies -->|"target_acquired"| CM
```

### CombatGrid Signals (Implemented)

```mermaid
graph LR
    CG[CombatGrid]
    TC["tile_clicked(coords: Vector2i)"]
    TH["tile_hovered(coords: Vector2i)"]

    CG -->|emits| TC
    CG -->|emits| TH

    style CG fill:#4a6741,stroke:#3d5636,color:#fff
    style TC fill:#3182ce,stroke:#2c5282,color:#fff
    style TH fill:#3182ce,stroke:#2c5282,color:#fff
```

### Planned Global Signals (via Autoloads)

```mermaid
graph TB
    subgraph GameManager_Signals["GameManager Signals"]
        GS1[game_started]
        GS2[game_paused]
        GS3[game_resumed]
        GS4["scene_changed(scene_name)"]
        GS5["game_over(victory)"]
    end

    subgraph TurnManager_Signals["TurnManager Signals"]
        TS1["turn_started(unit)"]
        TS2["turn_ended(unit)"]
        TS3["round_started(round_number)"]
        TS4["round_ended(round_number)"]
        TS5["combat_ended(victory)"]
    end

    subgraph CombatManager_Signals["CombatManager Signals"]
        CS1["unit_selected(unit)"]
        CS2[unit_deselected]
        CS3["unit_moved(unit, from, to)"]
        CS4["unit_attacked(attacker, target, damage)"]
        CS5["unit_died(unit)"]
        CS6["ability_used(unit, ability, target)"]
        CS7["soldier_order_changed(order)"]
    end

    subgraph LoyaltyManager_Signals["LoyaltyManager Signals"]
        LS1["loyalty_changed(companion, old, new)"]
        LS2["loyalty_threshold_crossed(companion, threshold)"]
        LS3["companion_left(companion)"]
    end
```

### Planned Entity Signals

```mermaid
graph TB
    subgraph Unit_Signals["Unit Signals"]
        US1["health_changed(current, max)"]
        US2["status_applied(effect)"]
        US3["status_removed(effect)"]
        US4[died]
        US5[selected]
    end

    subgraph PartyMember_Signals["PartyMember Signals"]
        PS1["ability_ready(ability)"]
        PS2["ability_used(ability)"]
        PS3["level_up(new_level)"]
    end

    subgraph Soldier_Signals["Soldier Signals"]
        SS1["order_received(order)"]
        SS2[order_completed]
        SS3[morale_broken]
    end

    subgraph Enemy_Signals["Enemy Signals"]
        ES1[alerted]
        ES2["target_acquired(target)"]
        ES3[fleeing]
    end
```

---

## GROUP REGISTRY

### Group Hierarchy

```mermaid
graph TB
    subgraph AllUnits["units (all units)"]
        subgraph PlayerControlled["player_controlled"]
            Party["party<br/>(PC + companions)"]
            Soldiers["soldiers<br/>(NPC soldiers)"]
        end
        Enemies["enemies<br/>(AI opponents)"]
    end

    style AllUnits fill:#4a5568,stroke:#2d3748,color:#fff
    style PlayerControlled fill:#3182ce,stroke:#2c5282,color:#fff
    style Party fill:#805ad5,stroke:#6b46c1,color:#fff
    style Soldiers fill:#38a169,stroke:#2f855a,color:#fff
    style Enemies fill:#e53e3e,stroke:#c53030,color:#fff
```

### Planned Groups

| Group Name | Used By | Purpose |
|------------|---------|---------|
| `units` | All units (party, soldiers, enemies) | Global unit queries |
| `party` | Player character + companions | Party-specific logic |
| `soldiers` | NPC soldiers under player command | Soldier order system |
| `enemies` | All enemy units | Enemy targeting |
| `player_controlled` | Party + soldiers | Player's forces |
| `selectable` | Units that can be selected | Selection system |
| `targetable` | Valid attack targets | Targeting system |
| `obstacles` | Grid obstacles, destructibles | Pathfinding |

### Group Usage Patterns (Planned)

```gdscript
# Get all player forces
var player_units = get_tree().get_nodes_in_group("player_controlled")

# Get all enemies for targeting
var enemies = get_tree().get_nodes_in_group("enemies")

# Issue order to all soldiers
for soldier in get_tree().get_nodes_in_group("soldiers"):
    soldier.receive_order(SoldierOrder.ADVANCE)

# Check if combat is over
var enemies_left = get_tree().get_nodes_in_group("enemies").size()
var allies_left = get_tree().get_nodes_in_group("player_controlled").size()
```

---

## AUTOLOAD REGISTRY

### Autoload Dependency Graph

```mermaid
graph TB
    GM[GameManager<br/>Global state, scene transitions]
    TM[TurnManager<br/>Turn order, initiative]
    CM[CombatManager<br/>Combat logic, damage]
    LM[LoyaltyManager<br/>Companion loyalty]
    DM[DialogueManager<br/>Dialogue trees]
    SM[SaveManager<br/>Save/load]

    TM -->|depends on| GM
    CM -->|depends on| GM
    CM -->|depends on| TM
    LM -->|depends on| GM
    DM -->|depends on| GM
    DM -->|depends on| LM
    SM -->|depends on| GM
    SM -->|depends on| LM

    style GM fill:#1a365d,stroke:#2c5282,color:#fff
    style TM fill:#2c5282,stroke:#3182ce,color:#fff
    style CM fill:#3182ce,stroke:#4299e1,color:#fff
    style LM fill:#805ad5,stroke:#6b46c1,color:#fff
    style DM fill:#d69e2e,stroke:#b7791f,color:#fff
    style SM fill:#38a169,stroke:#2f855a,color:#fff
```

### Planned Autoloads

| Name | Path | Purpose | Status |
|------|------|---------|--------|
| GameManager | `scripts/autoload/game_manager.gd` | Global state, scene transitions | Planned |
| TurnManager | `scripts/autoload/turn_manager.gd` | Turn order, initiative | Planned |
| CombatManager | `scripts/autoload/combat_manager.gd` | Combat logic, damage calculation | Planned |
| LoyaltyManager | `scripts/autoload/loyalty_manager.gd` | Companion loyalty tracking | Planned |
| DialogueManager | `scripts/autoload/dialogue_manager.gd` | Dialogue tree processing | Planned |
| SaveManager | `scripts/autoload/save_manager.gd` | Save/load (post-prototype) | Planned |

---

## COLLISION LAYERS

### Collision Layer Diagram

```mermaid
graph TB
    subgraph Layers["Collision Layers"]
        L1["Layer 1: grid_tiles<br/>Walkable/obstacle detection"]
        L2["Layer 2: player_units<br/>Party members and soldiers"]
        L3["Layer 3: enemy_units<br/>Enemy units"]
        L4["Layer 4: projectiles<br/>Arrows, magic"]
        L5["Layer 5: interactables<br/>Chests, levers"]
        L6["Layer 6: triggers<br/>Area triggers"]
    end

    style L1 fill:#4a6741,stroke:#3d5636,color:#fff
    style L2 fill:#3182ce,stroke:#2c5282,color:#fff
    style L3 fill:#e53e3e,stroke:#c53030,color:#fff
    style L4 fill:#d69e2e,stroke:#b7791f,color:#fff
    style L5 fill:#805ad5,stroke:#6b46c1,color:#fff
    style L6 fill:#38a169,stroke:#2f855a,color:#fff
```

### Planned Layer Definitions

| Layer | Bit | Name | Purpose |
|-------|-----|------|---------|
| 1 | 1 | grid_tiles | Grid walkable/obstacle detection |
| 2 | 2 | player_units | Party members and soldiers |
| 3 | 4 | enemy_units | Enemy units |
| 4 | 8 | projectiles | Arrows, magic projectiles |
| 5 | 16 | interactables | Chests, levers, etc. |
| 6 | 32 | triggers | Area triggers (ambush, cutscene) |

### Collision Matrix

```mermaid
graph LR
    subgraph Interactions["Collision Interactions"]
        PU[Player Units] <-->|collides| EU[Enemy Units]
        PU <-->|collides| GT[Grid Tiles]
        EU <-->|collides| GT
        PR[Projectiles] -->|hits| PU
        PR -->|hits| EU
        PU -->|triggers| TR[Triggers]
        EU -->|triggers| TR
        PU -->|interacts| IN[Interactables]
    end
```

---

## FILE STRUCTURE

### Directory Tree

```mermaid
graph TB
    Root["blood-&-gold/"]

    subgraph Core["Core Directories"]
        Scenes["scenes/"]
        Scripts["scripts/"]
        Resources["resources/"]
        Assets["assets/"]
    end

    subgraph Support["Support Directories"]
        Docs["docs/"]
        Tests["tests/"]
        Tools["tools/"]
        Exports["exports/"]
    end

    subgraph Config["Config"]
        Claude[".claude/"]
        Addons["addons/"]
        ProjectGodot["project.godot"]
    end

    Root --> Core
    Root --> Support
    Root --> Config
```

### Scenes Directory

```mermaid
graph TB
    Scenes["scenes/"]
    Main["main/<br/>Main.tscn ✓"]
    Combat["combat/<br/>CombatGrid.tscn ✓"]
    Player["player/"]
    Enemies["enemies/"]
    Weapons["weapons/"]
    Effects["effects/"]
    Levels["levels/"]
    UI["UI/"]

    Scenes --> Main
    Scenes --> Combat
    Scenes --> Player
    Scenes --> Enemies
    Scenes --> Weapons
    Scenes --> Effects
    Scenes --> Levels
    Scenes --> UI

    style Main fill:#48bb78,stroke:#38a169,color:#fff
    style Combat fill:#48bb78,stroke:#38a169,color:#fff
```

### Scripts Directory

```mermaid
graph TB
    Scripts["scripts/"]
    Autoload["autoload/"]
    CombatScripts["combat/<br/>combat_grid.gd ✓"]
    EnemyScripts["enemies/"]
    PlayerScripts["player/"]
    ResourceScripts["resources/"]
    Systems["systems/"]
    Utils["utils/"]
    WeaponScripts["weapons/"]

    Scripts --> Autoload
    Scripts --> CombatScripts
    Scripts --> EnemyScripts
    Scripts --> PlayerScripts
    Scripts --> ResourceScripts
    Scripts --> Systems
    Scripts --> Utils
    Scripts --> WeaponScripts

    style CombatScripts fill:#48bb78,stroke:#38a169,color:#fff
```

### Full Directory Structure

```
blood-&-gold/
├── .claude/                    # Claude Code skills and settings
├── addons/                     # Godot plugins
├── assets/
│   ├── animations/
│   ├── audio/
│   ├── fonts/
│   ├── shaders/
│   ├── sprites/tiles/
│   └── textures/
├── docs/
│   ├── features/
│   ├── implementation-reports/
│   ├── architecture.md         # This file
│   └── *.md
├── exports/{linux,mac,web,windows}/
├── resources/
│   ├── data/
│   ├── materials/
│   ├── themes/
│   └── tilesets/
├── scenes/
│   ├── combat/CombatGrid.tscn  ✓
│   ├── main/Main.tscn          ✓
│   └── {effects,enemies,levels,player,UI,weapons}/
├── scripts/
│   ├── combat/combat_grid.gd   ✓
│   └── {autoload,enemies,player,resources,systems,utils,weapons}/
├── tests/{integration,unit}/
├── tools/editor_scripts/
├── CLAUDE.md
└── project.godot
```

---

## IMPLEMENTATION STATUS

### Phase 1: Combat Foundation (Current)

```mermaid
gantt
    title Phase 1 Progress
    dateFormat X
    axisFormat %s

    section Completed
    Grid system (12x12)           :done, 0, 1
    Tile types                    :done, 0, 1
    Grid centering                :done, 0, 1
    Coordinate conversion         :done, 0, 1

    section Pending
    Unit placement                :active, 0, 1
    Unit selection                :0, 1
    Movement system               :0, 1
    Basic attack                  :0, 1
    Turn order                    :0, 1
    HP tracking                   :0, 1
    Victory/defeat                :0, 1
```

| Feature | Status | File(s) |
|---------|--------|---------|
| Grid system (12x12) | ✓ Complete | `combat_grid.gd`, `CombatGrid.tscn` |
| Tile types (walkable/obstacle) | ✓ Complete | `combat_grid.gd` |
| Grid centering | ✓ Complete | `combat_grid.gd` |
| Coordinate conversion | ✓ Complete | `combat_grid.gd` |
| Unit placement | Pending | - |
| Unit selection | Pending | - |
| Movement system | Pending | - |
| Basic attack | Pending | - |
| Turn order | Pending | - |
| HP tracking | Pending | - |
| Victory/defeat | Pending | - |

### Phase Overview

```mermaid
graph LR
    P1["Phase 1<br/>Combat Foundation<br/>🔄 In Progress"]
    P2["Phase 2<br/>Full Party Combat<br/>⏳ Pending"]
    P3["Phase 3<br/>Meta Loop<br/>⏳ Pending"]
    P4["Phase 4<br/>Polish & Playtest<br/>⏳ Pending"]

    P1 --> P2 --> P3 --> P4

    style P1 fill:#d69e2e,stroke:#b7791f,color:#fff
    style P2 fill:#a0aec0,stroke:#718096,color:#fff
    style P3 fill:#a0aec0,stroke:#718096,color:#fff
    style P4 fill:#a0aec0,stroke:#718096,color:#fff
```

---

## CHANGELOG

### 2026-01-11 - Initial Architecture Document
**Created:** Complete architecture documentation with Mermaid diagrams
**Documented:**
- Current implementation (Main.tscn, CombatGrid.tscn, combat_grid.gd)
- Planned scene structures
- Data architecture
- Signal map
- File structure

---

**END OF ARCHITECTURE DOCUMENT**

This document shows WHAT exists and HOW it's organized.
- For implementation details, see the Systems Bible (when created)
- For design rationale, see `docs/blood-and-gold-prototype-gdd.md`
- For feature specs, see `docs/features/`
