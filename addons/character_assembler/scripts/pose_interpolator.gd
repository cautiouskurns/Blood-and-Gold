@tool
extends RefCounted
class_name PoseInterpolator
## Handles interpolation between poses to generate animation frames.
## Uses weighted blending to create smooth transitions.


## Generate all animation frames from a template and pose assignments.
## Returns an array of frame dictionaries, each containing body part rotations.
static func generate_animation_frames(
	template: AnimationTemplate,
	pose_assignments: Dictionary,
	available_poses: Dictionary  # pose_name -> Pose
) -> Array[Dictionary]:
	var frames: Array[Dictionary] = []

	if template == null or template.frame_sequence.is_empty():
		return frames

	for frame_def in template.frame_sequence:
		var pose_weights: Dictionary = frame_def.get("pose_weights", {})
		var blended_frame := blend_poses(pose_weights, pose_assignments, available_poses)
		frames.append(blended_frame)

	return frames


## Blend multiple poses together based on weights.
## pose_weights: Dictionary mapping pose slot names to weights (0.0 to 1.0)
## pose_assignments: Dictionary mapping pose slot names to user pose names
## available_poses: Dictionary mapping pose names to Pose objects
static func blend_poses(
	pose_weights: Dictionary,
	pose_assignments: Dictionary,
	available_poses: Dictionary
) -> Dictionary:
	var blended_rotations: Dictionary = {}

	# Normalize weights to ensure they sum to 1.0
	var total_weight := 0.0
	for slot_name in pose_weights:
		total_weight += pose_weights[slot_name]

	if total_weight <= 0.0:
		return blended_rotations

	# Blend each pose according to its weight
	for slot_name in pose_weights:
		var weight: float = pose_weights[slot_name] / total_weight
		var user_pose_name: String = pose_assignments.get(slot_name, "")

		if user_pose_name.is_empty():
			continue

		var pose: Pose = available_poses.get(user_pose_name)
		if pose == null:
			continue

		# Add this pose's rotations weighted
		for body_part in pose.rotations:
			var rotation_value: float = pose.rotations[body_part]
			if body_part not in blended_rotations:
				blended_rotations[body_part] = 0.0
			blended_rotations[body_part] += rotation_value * weight

	return blended_rotations


## Interpolate between two poses at a given factor (0.0 to 1.0).
static func interpolate_poses(pose_a: Pose, pose_b: Pose, factor: float) -> Dictionary:
	var result: Dictionary = {}
	factor = clampf(factor, 0.0, 1.0)

	# Get all body parts from both poses
	var all_parts: Array[String] = []
	if pose_a:
		for part in pose_a.rotations.keys():
			if part not in all_parts:
				all_parts.append(part)
	if pose_b:
		for part in pose_b.rotations.keys():
			if part not in all_parts:
				all_parts.append(part)

	# Interpolate each body part
	for body_part in all_parts:
		var rot_a: float = 0.0
		var rot_b: float = 0.0

		if pose_a:
			rot_a = pose_a.get_rotation(body_part)
		if pose_b:
			rot_b = pose_b.get_rotation(body_part)

		result[body_part] = lerpf(rot_a, rot_b, factor)

	return result


## Create a Pose from blended rotation data.
static func create_pose_from_rotations(rotations: Dictionary, name: String = "blended") -> Pose:
	var pose := Pose.new(name, rotations)
	return pose


## Generate frames with custom interpolation between keyframes.
## keyframes: Array of {frame_index: int, pose: Pose}
## total_frames: Total number of frames to generate
static func generate_interpolated_frames(
	keyframes: Array,
	total_frames: int
) -> Array[Dictionary]:
	var frames: Array[Dictionary] = []

	if keyframes.is_empty() or total_frames <= 0:
		return frames

	# Sort keyframes by frame index
	keyframes.sort_custom(func(a, b): return a.frame_index < b.frame_index)

	# Generate each frame
	for i in range(total_frames):
		# Find surrounding keyframes
		var prev_kf: Dictionary = {}
		var next_kf: Dictionary = {}

		for kf in keyframes:
			if kf.frame_index <= i:
				prev_kf = kf
			if kf.frame_index >= i and next_kf.is_empty():
				next_kf = kf
				break

		# If we only have one keyframe, use it directly
		if prev_kf.is_empty() and not next_kf.is_empty():
			frames.append(_pose_to_rotation_dict(next_kf.pose))
		elif not prev_kf.is_empty() and next_kf.is_empty():
			frames.append(_pose_to_rotation_dict(prev_kf.pose))
		elif not prev_kf.is_empty() and not next_kf.is_empty():
			# Interpolate between keyframes
			if prev_kf.frame_index == next_kf.frame_index:
				frames.append(_pose_to_rotation_dict(prev_kf.pose))
			else:
				var range_size: float = next_kf.frame_index - prev_kf.frame_index
				var factor: float = (i - prev_kf.frame_index) / range_size
				var interpolated := interpolate_poses(prev_kf.pose, next_kf.pose, factor)
				frames.append(interpolated)
		else:
			# No keyframes, add empty frame
			frames.append({})

	return frames


## Convert a Pose to a rotation dictionary.
static func _pose_to_rotation_dict(pose: Pose) -> Dictionary:
	if pose == null:
		return {}
	return pose.rotations.duplicate()


## Apply easing to interpolation factor.
## easing_type: "linear", "ease_in", "ease_out", "ease_in_out"
static func apply_easing(factor: float, easing_type: String) -> float:
	factor = clampf(factor, 0.0, 1.0)

	match easing_type:
		"ease_in":
			return factor * factor
		"ease_out":
			return 1.0 - (1.0 - factor) * (1.0 - factor)
		"ease_in_out":
			if factor < 0.5:
				return 2.0 * factor * factor
			else:
				return 1.0 - pow(-2.0 * factor + 2.0, 2) / 2.0
		_:  # "linear" or default
			return factor


## Generate frames with easing between keyframes.
static func generate_eased_frames(
	keyframes: Array,
	total_frames: int,
	easing_type: String = "ease_in_out"
) -> Array[Dictionary]:
	var frames: Array[Dictionary] = []

	if keyframes.is_empty() or total_frames <= 0:
		return frames

	keyframes.sort_custom(func(a, b): return a.frame_index < b.frame_index)

	for i in range(total_frames):
		var prev_kf: Dictionary = {}
		var next_kf: Dictionary = {}

		for kf in keyframes:
			if kf.frame_index <= i:
				prev_kf = kf
			if kf.frame_index >= i and next_kf.is_empty():
				next_kf = kf
				break

		if prev_kf.is_empty() and not next_kf.is_empty():
			frames.append(_pose_to_rotation_dict(next_kf.pose))
		elif not prev_kf.is_empty() and next_kf.is_empty():
			frames.append(_pose_to_rotation_dict(prev_kf.pose))
		elif not prev_kf.is_empty() and not next_kf.is_empty():
			if prev_kf.frame_index == next_kf.frame_index:
				frames.append(_pose_to_rotation_dict(prev_kf.pose))
			else:
				var range_size: float = next_kf.frame_index - prev_kf.frame_index
				var linear_factor: float = (i - prev_kf.frame_index) / range_size
				var eased_factor := apply_easing(linear_factor, easing_type)
				var interpolated := interpolate_poses(prev_kf.pose, next_kf.pose, eased_factor)
				frames.append(interpolated)
		else:
			frames.append({})

	return frames
