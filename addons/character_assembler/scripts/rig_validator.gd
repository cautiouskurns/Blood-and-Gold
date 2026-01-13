@tool
extends RefCounted
class_name RigValidator
## Validates rig configuration for the Character Assembler.
## Checks for missing shapes, pivots, circular references, and other issues.

enum IssueType {
	INFO,
	WARNING,
	ERROR,
}

## Validation issue data structure.
class ValidationIssue:
	var type: IssueType
	var message: String
	var part_name: String

	func _init(t: IssueType, msg: String, part: String = "") -> void:
		type = t
		message = msg
		part_name = part


## Validate the rig and return a list of issues.
static func validate(body_parts: Dictionary, total_shapes: int) -> Array[ValidationIssue]:
	var issues: Array[ValidationIssue] = []

	# Check for untagged shapes
	var tagged_shapes := _get_all_tagged_shapes(body_parts)
	var untagged_count := total_shapes - tagged_shapes.size()

	if untagged_count > 0:
		issues.append(ValidationIssue.new(
			IssueType.WARNING,
			"%d shape(s) not assigned to any body part" % untagged_count
		))

	# Check each body part
	for part_name in BodyPart.PART_NAMES:
		if part_name in body_parts:
			var part: BodyPart = body_parts[part_name]

			# Check for empty body part
			if not part.has_shapes():
				issues.append(ValidationIssue.new(
					IssueType.WARNING,
					"No shapes assigned",
					part_name
				))

			# Check for missing pivot
			if not part.pivot_set:
				issues.append(ValidationIssue.new(
					IssueType.WARNING,
					"Pivot point not set",
					part_name
				))

			# Validate parent reference
			if not part.parent_name.is_empty():
				if not BodyPart.is_valid_part_name(part.parent_name):
					issues.append(ValidationIssue.new(
						IssueType.ERROR,
						"Invalid parent: %s" % part.parent_name,
						part_name
					))
		else:
			# Body part not defined at all
			issues.append(ValidationIssue.new(
				IssueType.INFO,
				"Not configured",
				part_name
			))

	# Check for circular references
	var circular := _check_circular_references(body_parts)
	for part_name in circular:
		issues.append(ValidationIssue.new(
			IssueType.ERROR,
			"Circular parent reference detected",
			part_name
		))

	# Check for duplicate shape assignments
	var duplicates := _check_duplicate_shapes(body_parts)
	for shape_idx in duplicates:
		issues.append(ValidationIssue.new(
			IssueType.WARNING,
			"Shape %d assigned to multiple body parts" % shape_idx
		))

	return issues


## Get count of configured body parts.
static func get_configured_count(body_parts: Dictionary) -> int:
	var count := 0
	for part_name in BodyPart.PART_NAMES:
		if part_name in body_parts:
			var part: BodyPart = body_parts[part_name]
			if part.has_shapes():
				count += 1
	return count


## Get count of complete body parts (shapes + pivot).
static func get_complete_count(body_parts: Dictionary) -> int:
	var count := 0
	for part_name in BodyPart.PART_NAMES:
		if part_name in body_parts:
			var part: BodyPart = body_parts[part_name]
			if part.is_complete():
				count += 1
	return count


## Check if the rig is ready for animation.
static func is_animation_ready(body_parts: Dictionary) -> bool:
	# At minimum, need Torso configured
	if "Torso" not in body_parts:
		return false

	var torso: BodyPart = body_parts["Torso"]
	if not torso.is_complete():
		return false

	# At least 3 body parts should be complete
	return get_complete_count(body_parts) >= 3


## Get all shape indices that are tagged.
static func _get_all_tagged_shapes(body_parts: Dictionary) -> Array[int]:
	var tagged: Array[int] = []
	for part_name in body_parts:
		var part: BodyPart = body_parts[part_name]
		for idx in part.shape_indices:
			if idx not in tagged:
				tagged.append(idx)
	return tagged


## Check for circular parent references.
static func _check_circular_references(body_parts: Dictionary) -> Array[String]:
	var circular: Array[String] = []

	for part_name in body_parts:
		var part: BodyPart = body_parts[part_name]
		var visited: Array[String] = [part_name]
		var current := part.parent_name

		while not current.is_empty():
			if current in visited:
				if part_name not in circular:
					circular.append(part_name)
				break

			visited.append(current)

			if current in body_parts:
				current = body_parts[current].parent_name
			else:
				break

	return circular


## Check for shapes assigned to multiple body parts.
static func _check_duplicate_shapes(body_parts: Dictionary) -> Array[int]:
	var seen: Dictionary = {}  # shape_idx -> part_name
	var duplicates: Array[int] = []

	for part_name in body_parts:
		var part: BodyPart = body_parts[part_name]
		for idx in part.shape_indices:
			if idx in seen:
				if idx not in duplicates:
					duplicates.append(idx)
			else:
				seen[idx] = part_name

	return duplicates


## Get validation summary text.
static func get_summary(body_parts: Dictionary, total_shapes: int) -> String:
	var issues := validate(body_parts, total_shapes)

	var errors := 0
	var warnings := 0
	var info := 0

	for issue in issues:
		match issue.type:
			IssueType.ERROR: errors += 1
			IssueType.WARNING: warnings += 1
			IssueType.INFO: info += 1

	if errors > 0:
		return "%d error(s), %d warning(s)" % [errors, warnings]
	elif warnings > 0:
		return "%d warning(s)" % warnings
	else:
		return "Rig valid"


## Get icon name for issue type.
static func get_issue_icon(type: IssueType) -> String:
	match type:
		IssueType.ERROR: return "StatusError"
		IssueType.WARNING: return "StatusWarning"
		IssueType.INFO: return "StatusSuccess"
		_: return "StatusSuccess"


## Get color for issue type.
static func get_issue_color(type: IssueType) -> Color:
	match type:
		IssueType.ERROR: return Color(0.9, 0.3, 0.3)
		IssueType.WARNING: return Color(0.9, 0.7, 0.2)
		IssueType.INFO: return Color(0.5, 0.5, 0.5)
		_: return Color.WHITE
