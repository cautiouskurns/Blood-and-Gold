@tool
extends Control
class_name AnimationPreview
## Animation preview player that displays animated character frames.
## Handles playback, scrubbing, and frame display.

signal frame_changed(frame_index: int)
signal playback_finished()

# Preview settings
var shapes: Array = []
var body_parts: Dictionary = {}  # part_name -> BodyPart
var animation_frames: Array[Dictionary] = []  # Array of rotation dictionaries
var canvas_size: int = 64

# Playback state
var current_frame: int = 0
var fps: int = 12
var is_playing: bool = false
var is_looping: bool = true
var _playback_timer: float = 0.0

# Visual settings
const BACKGROUND_COLOR := Color(0.12, 0.12, 0.12, 1.0)
const BORDER_COLOR := Color(0.4, 0.4, 0.4, 1.0)


func _ready() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(200, 200)
	# Disable process initially - only enable when playing
	set_process(false)


func _process(delta: float) -> void:
	if not is_playing or animation_frames.is_empty():
		return

	_playback_timer += delta
	var frame_duration := 1.0 / float(fps) if fps > 0 else 0.1

	if _playback_timer >= frame_duration:
		_playback_timer -= frame_duration
		_advance_frame()


func _draw() -> void:
	var preview_rect := _get_preview_rect()

	# Background
	draw_rect(preview_rect, BACKGROUND_COLOR)

	# Draw character at current frame
	if not shapes.is_empty() and not animation_frames.is_empty():
		_draw_animated_character(preview_rect)
	elif not shapes.is_empty():
		_draw_static_character(preview_rect)

	# Border
	draw_rect(preview_rect, BORDER_COLOR, false, 2.0)

	# Frame indicator
	_draw_frame_indicator(preview_rect)


func _get_preview_rect() -> Rect2:
	var available_size := size
	var preview_size := min(available_size.x, available_size.y - 24)  # Leave room for frame indicator
	var offset := Vector2((available_size.x - preview_size) / 2, 0)
	return Rect2(offset, Vector2(preview_size, preview_size))


func _draw_animated_character(preview_rect: Rect2) -> void:
	if current_frame < 0 or current_frame >= animation_frames.size():
		return

	var frame_rotations := animation_frames[current_frame]

	# Create a temporary pose from the frame rotations
	var temp_pose := Pose.new("preview_frame", frame_rotations)

	# Apply pose to shapes and draw
	var transformed_shapes := PoseRenderer.apply_pose(shapes, body_parts, temp_pose, canvas_size)
	_draw_shapes(transformed_shapes, preview_rect)


func _draw_static_character(preview_rect: Rect2) -> void:
	_draw_shapes(shapes, preview_rect)


func _draw_shapes(shapes_to_draw: Array, preview_rect: Rect2) -> void:
	# Sort by layer
	var sorted_shapes := shapes_to_draw.duplicate()
	sorted_shapes.sort_custom(func(a, b): return a.get("layer", 0) < b.get("layer", 0))

	var scale := preview_rect.size.x / float(canvas_size)

	for shape in sorted_shapes:
		var pos := Vector2(shape.position[0], shape.position[1]) * scale + preview_rect.position
		var shape_size := Vector2(shape.size[0], shape.size[1]) * scale
		var color := Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])
		var rotation: float = shape.get("rotation", 0.0)

		match shape.type:
			"rectangle":
				_draw_rotated_rect(pos, shape_size, rotation, color)
			"circle":
				_draw_circle_shape(pos, shape_size, color)
			"ellipse":
				_draw_ellipse_shape(pos, shape_size, rotation, color)
			"triangle":
				_draw_triangle_shape(pos, shape_size, rotation, color)


func _draw_rotated_rect(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var half_size := shape_size / 2
	var points: PackedVector2Array = []

	var corners: Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	for corner in corners:
		var point: Vector2 = corner * half_size
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_circle_shape(pos: Vector2, shape_size: Vector2, color: Color) -> void:
	var center := pos + shape_size / 2
	var radius: float = minf(shape_size.x, shape_size.y) / 2.0
	draw_circle(center, radius, color)


func _draw_ellipse_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var points: PackedVector2Array = []

	for i in range(24):
		var angle := i * TAU / 24
		var point := Vector2(cos(angle) * shape_size.x / 2, sin(angle) * shape_size.y / 2)
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_triangle_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var tri_points := [
		Vector2(0, -shape_size.y / 2),
		Vector2(-shape_size.x / 2, shape_size.y / 2),
		Vector2(shape_size.x / 2, shape_size.y / 2),
	]

	var points: PackedVector2Array = []
	for point in tri_points:
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_frame_indicator(preview_rect: Rect2) -> void:
	var indicator_y := preview_rect.end.y + 4
	var total_frames := animation_frames.size()

	if total_frames == 0:
		return

	var font := ThemeDB.fallback_font
	var text := "Frame: %d / %d" % [current_frame + 1, total_frames]
	var text_pos := Vector2(preview_rect.position.x, indicator_y + 14)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Draw playing indicator
	if is_playing:
		var play_text := "[Playing]"
		var play_pos := Vector2(preview_rect.end.x - 60, indicator_y + 14)
		draw_string(font, play_pos, play_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(0.4, 0.8, 0.4))


func _advance_frame() -> void:
	if animation_frames.is_empty():
		return

	current_frame += 1

	if current_frame >= animation_frames.size():
		if is_looping:
			current_frame = 0
		else:
			current_frame = animation_frames.size() - 1
			is_playing = false
			set_process(false)  # Disable _process when animation finishes
			playback_finished.emit()

	frame_changed.emit(current_frame)
	queue_redraw()


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the character data for preview.
func set_character_data(p_shapes: Array, p_body_parts: Dictionary, p_canvas_size: int) -> void:
	shapes = p_shapes.duplicate(true)
	body_parts = p_body_parts
	canvas_size = p_canvas_size
	queue_redraw()


## Set the animation frames to preview.
func set_animation_frames(frames: Array[Dictionary], p_fps: int = 12, p_loop: bool = true) -> void:
	animation_frames = frames
	fps = p_fps
	is_looping = p_loop
	current_frame = 0
	_playback_timer = 0.0
	queue_redraw()


## Clear the animation preview.
func clear_animation() -> void:
	animation_frames.clear()
	current_frame = 0
	is_playing = false
	_playback_timer = 0.0
	queue_redraw()


## Start playback.
func play() -> void:
	if animation_frames.is_empty():
		return
	is_playing = true
	_playback_timer = 0.0
	set_process(true)  # Enable _process for animation
	queue_redraw()


## Pause playback.
func pause() -> void:
	is_playing = false
	set_process(false)  # Disable _process when paused
	queue_redraw()


## Stop playback and reset to frame 0.
func stop() -> void:
	is_playing = false
	current_frame = 0
	_playback_timer = 0.0
	set_process(false)  # Disable _process when stopped
	frame_changed.emit(current_frame)
	queue_redraw()


## Toggle play/pause.
func toggle_playback() -> void:
	if is_playing:
		pause()
	else:
		play()


## Go to a specific frame.
func go_to_frame(frame_index: int) -> void:
	if animation_frames.is_empty():
		return

	current_frame = clampi(frame_index, 0, animation_frames.size() - 1)
	frame_changed.emit(current_frame)
	queue_redraw()


## Go to next frame.
func next_frame() -> void:
	if animation_frames.is_empty():
		return

	current_frame = (current_frame + 1) % animation_frames.size()
	frame_changed.emit(current_frame)
	queue_redraw()


## Go to previous frame.
func prev_frame() -> void:
	if animation_frames.is_empty():
		return

	current_frame -= 1
	if current_frame < 0:
		current_frame = animation_frames.size() - 1
	frame_changed.emit(current_frame)
	queue_redraw()


## Set FPS.
func set_fps(p_fps: int) -> void:
	fps = max(1, p_fps)


## Set looping.
func set_looping(p_loop: bool) -> void:
	is_looping = p_loop


## Get current frame index.
func get_current_frame() -> int:
	return current_frame


## Get total frame count.
func get_frame_count() -> int:
	return animation_frames.size()


## Check if animation is playing.
func is_animation_playing() -> bool:
	return is_playing
