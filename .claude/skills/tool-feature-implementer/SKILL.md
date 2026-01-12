---
name: tool-feature-implementer
description: Implement tool features from roadmaps, building editor plugins, standalone tools, and CLI utilities for game development. Use this when implementing features from a tool roadmap.
domain: tooling
type: implementer
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Tool Feature Implementer Skill

This skill implements individual features from tool roadmaps, understanding the architecture of Godot editor plugins, standalone tools, and CLI utilities. Takes a feature from a roadmap and builds it completely.

## When to Use This Skill

Invoke this skill when the user:
- Says "implement [feature] from [tool] roadmap"
- Has a tool roadmap and wants to start building
- Says "build the MVP for [tool]"
- Asks "implement the next feature"
- Wants to work through a roadmap feature by feature
- Says "start implementing [tool name]"

---

## Core Principle

**One feature at a time, fully working before moving on.**

- Read the tool spec to understand requirements
- Read the roadmap to understand feature scope
- Implement the feature completely
- Test that it works
- Mark complete in roadmap
- Move to next feature

---

## Tool Architecture Knowledge

### Godot Editor Plugin Structure

```
addons/
└── [plugin_name]/
    ├── plugin.cfg              # Plugin metadata
    ├── plugin.gd               # Main EditorPlugin script
    ├── scenes/
    │   ├── main_panel.tscn     # Main screen panel (if applicable)
    │   ├── dock.tscn           # Dock panel (if applicable)
    │   └── dialogs/            # Popup dialogs
    ├── scripts/
    │   ├── [feature].gd        # Feature scripts
    │   └── components/         # Reusable components
    ├── resources/
    │   └── [custom].gd         # Custom Resource definitions
    └── icons/                  # Editor icons (SVG preferred)
```

### plugin.cfg Format

```ini
[plugin]

name="Plugin Display Name"
description="What the plugin does"
author="Author Name"
version="0.1.0"
script="plugin.gd"
```

### EditorPlugin Base Script

```gdscript
@tool
extends EditorPlugin

# For Main Screen plugins
var main_panel_instance: Control

func _enter_tree() -> void:
    # Initialize plugin
    main_panel_instance = preload("res://addons/plugin_name/scenes/main_panel.tscn").instantiate()
    EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
    _make_visible(false)

func _exit_tree() -> void:
    # Cleanup
    if main_panel_instance:
        main_panel_instance.queue_free()

func _has_main_screen() -> bool:
    return true

func _make_visible(visible: bool) -> void:
    if main_panel_instance:
        main_panel_instance.visible = visible

func _get_plugin_name() -> String:
    return "Plugin Name"

func _get_plugin_icon() -> Texture2D:
    return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
```

### For Dock Plugins

```gdscript
@tool
extends EditorPlugin

var dock: Control

func _enter_tree() -> void:
    dock = preload("res://addons/plugin_name/scenes/dock.tscn").instantiate()
    add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _exit_tree() -> void:
    remove_control_from_docks(dock)
    dock.queue_free()
```

---

## GraphEdit for Node Editors

For visual node editors (like Dialogue Tree Editor):

### GraphEdit Setup

```gdscript
@tool
extends GraphEdit

func _ready() -> void:
    # Configure GraphEdit
    minimap_enabled = true
    show_grid = true
    snapping_enabled = true
    snapping_distance = 20

    # Connect signals
    connection_request.connect(_on_connection_request)
    disconnection_request.connect(_on_disconnection_request)
    delete_nodes_request.connect(_on_delete_nodes_request)

    # Right-click menu
    popup_request.connect(_on_popup_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    disconnect_node(from_node, from_port, to_node, to_port)
```

### GraphNode Setup

```gdscript
@tool
extends GraphNode

signal data_changed

@export var node_data: Dictionary = {}

func _ready() -> void:
    # Configure appearance
    title = "Node Title"
    resizable = true

    # Set slot colors/types
    set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)

func get_data() -> Dictionary:
    return node_data

func set_data(data: Dictionary) -> void:
    node_data = data
    _update_ui()

func _update_ui() -> void:
    # Update UI elements from data
    pass
```

---

## Implementation Workflow

### Step 1: Understand the Feature

```
1. Read tool spec: docs/tools/[tool-name]-spec.md
2. Read roadmap: docs/tools/[tool-name]-roadmap.md
3. Identify the specific feature to implement
4. Note dependencies (other features that must exist first)
5. Note success criteria for this feature
```

### Step 2: Set Up Structure (If First Feature)

For editor plugins:
```
1. Create addons/[plugin_name]/ directory
2. Create plugin.cfg
3. Create plugin.gd with appropriate base
4. Create scenes/ and scripts/ subdirectories
5. Enable plugin in Project Settings
```

For standalone tools:
```
1. Create tools/[tool_name]/ directory
2. Create main scene
3. Create project.godot if separate project
```

For CLI tools:
```
1. Create tools/[tool_name]/ directory
2. Create main script with argument parsing
3. Create any supporting modules
```

### Step 3: Implement the Feature

```
1. Create necessary scenes (.tscn files)
2. Create scripts (.gd files)
3. Wire up signals and connections
4. Add to main plugin/tool integration
5. Test the feature works
```

### Step 4: Verify and Document

```
1. Test against success criteria from roadmap
2. Update roadmap (check off completed items)
3. Add to changelog if significant
4. Note any issues or follow-up tasks
```

---

## Feature Implementation Patterns

### Pattern: Adding a New Node Type (GraphEdit)

```gdscript
# 1. Create node scene: scenes/nodes/speaker_node.tscn
# 2. Create node script: scripts/nodes/speaker_node.gd

@tool
class_name SpeakerNode
extends GraphNode

signal data_changed

var speaker: String = ""
var dialogue_text: String = ""

func _ready() -> void:
    title = "Speaker"
    # Input slot (from previous node)
    set_slot(0, true, 0, Color("#3182ce"), false, 0, Color.WHITE)
    # Output slot (to next node)
    set_slot(1, false, 0, Color.WHITE, true, 0, Color("#38a169"))

    _setup_ui()

func _setup_ui() -> void:
    # Speaker dropdown
    var speaker_dropdown = OptionButton.new()
    speaker_dropdown.add_item("Player")
    speaker_dropdown.add_item("NPC")
    add_child(speaker_dropdown)

    # Dialogue text
    var text_edit = TextEdit.new()
    text_edit.custom_minimum_size = Vector2(200, 80)
    text_edit.placeholder_text = "Enter dialogue..."
    text_edit.text_changed.connect(_on_text_changed)
    add_child(text_edit)

func _on_text_changed() -> void:
    data_changed.emit()

func get_data() -> Dictionary:
    return {
        "type": "speaker",
        "speaker": speaker,
        "text": dialogue_text
    }

func set_data(data: Dictionary) -> void:
    speaker = data.get("speaker", "")
    dialogue_text = data.get("text", "")
    _update_ui()
```

### Pattern: Save/Load System

```gdscript
# In main editor script

const SAVE_DIR = "res://data/dialogue/"

func save_tree(filename: String) -> void:
    var data = {
        "metadata": {
            "version": 1,
            "created": Time.get_datetime_string_from_system()
        },
        "nodes": _serialize_nodes(),
        "connections": _serialize_connections()
    }

    var file = FileAccess.open(SAVE_DIR + filename, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()

func load_tree(filename: String) -> void:
    var file = FileAccess.open(SAVE_DIR + filename, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    file.close()

    _clear_canvas()
    _deserialize_nodes(data.nodes)
    _deserialize_connections(data.connections)

func _serialize_nodes() -> Array:
    var nodes = []
    for child in graph_edit.get_children():
        if child is GraphNode:
            nodes.append({
                "id": child.name,
                "position": [child.position_offset.x, child.position_offset.y],
                "data": child.get_data()
            })
    return nodes

func _serialize_connections() -> Array:
    var connections = []
    for conn in graph_edit.get_connection_list():
        connections.append({
            "from": conn.from_node,
            "from_port": conn.from_port,
            "to": conn.to_node,
            "to_port": conn.to_port
        })
    return connections
```

### Pattern: Undo/Redo System

```gdscript
# Using Godot's built-in UndoRedo

var undo_redo: UndoRedo

func _ready() -> void:
    undo_redo = UndoRedo.new()

func add_node_with_undo(node_type: String, position: Vector2) -> void:
    var node = _create_node(node_type)

    undo_redo.create_action("Add " + node_type + " Node")
    undo_redo.add_do_method(self, "_do_add_node", node, position)
    undo_redo.add_undo_method(self, "_undo_add_node", node)
    undo_redo.commit_action()

func _do_add_node(node: GraphNode, position: Vector2) -> void:
    graph_edit.add_child(node)
    node.position_offset = position

func _undo_add_node(node: GraphNode) -> void:
    graph_edit.remove_child(node)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.ctrl_pressed and event.keycode == KEY_Z:
            if event.shift_pressed:
                undo_redo.redo()
            else:
                undo_redo.undo()
```

### Pattern: Export to Game Format

```gdscript
func export_to_json(output_path: String) -> void:
    var game_data = {
        "dialogue_id": current_tree_id,
        "nodes": {},
        "start": _find_start_node()
    }

    # Convert editor format to game format
    for child in graph_edit.get_children():
        if child is GraphNode:
            var node_data = child.get_data()
            var connections = _get_node_connections(child.name)

            game_data.nodes[child.name] = {
                "type": node_data.type,
                "data": _strip_editor_only_data(node_data),
                "next": connections
            }

    var file = FileAccess.open(output_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(game_data, "\t"))
    file.close()

    print("Exported to: ", output_path)
```

---

## File Locations by Tool Type

### Editor Plugins
```
addons/[plugin_name]/          # Plugin root
├── plugin.cfg                 # Required metadata
├── plugin.gd                  # Main plugin script
├── scenes/                    # UI scenes
├── scripts/                   # GDScript files
├── resources/                 # Custom resources
└── icons/                     # Plugin icons
```

### Standalone Tools (Same Project)
```
tools/[tool_name]/             # Tool root
├── [tool_name].tscn           # Main scene
├── [tool_name].gd             # Main script
└── components/                # Supporting scripts
```

### CLI Tools
```
tools/[tool_name]/             # Tool root
├── [tool_name].gd             # Main script (run with godot --script)
└── lib/                       # Supporting modules
```

---

## Common Godot Editor APIs

### EditorInterface

```gdscript
# Get editor components
var editor_settings = EditorInterface.get_editor_settings()
var filesystem = EditorInterface.get_resource_filesystem()
var selection = EditorInterface.get_selection()

# Open files/scenes
EditorInterface.edit_resource(resource)
EditorInterface.open_scene_from_path("res://path/to/scene.tscn")

# Editor theme for icons
var icon = EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
```

### Resource Management

```gdscript
# Scan for resources
func find_all_resources(type: String, directory: String) -> Array:
    var resources = []
    var dir = DirAccess.open(directory)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var res = load(directory + "/" + file_name)
                if res is type:
                    resources.append(res)
            file_name = dir.get_next()
    return resources
```

### File Operations

```gdscript
# Save custom format
func save_data(path: String, data: Dictionary) -> void:
    var file = FileAccess.open(path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()

# Load custom format
func load_data(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file = FileAccess.open(path, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    return data if data else {}
```

---

## Implementation Checklist

Before marking a feature complete:

- [ ] Feature matches spec requirements
- [ ] Feature matches roadmap description
- [ ] Code follows @tool pattern for editor scripts
- [ ] Scenes are properly structured
- [ ] Signals are connected and working
- [ ] Undo/redo works (if applicable)
- [ ] Save/load works (if applicable)
- [ ] No console errors
- [ ] Tested in editor

---

## Example Invocations

User: "Implement the visual node canvas from the Dialogue Tree Editor roadmap"
User: "Build the MVP for the balance dashboard"
User: "Start implementing the dialogue tree editor"
User: "Implement the save/load feature"
User: "What's the next feature to implement?"

---

## Workflow Summary

1. User requests feature implementation
2. Read tool spec and roadmap
3. Identify feature and dependencies
4. Set up project structure (if first feature)
5. Implement the feature
6. Test against success criteria
7. Update roadmap progress
8. Report completion and any issues

---

## Integration with Other Skills

### With `tool-spec-generator`
- Spec defines WHAT features do
- Implementer builds them

### With `tool-roadmap-planner`
- Roadmap defines feature order and scope
- Implementer follows the roadmap
- Updates roadmap with progress

### With `systems-bible-updater`
- Document complex implementations in Systems Bible
- Cross-reference architecture decisions

### With `gdscript-quality-checker`
- Run quality checks on implemented code
- Ensure consistent code style

---

This skill bridges the gap between planning (specs, roadmaps) and working code, handling the Godot-specific details of building editor plugins and development tools.
