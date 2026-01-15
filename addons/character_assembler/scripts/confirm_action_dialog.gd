@tool
extends ConfirmationDialog
class_name ConfirmActionDialog
## Reusable confirmation dialog for destructive operations.
## Supports configurable title, message, and action callbacks.

signal action_confirmed()
signal action_canceled()

var _action_type: String = ""


func _init() -> void:
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)


## Configure and show the confirmation dialog.
func show_confirmation(
	action_type: String,
	title_text: String,
	message: String,
	confirm_text: String = "Confirm",
	cancel_text: String = "Cancel"
) -> void:
	_action_type = action_type
	title = title_text
	dialog_text = message
	ok_button_text = confirm_text
	cancel_button_text = cancel_text

	popup_centered()


## Show confirmation for deleting shapes.
func confirm_delete_shapes(count: int) -> void:
	var msg := "Are you sure you want to delete %d shape(s)?\n\nThis action cannot be undone." % count
	show_confirmation("delete_shapes", "Delete Shapes?", msg, "Delete", "Cancel")


## Show confirmation for clearing all shapes.
func confirm_clear_canvas() -> void:
	var msg := "Are you sure you want to clear the entire canvas?\n\nThis will remove all shapes and cannot be undone."
	show_confirmation("clear_canvas", "Clear Canvas?", msg, "Clear All", "Cancel")


## Show confirmation for clearing reference image.
func confirm_clear_reference() -> void:
	var msg := "Remove the reference image from this project?"
	show_confirmation("clear_reference", "Clear Reference Image?", msg, "Clear", "Cancel")


## Show confirmation for closing without saving.
func confirm_close_unsaved() -> void:
	var msg := "You have unsaved changes that will be lost.\n\nDo you want to save before closing?"
	show_confirmation("close_unsaved", "Unsaved Changes", msg, "Save", "Don't Save")


## Show confirmation for deleting a pose.
func confirm_delete_pose(pose_name: String) -> void:
	var msg := "Are you sure you want to delete the pose '%s'?\n\nAnimations using this pose will need to be updated." % pose_name
	show_confirmation("delete_pose", "Delete Pose?", msg, "Delete", "Cancel")


## Show confirmation for deleting an animation.
func confirm_delete_animation(anim_name: String) -> void:
	var msg := "Are you sure you want to delete the animation '%s'?\n\nThis will remove all generated frames." % anim_name
	show_confirmation("delete_animation", "Delete Animation?", msg, "Delete", "Cancel")


## Show confirmation for resetting body part configuration.
func confirm_reset_body_parts() -> void:
	var msg := "Reset all body part configurations?\n\nThis will clear all shape assignments and pivot points."
	show_confirmation("reset_body_parts", "Reset Body Parts?", msg, "Reset", "Cancel")


## Show confirmation for overwriting an existing file.
func confirm_overwrite_file(file_name: String) -> void:
	var msg := "The file '%s' already exists.\n\nDo you want to replace it?" % file_name
	show_confirmation("overwrite_file", "Overwrite File?", msg, "Replace", "Cancel")


## Get the type of the last confirmed action.
func get_action_type() -> String:
	return _action_type


func _on_confirmed() -> void:
	action_confirmed.emit()
	queue_free()


func _on_canceled() -> void:
	action_canceled.emit()
	queue_free()
