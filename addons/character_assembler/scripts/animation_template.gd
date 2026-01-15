@tool
extends Resource
class_name AnimationTemplate
## Defines a reusable animation template with pose slots and frame sequence.
## Templates specify which poses are needed and how to blend between them.

## The name of the template (e.g., "Walk Cycle", "Attack")
@export var template_name: String = ""

## Description of what this animation does
@export var description: String = ""

## Required pose slots that must be assigned (e.g., ["idle", "walk_left", "walk_right"])
@export var required_poses: Array[String] = []

## Default frame count for this animation
@export var default_frame_count: int = 8

## Default FPS for this animation
@export var default_fps: int = 12

## Whether this animation should loop by default
@export var loop: bool = true

## Frame sequence - each element is a Dictionary with pose_weights
## pose_weights maps pose slot name -> weight (0.0 to 1.0)
@export var frame_sequence: Array = []


func _init(p_name: String = "", p_required: Array[String] = [], p_frames: int = 8, p_fps: int = 12, p_loop: bool = true) -> void:
	template_name = p_name
	required_poses = p_required
	default_frame_count = p_frames
	default_fps = p_fps
	loop = p_loop


## Get the pose weights for a specific frame index.
## Returns empty dictionary if frame is out of range.
func get_frame_weights(frame_index: int) -> Dictionary:
	if frame_index < 0 or frame_index >= frame_sequence.size():
		return {}
	return frame_sequence[frame_index].get("pose_weights", {})


## Get the number of frames in this template.
func get_frame_count() -> int:
	return frame_sequence.size()


## Check if all required poses are assigned in the given assignment dictionary.
func validate_assignments(assignments: Dictionary) -> bool:
	for pose_slot in required_poses:
		if pose_slot not in assignments or assignments[pose_slot] == null:
			return false
	return true


## Get list of missing pose assignments.
func get_missing_assignments(assignments: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for pose_slot in required_poses:
		if pose_slot not in assignments or assignments[pose_slot] == null:
			missing.append(pose_slot)
	return missing


## Convert to dictionary for serialization.
func to_dict() -> Dictionary:
	return {
		"template_name": template_name,
		"description": description,
		"required_poses": required_poses.duplicate(),
		"default_frame_count": default_frame_count,
		"default_fps": default_fps,
		"loop": loop,
		"frame_sequence": frame_sequence.duplicate(true)
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = data.get("template_name", "")
	template.description = data.get("description", "")

	var req_poses = data.get("required_poses", [])
	template.required_poses.clear()
	for p in req_poses:
		template.required_poses.append(str(p))

	template.default_frame_count = data.get("default_frame_count", 8)
	template.default_fps = data.get("default_fps", 12)
	template.loop = data.get("loop", true)

	var seq = data.get("frame_sequence", [])
	template.frame_sequence.clear()
	for frame in seq:
		template.frame_sequence.append(frame.duplicate(true) if frame is Dictionary else {})

	return template


# =============================================================================
# BUILT-IN TEMPLATE FACTORIES
# =============================================================================

## Create the Walk Cycle template (8 frames).
static func create_walk_cycle() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Walk Cycle"
	template.description = "Standard 8-frame walk cycle animation"
	template.required_poses.assign(["idle", "walk_left", "walk_right"])
	template.default_frame_count = 8
	template.default_fps = 12
	template.loop = true
	template.frame_sequence = [
		{"pose_weights": {"idle": 1.0}},
		{"pose_weights": {"idle": 0.5, "walk_left": 0.5}},
		{"pose_weights": {"walk_left": 1.0}},
		{"pose_weights": {"walk_left": 0.5, "idle": 0.5}},
		{"pose_weights": {"idle": 1.0}},
		{"pose_weights": {"idle": 0.5, "walk_right": 0.5}},
		{"pose_weights": {"walk_right": 1.0}},
		{"pose_weights": {"walk_right": 0.5, "idle": 0.5}},
	]
	return template


## Create the Run Cycle template (8 frames, faster).
static func create_run_cycle() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Run Cycle"
	template.description = "Fast 8-frame run cycle animation"
	template.required_poses.assign(["idle", "run_left", "run_right"])
	template.default_frame_count = 8
	template.default_fps = 16
	template.loop = true
	template.frame_sequence = [
		{"pose_weights": {"idle": 0.8, "run_left": 0.2}},
		{"pose_weights": {"run_left": 0.8, "idle": 0.2}},
		{"pose_weights": {"run_left": 1.0}},
		{"pose_weights": {"run_left": 0.6, "run_right": 0.4}},
		{"pose_weights": {"idle": 0.8, "run_right": 0.2}},
		{"pose_weights": {"run_right": 0.8, "idle": 0.2}},
		{"pose_weights": {"run_right": 1.0}},
		{"pose_weights": {"run_right": 0.6, "run_left": 0.4}},
	]
	return template


## Create the Idle Breathing template (4 frames).
static func create_idle_breathing() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Idle Breathing"
	template.description = "Subtle breathing idle animation"
	template.required_poses.assign(["idle", "breathe_in"])
	template.default_frame_count = 4
	template.default_fps = 6
	template.loop = true
	template.frame_sequence = [
		{"pose_weights": {"idle": 1.0}},
		{"pose_weights": {"idle": 0.5, "breathe_in": 0.5}},
		{"pose_weights": {"breathe_in": 1.0}},
		{"pose_weights": {"breathe_in": 0.5, "idle": 0.5}},
	]
	return template


## Create the Attack template (6 frames).
static func create_attack() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Attack"
	template.description = "6-frame melee attack animation"
	template.required_poses.assign(["idle", "attack_windup", "attack_swing"])
	template.default_frame_count = 6
	template.default_fps = 15
	template.loop = false
	template.frame_sequence = [
		{"pose_weights": {"idle": 1.0}},
		{"pose_weights": {"idle": 0.3, "attack_windup": 0.7}},
		{"pose_weights": {"attack_windup": 1.0}},
		{"pose_weights": {"attack_windup": 0.3, "attack_swing": 0.7}},
		{"pose_weights": {"attack_swing": 1.0}},
		{"pose_weights": {"attack_swing": 0.3, "idle": 0.7}},
	]
	return template


## Create the Hurt Recoil template (3 frames).
static func create_hurt_recoil() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Hurt Recoil"
	template.description = "Quick 3-frame hurt reaction"
	template.required_poses.assign(["idle", "hurt"])
	template.default_frame_count = 3
	template.default_fps = 12
	template.loop = false
	template.frame_sequence = [
		{"pose_weights": {"idle": 0.3, "hurt": 0.7}},
		{"pose_weights": {"hurt": 1.0}},
		{"pose_weights": {"hurt": 0.4, "idle": 0.6}},
	]
	return template


## Create the Death template (6 frames, no loop).
static func create_death() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Death"
	template.description = "6-frame death animation (no loop)"
	template.required_poses.assign(["idle", "hurt", "death"])
	template.default_frame_count = 6
	template.default_fps = 10
	template.loop = false
	template.frame_sequence = [
		{"pose_weights": {"idle": 1.0}},
		{"pose_weights": {"idle": 0.3, "hurt": 0.7}},
		{"pose_weights": {"hurt": 1.0}},
		{"pose_weights": {"hurt": 0.5, "death": 0.5}},
		{"pose_weights": {"death": 0.8, "hurt": 0.2}},
		{"pose_weights": {"death": 1.0}},
	]
	return template


## Create the Victory template (4 frames).
static func create_victory() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Victory"
	template.description = "Subtle victory celebration"
	template.required_poses.assign(["idle", "victory"])
	template.default_frame_count = 4
	template.default_fps = 8
	template.loop = true
	template.frame_sequence = [
		{"pose_weights": {"idle": 0.7, "victory": 0.3}},
		{"pose_weights": {"victory": 1.0}},
		{"pose_weights": {"victory": 0.8, "idle": 0.2}},
		{"pose_weights": {"idle": 0.5, "victory": 0.5}},
	]
	return template


## Create the Jump template (6 frames).
static func create_jump() -> AnimationTemplate:
	var template = AnimationTemplate.new()
	template.template_name = "Jump"
	template.description = "6-frame jump animation"
	template.required_poses.assign(["idle", "crouch", "jump_up", "jump_down"])
	template.default_frame_count = 6
	template.default_fps = 12
	template.loop = false
	template.frame_sequence = [
		{"pose_weights": {"idle": 0.5, "crouch": 0.5}},
		{"pose_weights": {"crouch": 1.0}},
		{"pose_weights": {"jump_up": 1.0}},
		{"pose_weights": {"jump_up": 0.5, "jump_down": 0.5}},
		{"pose_weights": {"jump_down": 1.0}},
		{"pose_weights": {"jump_down": 0.3, "idle": 0.7}},
	]
	return template


## Get all built-in templates.
static func get_all_builtin_templates() -> Array[AnimationTemplate]:
	var templates: Array[AnimationTemplate] = []
	templates.append(create_walk_cycle())
	templates.append(create_run_cycle())
	templates.append(create_idle_breathing())
	templates.append(create_attack())
	templates.append(create_hurt_recoil())
	templates.append(create_death())
	templates.append(create_victory())
	templates.append(create_jump())
	return templates
