# Data Format Examples for Godot

This reference shows concrete examples of different data storage formats in Godot 4.x.

## Example 1: Godot Resource (.tres)

### Step 1: Create Resource Script

```gdscript
# scripts/resources/weapon_data.gd
class_name WeaponData
extends Resource

@export_group("Identity")
@export var weapon_name: String = "Unknown Weapon"
@export_enum("Machine Gun", "Railgun", "Laser", "Missiles", "Flamethrower") var weapon_type: String

@export_group("Combat Stats")
@export var damage: int = 10
@export var fire_rate: float = 1.0
@export_range(0, 1000) var range: float = 300.0
@export var projectile_speed: float = 500.0

@export_group("Targeting")
@export_enum("Closest", "Weakest", "Strongest", "Group", "Elite") var default_target_priority: String = "Closest"
@export_enum("Always", "Optimal Range", "Save for Elite", "High Health") var default_fire_condition: String = "Always"

@export_group("References")
@export var projectile_scene: PackedScene
@export var muzzle_flash_scene: PackedScene
@export var fire_sound: AudioStream
```

### Step 2: Create Resource Instance in Godot Editor

1. Right-click in FileSystem → New Resource
2. Search for "WeaponData"
3. Save as `data/weapons/machine_gun.tres`
4. Set properties in Inspector

### Step 3: Use in Script

```gdscript
# scripts/weapons/weapon_base.gd
extends Node2D

@export var weapon_data: WeaponData

func _ready():
    print("Loaded: ", weapon_data.weapon_name)
    print("Damage: ", weapon_data.damage)

func fire():
    var projectile = weapon_data.projectile_scene.instantiate()
    projectile.damage = weapon_data.damage
    projectile.speed = weapon_data.projectile_speed
    get_tree().root.add_child(projectile)
```

### Resulting .tres file (auto-generated):

```
[gd_resource type="Resource" script_class="WeaponData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/resources/weapon_data.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/projectiles/bullet.tscn" id="2"]

[resource]
script = ExtResource("1")
weapon_name = "Machine Gun"
weapon_type = "Machine Gun"
damage = 5
fire_rate = 5.0
range = 300.0
projectile_speed = 500.0
default_target_priority = "Closest"
default_fire_condition = "Always"
projectile_scene = ExtResource("2")
```

---

## Example 2: JSON Data

### weapons.json

```json
{
  "machine_gun": {
    "name": "Machine Gun",
    "damage": 5,
    "fire_rate": 5.0,
    "range": 300,
    "projectile_speed": 500,
    "targeting": {
      "priority": "closest",
      "condition": "always"
    }
  },
  "railgun": {
    "name": "Railgun",
    "damage": 100,
    "fire_rate": 0.5,
    "range": 600,
    "projectile_speed": 2000,
    "targeting": {
      "priority": "strongest",
      "condition": "always"
    }
  },
  "laser": {
    "name": "Laser Beam",
    "damage": 3,
    "tick_rate": 10,
    "range": 400,
    "pierce_count": 3,
    "targeting": {
      "priority": "closest",
      "condition": "always"
    }
  }
}
```

### Loading JSON in GDScript

```gdscript
# autoload/game_data.gd
extends Node

var weapons: Dictionary = {}

func _ready():
    load_weapons()

func load_weapons():
    var file = FileAccess.open("res://data/weapons.json", FileAccess.READ)
    if not file:
        push_error("Could not load weapons.json")
        return

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var error = json.parse(json_string)

    if error == OK:
        weapons = json.data
        print("Loaded %d weapons" % weapons.size())
    else:
        push_error("JSON Parse Error: ", json.get_error_message())

func get_weapon_stat(weapon_id: String, stat: String):
    if weapon_id in weapons:
        return weapons[weapon_id].get(stat, 0)
    return 0

# Usage
func example():
    var mg_damage = GameData.get_weapon_stat("machine_gun", "damage")
    print("Machine gun damage: ", mg_damage)
```

---

## Example 3: ConfigFile (.cfg)

### game_balance.cfg

```ini
[player]
max_health = 100
movement_speed = 200.0
starting_level = 1

[weapons.machine_gun]
damage = 5
fire_rate = 5.0
range = 300

[weapons.railgun]
damage = 100
fire_rate = 0.5
range = 600

[enemies.scout]
health = 20
speed = 150
damage = 10
xp_value = 5

[waves]
initial_spawn_rate = 2.0
spawn_rate_increase_per_minute = 0.1
elite_spawn_interval = 120.0
```

### Loading ConfigFile

```gdscript
# autoload/balance_config.gd
extends Node

var config = ConfigFile.new()

func _ready():
    var error = config.load("res://data/game_balance.cfg")
    if error != OK:
        push_error("Could not load game_balance.cfg")
        return

    print("Config loaded successfully")

func get_player_stat(stat: String):
    return config.get_value("player", stat, 0)

func get_weapon_stat(weapon_type: String, stat: String):
    var section = "weapons." + weapon_type
    return config.get_value(section, stat, 0)

func get_enemy_stat(enemy_type: String, stat: String):
    var section = "enemies." + enemy_type
    return config.get_value(section, stat, 0)

# Usage
func example():
    var player_health = BalanceConfig.get_player_stat("max_health")
    var scout_hp = BalanceConfig.get_enemy_stat("scout", "health")
    var mg_damage = BalanceConfig.get_weapon_stat("machine_gun", "damage")
```

---

## Example 4: GDScript Constants File

### game_constants.gd

```gdscript
# autoload/game_constants.gd
class_name GameConstants
extends Node

# Collision Layers
const LAYER_PLAYER = 1
const LAYER_ENEMY = 2
const LAYER_PROJECTILE = 4
const LAYER_PICKUP = 8

# Groups
const GROUP_ENEMIES = "enemies"
const GROUP_PLAYER = "player"
const GROUP_PROJECTILES = "projectiles"

# Weapon Types
enum WeaponType {
    MACHINE_GUN,
    RAILGUN,
    LASER,
    MISSILES,
    FLAMETHROWER
}

# Target Priority
enum TargetPriority {
    CLOSEST,
    WEAKEST,
    STRONGEST,
    GROUP,
    ELITE_ONLY
}

# Game Settings (rarely change)
const MAX_ENEMIES_ON_SCREEN = 100
const PROJECTILE_POOL_SIZE = 200
const DAMAGE_NUMBER_POOL_SIZE = 50
const SCREEN_BOUNDS_MARGIN = 100

# Balance Constants (extracted, but rarely change mid-development)
const PLAYER_BASE_HEALTH = 100
const PLAYER_BASE_SPEED = 200.0
const XP_PER_LEVEL_BASE = 100
const XP_SCALING_FACTOR = 1.5

# Weapon Base Stats (can be overridden by data files)
const WEAPON_DEFAULTS = {
    WeaponType.MACHINE_GUN: {
        "damage": 5,
        "fire_rate": 5.0,
        "range": 300
    },
    WeaponType.RAILGUN: {
        "damage": 100,
        "fire_rate": 0.5,
        "range": 600
    }
}

# Helper functions
static func get_xp_for_level(level: int) -> int:
    return int(XP_PER_LEVEL_BASE * pow(XP_SCALING_FACTOR, level - 1))
```

### Usage

```gdscript
# Any script
func _ready():
    add_to_group(GameConstants.GROUP_ENEMIES)
    collision_layer = GameConstants.LAYER_ENEMY

    var xp_needed = GameConstants.get_xp_for_level(5)
    print("XP for level 5: ", xp_needed)
```

---

## Example 5: Hybrid Approach (Recommended for Mech Survivors)

### Resource for Entity Definitions

```gdscript
# scripts/resources/enemy_data.gd
class_name EnemyData
extends Resource

@export var enemy_name: String
@export var max_health: int
@export var movement_speed: float
@export var attack_damage: int
@export var xp_value: int
@export var score_value: int
@export_enum("Melee", "Ranged", "Flying") var behavior_type: String
@export var enemy_scene: PackedScene
```

### JSON for Progression/Wave Data

```json
{
  "wave_timeline": [
    {
      "start_time": 0,
      "end_time": 300,
      "spawn_rate": 2.0,
      "enemy_types": ["scout"]
    },
    {
      "start_time": 300,
      "end_time": 600,
      "spawn_rate": 3.0,
      "enemy_types": ["scout", "tank", "drone"]
    },
    {
      "start_time": 600,
      "end_time": 900,
      "spawn_rate": 5.0,
      "enemy_types": ["scout", "tank", "drone", "artillery"],
      "elite_spawn_chance": 0.1
    }
  ]
}
```

### GDScript Constants for System Values

```gdscript
# autoload/game_constants.gd
const LAYER_PLAYER = 1
const LAYER_ENEMY = 2
const GROUP_ENEMIES = "enemies"
```

### ConfigFile for Tunable Settings

```ini
[debug]
god_mode = false
show_fps = true
spawn_rate_multiplier = 1.0

[vfx]
screen_shake_enabled = true
screen_shake_intensity = 5.0
particle_density = 1.0
```

This hybrid gives you:
- ✅ Type safety for entities (Resources)
- ✅ Easy wave editing (JSON)
- ✅ Fast constant access (GDScript)
- ✅ Runtime-tunable settings (ConfigFile)

---

## Loading Pattern for Resources

```gdscript
# Preload (compile time, fastest)
const MACHINE_GUN_DATA = preload("res://data/weapons/machine_gun.tres")

# Load (runtime, flexible)
var weapon_data = load("res://data/weapons/" + weapon_name + ".tres") as WeaponData

# Load all weapons from directory
func load_all_weapons() -> Array[WeaponData]:
    var weapons: Array[WeaponData] = []
    var dir = DirAccess.open("res://data/weapons/")

    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()

        while file_name != "":
            if file_name.ends_with(".tres"):
                var weapon = load("res://data/weapons/" + file_name) as WeaponData
                if weapon:
                    weapons.append(weapon)
            file_name = dir.get_next()

        dir.list_dir_end()

    return weapons
```

---

## When to Use Each Format

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| **Resource (.tres)** | Entities (weapons, enemies) | Type-safe, editor integration, can reference scenes | Godot-specific, binary format |
| **JSON** | Lists, progression, waves | Human-readable, git-friendly, external tools | No type safety, runtime parsing |
| **ConfigFile (.cfg)** | Settings, preferences | Simple, built-in, good for user config | Limited structure |
| **GDScript** | Constants, enums, helpers | Fast, type-safe, no loading | Requires code edit |
