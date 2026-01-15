@tool
extends ConfirmationDialog
class_name RecoveryDialog
## Dialog for recovering from auto-saved files after a crash.
## Shows available recovery files and lets the user choose to recover or discard.

signal recovery_requested(path: String)
signal recovery_dismissed()
signal recovery_all_dismissed()

var _content_vbox: VBoxContainer
var _info_label: Label
var _file_list: ItemList
var _recovery_files: Array[Dictionary] = []


func _init() -> void:
	title = "Recover Unsaved Work?"
	min_size = Vector2(500, 350)
	ok_button_text = "Recover Selected"
	add_button("Discard All", false, "discard_all")

	confirmed.connect(_on_recover_pressed)
	canceled.connect(_on_cancel_pressed)
	custom_action.connect(_on_custom_action)


func _ready() -> void:
	_setup_ui()


func _setup_ui() -> void:
	_content_vbox = VBoxContainer.new()
	_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_content_vbox)

	# Info label
	_info_label = Label.new()
	_info_label.text = "The Character Assembler found unsaved work from a previous session.\nWould you like to recover it?"
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_vbox.add_child(_info_label)

	# Separator
	var sep := HSeparator.new()
	_content_vbox.add_child(sep)

	# File list
	_file_list = ItemList.new()
	_file_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_file_list.select_mode = ItemList.SELECT_SINGLE
	_file_list.item_selected.connect(_on_item_selected)
	_content_vbox.add_child(_file_list)


## Show the recovery dialog with the given files.
func show_recovery_files(files: Array[Dictionary]) -> void:
	_recovery_files = files
	_file_list.clear()

	if files.is_empty():
		recovery_dismissed.emit()
		queue_free()
		return

	for file_data in files:
		var display_text := "%s (Last modified: %s)" % [
			file_data.file_name,
			file_data.modified_date
		]
		_file_list.add_item(display_text)

	# Select the first (most recent) by default
	_file_list.select(0)

	popup_centered()


func _on_item_selected(index: int) -> void:
	# Item selection - just update UI feedback
	pass


func _on_recover_pressed() -> void:
	var selected := _file_list.get_selected_items()
	if selected.is_empty():
		# If nothing selected, use the first one
		if not _recovery_files.is_empty():
			recovery_requested.emit(_recovery_files[0].path)
	else:
		recovery_requested.emit(_recovery_files[selected[0]].path)

	queue_free()


func _on_cancel_pressed() -> void:
	recovery_dismissed.emit()
	queue_free()


func _on_custom_action(action: StringName) -> void:
	if action == "discard_all":
		recovery_all_dismissed.emit()
		queue_free()
