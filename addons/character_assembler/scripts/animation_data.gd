@tool
extends Resource
class_name AnimationData
## Represents a specific animation instance created from a template.
## Stores the template reference, pose assignments, settings, and generated frames.

## The name of this animation (e.g., "walk", "attack_1")
@export var animation_name: String = ""

## The template this animation is based on
@export var template_name: String = ""

## Number of frames in this animation
@export var frame_count: int = 8

## Frames per second
@export var fps: int = 12

## Whether this animation loops
@export var loop: bool = true

## Pose assignments - maps template slot name -> user pose name
@export var pose_assignments: Dictionary = {}

## Generated frame data - Array of frame dictionaries
## Each frame contains rotation data for all body parts
@export var generated_frames: Array[Dictionary] = []

## Whether frames have been generated
@export var is_generated: bool = false


func _init(p_name: String = "", p_template: String = "") -> void:
	animation_name = p_name
	template_name = p_template


## Set a pose assignment for a template slot.
func set_pose_assignment(slot_name: String, pose_name: String) -> void:
	pose_assignments[slot_name] = pose_name


## Get the pose assignment for a template slot.
func get_pose_assignment(slot_name: String) -> String:
	return pose_assignments.get(slot_name, "")


## Clear all pose assignments.
func clear_assignments() -> void:
	pose_assignments.clear()


## Check if all required poses are assigned.
func has_all_assignments(template: AnimationTemplate) -> bool:
	if template == null:
		return false
	return template.validate_assignments(pose_assignments)


## Get animation duration in seconds.
func get_duration() -> float:
	if fps <= 0:
		return 0.0
	return float(frame_count) / float(fps)


## Get a specific generated frame.
func get_frame(frame_index: int) -> Dictionary:
	if frame_index < 0 or frame_index >= generated_frames.size():
		return {}
	return generated_frames[frame_index]


## Set the generated frames.
func set_generated_frames(frames: Array[Dictionary]) -> void:
	generated_frames = frames
	is_generated = not frames.is_empty()


## Clear generated frames.
func clear_generated_frames() -> void:
	generated_frames.clear()
	is_generated = false


## Convert to dictionary for serialization.
func to_dict() -> Dictionary:
	var frames_arr = []
	for frame in generated_frames:
		frames_arr.append(frame.duplicate(true))

	return {
		"animation_name": animation_name,
		"template_name": template_name,
		"frame_count": frame_count,
		"fps": fps,
		"loop": loop,
		"pose_assignments": pose_assignments.duplicate(),
		"generated_frames": frames_arr,
		"is_generated": is_generated
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> AnimationData:
	var anim = AnimationData.new()
	anim.animation_name = data.get("animation_name", "")
	anim.template_name = data.get("template_name", "")
	anim.frame_count = data.get("frame_count", 8)
	anim.fps = data.get("fps", 12)
	anim.loop = data.get("loop", true)
	anim.pose_assignments = data.get("pose_assignments", {}).duplicate()
	anim.is_generated = data.get("is_generated", false)

	var frames = data.get("generated_frames", [])
	anim.generated_frames.clear()
	for frame in frames:
		anim.generated_frames.append(frame.duplicate(true) if frame is Dictionary else {})

	return anim


## Get a summary string.
func get_summary() -> String:
	var status = "generated" if is_generated else "not generated"
	var loop_str = "loop" if loop else "no loop"
	return "%s (%d frames, %d FPS, %s, %s)" % [animation_name, frame_count, fps, loop_str, status]
