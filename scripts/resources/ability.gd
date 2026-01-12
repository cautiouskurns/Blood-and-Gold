## Ability - Resource class defining ability properties
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.3-implement-player-abilities.md
class_name Ability
extends Resource

# ===== ENUMS =====
enum AbilityType {
	MELEE_ATTACK,       # Requires adjacent enemy target
	RANGED_ATTACK,      # Requires enemy in range - Smite (Task 2.6)
	SELF_BUFF,          # Targets self - Poison Blade (Task 2.5)
	ALLY_BUFF,          # Targets ally (future)
	ALLY_HEAL,          # Heals ally in range - Heal (Task 2.6)
	SOLDIER_BUFF,       # Targets all soldiers (Rally)
	PARTY_BUFF,         # Buffs all party members - Bless (Task 2.6)
	AOE_ATTACK,         # Hits multiple targets (future)
	ARC_ATTACK,         # Cleave - hits up to N adjacent enemies in arc (Task 2.4)
	ENEMY_TAUNT,        # Taunt - forces enemies in range to attack user (Task 2.4)
	PASSIVE,            # Last Stand - triggered automatically, not user-activated (Task 2.4)
	TELEPORT,           # Shadowstep - instant movement to tile (Task 2.5)
	BACKSTAB,           # Backstab - melee with positional bonus (Task 2.5)
}

enum TargetType {
	NONE,               # No target needed
	ENEMY_ADJACENT,     # Adjacent enemy
	ENEMY_RANGE,        # Enemy within range - Smite (Task 2.6)
	ALLY,               # Friendly unit (future)
	ALLY_RANGE,         # Friendly unit within range - Heal (Task 2.6)
	SELF,               # Self only - Poison Blade (Task 2.5)
	TILE,               # Empty tile within range - Shadowstep (Task 2.5)
}

# ===== EXPORTED PROPERTIES =====
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

@export var ability_type: AbilityType = AbilityType.MELEE_ATTACK
@export var target_type: TargetType = TargetType.ENEMY_ADJACENT

# Usage limits
@export var uses_per_battle: int = -1  # -1 = unlimited
@export var ends_turn: bool = true     # Does using this end the turn?

# Combat modifiers
@export var damage_multiplier: float = 1.0      # 1.5 for Power Attack
@export var attack_modifier: int = 0            # -2 for Power Attack
@export var bonus_damage: int = 0               # Flat bonus damage

# Status effect application
@export var applies_status: String = ""         # "STUNNED", "ATTACK_BUFF", etc.
@export var status_duration: int = 0            # Turns
@export var status_value: int = 0               # +2 for attack buff, etc.

# Targeting
@export var ability_range: int = 1              # 1 = adjacent only
@export var targets_soldiers_only: bool = false # Rally targets soldiers
@export var requires_target: bool = true        # false for Rally

# Arc attack properties (Cleave - Task 2.4)
@export var max_targets: int = 1                # Max targets for arc attacks (Cleave = 2)
@export var arc_angle: int = 90                 # Arc angle in degrees (Cleave = 90)

# Passive ability properties (Last Stand - Task 2.4)
@export var is_passive: bool = false            # True for passive abilities like Last Stand
@export var passive_trigger: String = ""        # "on_lethal_damage" for Last Stand

# Backstab properties (Task 2.5)
@export var requires_behind: bool = false       # True for Backstab - requires being behind target
@export var backstab_multiplier: float = 2.0    # Damage multiplier when behind (Backstab = 2x)

# Teleport properties (Task 2.5)
@export var ignores_obstacles: bool = false     # True for Shadowstep - teleport ignores walls/enemies

# Healing properties (Task 2.6)
@export var heal_dice_count: int = 0            # Number of dice (2 for 2d8)
@export var heal_dice_size: int = 0             # Die size (8 for 2d8)
@export var heal_bonus: int = 0                 # Flat bonus (+4 for 2d8+4)

# Ranged attack properties (Task 2.6)
@export var auto_hit: bool = false              # True for Smite - always hits, no attack roll
@export var fixed_damage_die: int = 0           # If > 0, use this die instead of weapon (8 for 1d8)
@export var exclude_self: bool = false          # True for Heal - can't target self

# ===== METHODS =====
func is_available_for_unit(unit: Unit) -> bool:
	## Check if this ability can be used by the unit
	# Passive abilities are never "used" by the player - they trigger automatically
	if is_passive:
		return false

	# Check uses remaining
	if uses_per_battle > 0:
		var uses = unit.get_ability_uses(id)
		if uses >= uses_per_battle:
			return false

	# Check if there are valid targets (for targeted abilities)
	if requires_target:
		return _has_valid_targets(unit)

	# For abilities that don't require targeting but need adjacency (like Cleave)
	if ability_type == AbilityType.ARC_ATTACK:
		return CombatManager.has_adjacent_enemies(unit)

	# Self-buff abilities are always available (Task 2.5)
	if ability_type == AbilityType.SELF_BUFF:
		return true

	# Teleport abilities need at least one valid tile (Task 2.5)
	if ability_type == AbilityType.TELEPORT:
		return CombatManager.has_valid_teleport_tiles(unit, ability_range)

	# Party buff is always available (Task 2.6)
	if ability_type == AbilityType.PARTY_BUFF:
		return true

	# Ally heal needs allies in range (Task 2.6)
	if ability_type == AbilityType.ALLY_HEAL:
		return CombatManager.has_allies_in_range(unit, ability_range, exclude_self)

	return true

func _has_valid_targets(unit: Unit) -> bool:
	## Check if there are valid targets for this ability
	match target_type:
		TargetType.NONE:
			return true
		TargetType.ENEMY_ADJACENT:
			return CombatManager.has_adjacent_enemies(unit)
		TargetType.ENEMY_RANGE:
			return CombatManager.has_enemies_in_range_check(unit, ability_range)
		TargetType.ALLY_RANGE:
			return CombatManager.has_allies_in_range(unit, ability_range, exclude_self)
		TargetType.SELF:
			return true  # Self is always a valid target
		TargetType.TILE:
			return CombatManager.has_valid_teleport_tiles(unit, ability_range)
		_:
			return true
