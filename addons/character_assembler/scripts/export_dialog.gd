@tool
extends Window
class_name ExportDialog
## Dialog showing export progress and results.
## Handles the actual export execution with progress feedback.

signal export_finished(success: bool, results: Dictionary)

# UI elements
var _progress_bar: ProgressBar
var _status_label: Label
var _details_text: RichTextLabel
var _close_btn: Button
var _cancel_btn: Button

# State
var _is_exporting: bool = false
var _was_cancelled: bool = false


func _ready() -> void:
	title = "Exporting..."
	size = Vector2(500, 300)
	unresizable = false
	close_requested.connect(_on_close_requested)

	_setup_ui()


func _setup_ui() -> void:
	var margin := MarginContainer.new()
	margin.anchors_preset = Control.PRESET_FULL_RECT
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Status label
	_status_label = Label.new()
	_status_label.text = "Preparing export..."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_status_label)

	# Progress bar
	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0
	_progress_bar.max_value = 100
	_progress_bar.value = 0
	_progress_bar.custom_minimum_size.y = 24
	vbox.add_child(_progress_bar)

	# Details text
	_details_text = RichTextLabel.new()
	_details_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_text.bbcode_enabled = true
	_details_text.scroll_following = true
	vbox.add_child(_details_text)

	# Buttons
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_hbox)

	_cancel_btn = Button.new()
	_cancel_btn.text = "Cancel"
	_cancel_btn.custom_minimum_size = Vector2(100, 32)
	_cancel_btn.pressed.connect(_on_cancel_pressed)
	btn_hbox.add_child(_cancel_btn)

	_close_btn = Button.new()
	_close_btn.text = "Close"
	_close_btn.custom_minimum_size = Vector2(100, 32)
	_close_btn.pressed.connect(_on_close_pressed)
	_close_btn.visible = false
	btn_hbox.add_child(_close_btn)


## Execute the export with the given options and data.
func execute_export(
	options: ExportManager.ExportOptions,
	shapes: Array,
	body_parts: Dictionary,
	animations: Array[AnimationData],
	canvas_size: int,
	direction_views: Dictionary = {},
	body_parts_per_direction: Dictionary = {}
) -> void:
	_is_exporting = true
	_was_cancelled = false
	_cancel_btn.visible = true
	_close_btn.visible = false
	_details_text.clear()

	var results := {
		"sprite_sheet": null,
		"frames_exported": 0,
		"scene_path": "",
		"errors": []
	}

	var total_steps := _calculate_total_steps(options, animations, direction_views)
	var current_step := 0

	# Create output directory
	_log("Creating output directory...")
	var dir_err := DirAccess.make_dir_recursive_absolute(options.output_directory)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		_log_error("Failed to create output directory: %s" % error_string(dir_err))
		results.errors.append("Failed to create output directory")
		_finish_export(false, results)
		return

	current_step += 1
	_update_progress(current_step, total_steps, "Created output directory")

	if _was_cancelled:
		_finish_export(false, results)
		return

	# Export sprite sheet
	if options.export_sprite_sheet:
		_log("Generating sprite sheet...")

		var sheet_result: SpriteSheetGenerator.SpriteSheetResult

		if options.export_all_directions and not direction_views.is_empty():
			sheet_result = SpriteSheetGenerator.generate_all_directions(
				direction_views,
				body_parts_per_direction,
				animations,
				canvas_size,
				options.scale,
				options.background_type,
				options.background_color
			)
		else:
			sheet_result = SpriteSheetGenerator.generate(
				shapes,
				body_parts,
				animations,
				canvas_size,
				options.scale,
				options.background_type,
				options.background_color
			)

		if sheet_result.image != null:
			var sheet_path := options.output_directory.path_join(
				"%s_spritesheet.png" % options.character_name.to_lower().replace(" ", "_")
			)
			var save_err := SpriteSheetGenerator.save_to_png(sheet_result, sheet_path)

			if save_err == OK:
				results.sprite_sheet = sheet_result
				_log_success("Saved sprite sheet: %s" % sheet_path.get_file())

				# Export metadata
				if options.export_metadata:
					var meta_path := options.output_directory.path_join(
						"%s_metadata.json" % options.character_name.to_lower().replace(" ", "_")
					)
					var meta_err := GodotSceneGenerator.generate_metadata_json(
						sheet_result, options.character_name, canvas_size, options.scale, meta_path
					)
					if meta_err == OK:
						_log_success("Saved metadata: %s" % meta_path.get_file())
					else:
						_log_error("Failed to save metadata")

				# Export Godot scene
				if options.export_godot_scene:
					var scene_result := GodotSceneGenerator.generate_scene(
						sheet_result,
						sheet_path,
						options.output_directory,
						options.character_name
					)
					if scene_result.success:
						results.scene_path = scene_result.scene_path
						_log_success("Generated scene: %s" % scene_result.scene_path.get_file())
						_log_success("Generated SpriteFrames: %s" % scene_result.sprite_frames_path.get_file())
					else:
						for err in scene_result.errors:
							_log_error(err)
							results.errors.append(err)
			else:
				_log_error("Failed to save sprite sheet: %s" % error_string(save_err))
				results.errors.append("Failed to save sprite sheet")
		else:
			_log_error("Failed to generate sprite sheet (no animations?)")
			results.errors.append("Failed to generate sprite sheet")

		current_step += 1
		_update_progress(current_step, total_steps, "Sprite sheet complete")

		if _was_cancelled:
			_finish_export(false, results)
			return

	# Export individual frames
	if options.export_individual_frames:
		_log("Exporting individual frames...")

		var frame_result: FrameExporter.FrameExportResult

		if options.export_all_directions and not direction_views.is_empty():
			frame_result = FrameExporter.export_all_directions(
				direction_views,
				body_parts_per_direction,
				animations,
				options.output_directory,
				options.character_name,
				canvas_size,
				options.scale,
				options.background_type,
				options.background_color
			)
		else:
			frame_result = FrameExporter.export_all_animations(
				shapes,
				body_parts,
				animations,
				options.output_directory,
				options.character_name,
				"",
				canvas_size,
				options.scale,
				options.background_type,
				options.background_color
			)

		results.frames_exported = frame_result.files_exported

		if frame_result.success:
			_log_success("Exported %d frames" % frame_result.files_exported)
		else:
			for err in frame_result.errors:
				_log_error(err)
				results.errors.append(err)

		current_step += 1
		_update_progress(current_step, total_steps, "Frames export complete")

	# Finish
	var success: bool = results.errors.is_empty()
	_finish_export(success, results)


func _calculate_total_steps(
	options: ExportManager.ExportOptions,
	animations: Array[AnimationData],
	direction_views: Dictionary
) -> int:
	var steps := 1  # Directory creation

	if options.export_sprite_sheet:
		steps += 1

	if options.export_individual_frames:
		steps += 1

	return steps


func _update_progress(current: int, total: int, message: String) -> void:
	var percent := (float(current) / float(total)) * 100.0
	_progress_bar.value = percent
	_status_label.text = message


func _log(message: String) -> void:
	_details_text.append_text(message + "\n")


func _log_success(message: String) -> void:
	_details_text.append_text("[color=green]✓ %s[/color]\n" % message)


func _log_error(message: String) -> void:
	_details_text.append_text("[color=red]✗ %s[/color]\n" % message)


func _finish_export(success: bool, results: Dictionary) -> void:
	_is_exporting = false
	_cancel_btn.visible = false
	_close_btn.visible = true

	if _was_cancelled:
		title = "Export Cancelled"
		_status_label.text = "Export was cancelled"
		_log("\n[color=yellow]Export cancelled by user[/color]")
	elif success:
		title = "Export Complete"
		_status_label.text = "Export completed successfully!"
		_progress_bar.value = 100
		_log("\n[color=green][b]Export completed successfully![/b][/color]")
	else:
		title = "Export Failed"
		_status_label.text = "Export completed with errors"
		_log("\n[color=red][b]Export completed with errors[/b][/color]")

	export_finished.emit(success and not _was_cancelled, results)


func _on_cancel_pressed() -> void:
	_was_cancelled = true
	_log("\n[color=yellow]Cancelling...[/color]")


func _on_close_pressed() -> void:
	hide()
	queue_free()


func _on_close_requested() -> void:
	if _is_exporting:
		_was_cancelled = true
	else:
		hide()
		queue_free()
