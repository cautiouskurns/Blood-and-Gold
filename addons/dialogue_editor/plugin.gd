@tool
extends EditorPlugin

const MainPanel = preload("res://addons/dialogue_editor/scenes/main_panel.tscn")

var main_panel_instance: Control


func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	var main_screen = EditorInterface.get_editor_main_screen()
	main_screen.add_child(main_panel_instance)

	# Force the panel to fill the main screen area
	main_panel_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_panel_instance.set_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Connect to parent resize to keep panel filling the area
	main_screen.resized.connect(_on_main_screen_resized)
	call_deferred("_on_main_screen_resized")

	_make_visible(false)


func _on_main_screen_resized() -> void:
	if main_panel_instance and main_panel_instance.get_parent():
		var parent_size = main_panel_instance.get_parent().size
		main_panel_instance.size = parent_size
		main_panel_instance.position = Vector2.ZERO


func _exit_tree() -> void:
	var main_screen = EditorInterface.get_editor_main_screen()
	if main_screen.resized.is_connected(_on_main_screen_resized):
		main_screen.resized.disconnect(_on_main_screen_resized)
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name() -> String:
	return "Dialogue"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons")
