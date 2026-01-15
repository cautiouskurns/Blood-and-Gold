@tool
extends ConfirmationDialog
class_name ValidationDialog
## Dialog for displaying validation results before export.
## Shows warnings/errors and allows the user to proceed or cancel.

signal validation_accepted()
signal validation_rejected()

var _content_vbox: VBoxContainer
var _summary_label: Label
var _issues_container: ScrollContainer
var _issues_list: VBoxContainer


func _init() -> void:
	title = "Export Validation"
	min_size = Vector2(500, 400)
	ok_button_text = "Export Anyway"

	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)


func _ready() -> void:
	_setup_ui()


func _setup_ui() -> void:
	_content_vbox = VBoxContainer.new()
	_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_content_vbox)

	# Summary label
	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.add_theme_font_size_override("font_size", 14)
	_content_vbox.add_child(_summary_label)

	# Separator
	var sep := HSeparator.new()
	_content_vbox.add_child(sep)

	# Scrollable issues container
	_issues_container = ScrollContainer.new()
	_issues_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_issues_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content_vbox.add_child(_issues_container)

	_issues_list = VBoxContainer.new()
	_issues_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_issues_container.add_child(_issues_list)


## Display validation issues.
## Returns true if there are blocking errors, false if only warnings.
func show_validation(issues: Array[RigValidator.ValidationIssue], export_issues: Array[String] = []) -> bool:
	_clear_issues()

	var error_count := 0
	var warning_count := 0

	# Add export-specific issues first
	for msg in export_issues:
		_add_issue_item(RigValidator.IssueType.ERROR, msg, "")
		error_count += 1

	# Add rig validation issues
	for issue in issues:
		_add_issue_item(issue.type, issue.message, issue.part_name)
		match issue.type:
			RigValidator.IssueType.ERROR:
				error_count += 1
			RigValidator.IssueType.WARNING:
				warning_count += 1

	# Update summary
	if error_count > 0:
		_summary_label.text = "%d Error(s), %d Warning(s) - Cannot export with errors" % [error_count, warning_count]
		_summary_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		get_ok_button().disabled = true
		get_ok_button().text = "Fix Errors First"
	elif warning_count > 0:
		_summary_label.text = "%d Warning(s) - Export may have issues" % warning_count
		_summary_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
		get_ok_button().disabled = false
		get_ok_button().text = "Export Anyway"
	else:
		_summary_label.text = "All checks passed"
		_summary_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
		get_ok_button().disabled = false
		get_ok_button().text = "Export"

	# Show the dialog
	popup_centered()

	return error_count > 0


func _add_issue_item(type: RigValidator.IssueType, message: String, part_name: String) -> void:
	var item := HBoxContainer.new()
	item.add_theme_constant_override("separation", 8)
	_issues_list.add_child(item)

	# Icon based on type
	var icon_label := Label.new()
	match type:
		RigValidator.IssueType.ERROR:
			icon_label.text = "[X]"
			icon_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		RigValidator.IssueType.WARNING:
			icon_label.text = "[!]"
			icon_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
		RigValidator.IssueType.INFO:
			icon_label.text = "[i]"
			icon_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	icon_label.custom_minimum_size.x = 30
	item.add_child(icon_label)

	# Part name (if applicable)
	if not part_name.is_empty():
		var part_label := Label.new()
		part_label.text = "[%s]" % part_name
		part_label.custom_minimum_size.x = 100
		part_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
		item.add_child(part_label)

	# Message
	var msg_label := Label.new()
	msg_label.text = message
	msg_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(msg_label)

	# Suggestion (for certain issues)
	var suggestion := _get_suggestion_for_issue(type, message, part_name)
	if not suggestion.is_empty():
		var sep := VSeparator.new()
		item.add_child(sep)

		var suggestion_label := Label.new()
		suggestion_label.text = suggestion
		suggestion_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		suggestion_label.add_theme_font_size_override("font_size", 12)
		item.add_child(suggestion_label)


func _get_suggestion_for_issue(type: RigValidator.IssueType, message: String, part_name: String) -> String:
	# Provide helpful suggestions for common issues
	if message.contains("Pivot point not set"):
		return "Tip: Click 'Set Pivot' in Body Part Tagger"
	elif message.contains("No shapes assigned"):
		return "Tip: Select shapes and assign in Body Part Tagger"
	elif message.contains("not assigned to any body part"):
		return "Tip: Tag all shapes with body parts for animation"
	elif message.contains("No animations to export"):
		return "Tip: Create and generate animations first"
	elif message.contains("No generated animations"):
		return "Tip: Click 'Generate' on animations"
	elif message.contains("character name"):
		return "Tip: Enter a name in the Export section"
	elif message.contains("output directory"):
		return "Tip: Select or create an output folder"

	return ""


func _clear_issues() -> void:
	for child in _issues_list.get_children():
		child.queue_free()


func _on_confirmed() -> void:
	validation_accepted.emit()
	queue_free()


func _on_canceled() -> void:
	validation_rejected.emit()
	queue_free()
