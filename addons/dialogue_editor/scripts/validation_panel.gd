@tool
extends PanelContainer
## Panel that displays validation results and allows jumping to problem nodes.

const DialogueValidatorScript = preload("res://addons/dialogue_editor/scripts/dialogue_validator.gd")

signal issue_selected(node_id: String)
signal panel_closed()

# UI Elements
var _header_label: Label
var _close_btn: Button
var _refresh_btn: Button
var _issue_list: ItemList
var _summary_label: Label
var _error_icon: Texture2D
var _warning_icon: Texture2D
var _info_icon: Texture2D

# State
var _validator: RefCounted = null
var _canvas: GraphEdit = null
var _issues: Array = []  # Array of ValidationIssue


func _init() -> void:
	custom_minimum_size = Vector2(300, 200)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func _ready() -> void:
	_build_ui()
	_load_icons()


func _build_ui() -> void:
	# Main container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	# Header row
	var header_row = HBoxContainer.new()
	vbox.add_child(header_row)

	_header_label = Label.new()
	_header_label.text = "VALIDATION RESULTS"
	_header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(_header_label)

	_refresh_btn = Button.new()
	_refresh_btn.text = "Refresh"
	_refresh_btn.tooltip_text = "Re-run validation"
	_refresh_btn.pressed.connect(_on_refresh_pressed)
	header_row.add_child(_refresh_btn)

	_close_btn = Button.new()
	_close_btn.text = "X"
	_close_btn.tooltip_text = "Close validation panel"
	_close_btn.pressed.connect(_on_close_pressed)
	header_row.add_child(_close_btn)

	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Issue list
	_issue_list = ItemList.new()
	_issue_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_issue_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_issue_list.allow_reselect = true
	_issue_list.item_clicked.connect(_on_issue_clicked)
	_issue_list.custom_minimum_size = Vector2(0, 150)
	vbox.add_child(_issue_list)

	# Summary row
	var summary_row = HBoxContainer.new()
	vbox.add_child(summary_row)

	_summary_label = Label.new()
	_summary_label.text = "No issues"
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_row.add_child(_summary_label)


func _load_icons() -> void:
	# Load built-in editor icons
	if Engine.is_editor_hint():
		var base_control = EditorInterface.get_base_control()
		if base_control:
			_error_icon = base_control.get_theme_icon("StatusError", "EditorIcons")
			_warning_icon = base_control.get_theme_icon("StatusWarning", "EditorIcons")
			_info_icon = base_control.get_theme_icon("NodeInfo", "EditorIcons")


## Setup with canvas reference.
func setup(canvas: GraphEdit) -> void:
	_canvas = canvas
	_validator = DialogueValidatorScript.new()
	_validator.setup(canvas)


## Run validation and display results.
func validate() -> void:
	if not _validator:
		return

	_issues = _validator.validate()
	_display_issues()
	_update_summary()


## Get issues for external use (e.g., node warning icons).
func get_issues() -> Array:
	return _issues


## Get nodes that have issues.
func get_nodes_with_issues() -> Array[String]:
	if _validator:
		return _validator.get_nodes_with_issues()
	return []


## Check if there are any errors.
func has_errors() -> bool:
	if _validator:
		return _validator.has_errors()
	return false


func _display_issues() -> void:
	_issue_list.clear()

	for i in _issues.size():
		var issue = _issues[i]
		var text = _format_issue_text(issue)
		var idx = _issue_list.add_item(text)

		# Set icon based on severity
		var icon = _get_severity_icon(issue.severity)
		if icon:
			_issue_list.set_item_icon(idx, icon)

		# Store issue index in metadata
		_issue_list.set_item_metadata(idx, i)

		# Color code by severity
		var color = _get_severity_color(issue.severity)
		_issue_list.set_item_custom_fg_color(idx, color)


func _format_issue_text(issue) -> String:
	if issue.node_id.is_empty():
		return issue.message
	else:
		return "[%s] %s" % [issue.node_id, issue.message]


func _get_severity_icon(severity: int) -> Texture2D:
	match severity:
		DialogueValidatorScript.Severity.ERROR:
			return _error_icon
		DialogueValidatorScript.Severity.WARNING:
			return _warning_icon
		DialogueValidatorScript.Severity.INFO:
			return _info_icon
	return null


func _get_severity_color(severity: int) -> Color:
	match severity:
		DialogueValidatorScript.Severity.ERROR:
			return Color.RED
		DialogueValidatorScript.Severity.WARNING:
			return Color.YELLOW
		DialogueValidatorScript.Severity.INFO:
			return Color.CYAN
	return Color.WHITE


func _update_summary() -> void:
	if _validator:
		_summary_label.text = _validator.get_summary()

		# Color the summary based on worst severity
		var counts = _validator.get_issue_counts()
		if counts["errors"] > 0:
			_summary_label.add_theme_color_override("font_color", Color.RED)
		elif counts["warnings"] > 0:
			_summary_label.add_theme_color_override("font_color", Color.YELLOW)
		elif counts["total"] > 0:
			_summary_label.add_theme_color_override("font_color", Color.CYAN)
		else:
			_summary_label.add_theme_color_override("font_color", Color.GREEN)


func _on_issue_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var issue_index = _issue_list.get_item_metadata(index)
	if issue_index >= 0 and issue_index < _issues.size():
		var issue = _issues[issue_index]
		if not issue.node_id.is_empty():
			issue_selected.emit(issue.node_id)


func _on_refresh_pressed() -> void:
	validate()


func _on_close_pressed() -> void:
	visible = false
	panel_closed.emit()
