## MapSelector - UI for switching between combat maps
## Part of: Blood & Gold Prototype
## Task 2.16: Combat Map - Forest Clearing
extends PanelContainer

# ===== SIGNALS =====
signal map_changed(map_name: String)

# ===== CONSTANTS =====
const MAP_DEFAULT: String = "default"
const MAP_FOREST_CLEARING: String = "forest_clearing"
const MAP_RUINED_FORT: String = "ruined_fort"
const MAP_OPEN_FIELD: String = "open_field"

# ===== NODE REFERENCES =====
@onready var map_dropdown: OptionButton = $VBoxContainer/MapDropdown
@onready var title_label: Label = $VBoxContainer/TitleLabel

# ===== MAP DATA =====
var _available_maps: Dictionary = {
	MAP_DEFAULT: {
		"display_name": "Test Grid",
		"description": "Default procedural test grid with scattered terrain."
	},
	MAP_FOREST_CLEARING: {
		"display_name": "Forest Clearing",
		"description": "Woodland clearing with stream and trees for cover."
	},
	MAP_RUINED_FORT: {
		"display_name": "Ruined Fort",
		"description": "Fortified position with walls and chokepoints."
	},
	MAP_OPEN_FIELD: {
		"display_name": "Open Field",
		"description": "Sparse battlefield with minimal cover for mobility tactics."
	}
}

var _current_map: String = MAP_DEFAULT

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_dropdown()
	_connect_signals()
	print("[MapSelector] Initialized with %d maps" % _available_maps.size())

func _setup_dropdown() -> void:
	map_dropdown.clear()
	var index = 0
	for map_id in _available_maps:
		var map_info = _available_maps[map_id]
		map_dropdown.add_item(map_info["display_name"], index)
		map_dropdown.set_item_metadata(index, map_id)
		index += 1

func _connect_signals() -> void:
	map_dropdown.item_selected.connect(_on_map_selected)

# ===== SIGNAL HANDLERS =====
func _on_map_selected(index: int) -> void:
	var map_id = map_dropdown.get_item_metadata(index) as String
	if map_id != _current_map:
		_current_map = map_id
		print("[MapSelector] Map selected: %s" % map_id)
		map_changed.emit(map_id)

# ===== PUBLIC API =====
func get_current_map() -> String:
	return _current_map

func set_current_map(map_id: String) -> void:
	if map_id in _available_maps:
		_current_map = map_id
		# Update dropdown to match
		for i in range(map_dropdown.item_count):
			if map_dropdown.get_item_metadata(i) == map_id:
				map_dropdown.select(i)
				break
