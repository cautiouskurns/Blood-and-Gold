# Dialogue Tree Editor - User Guide

**Version:** 1.0
**For:** Godot 4.x
**Last Updated:** 2026-01-13

---

## Table of Contents

1. [Quick Start Guide](#quick-start-guide)
2. [Interface Overview](#interface-overview)
3. [Node Types Reference](#node-types-reference)
4. [Creating Dialogue Trees](#creating-dialogue-trees)
5. [Keyboard Shortcuts](#keyboard-shortcuts)
6. [Testing Dialogue](#testing-dialogue)
7. [Validation & Error Handling](#validation--error-handling)
8. [Export Format](#export-format)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## Quick Start Guide

### Getting Started in 5 Minutes

1. **Enable the Plugin**
   - Go to `Project > Project Settings > Plugins`
   - Find "Dialogue Tree Editor" and enable it
   - A "Dialogue" tab appears in the main editor toolbar

2. **Create Your First Dialogue**
   - Click the "Dialogue" tab to open the editor
   - Click "New" or press `Ctrl+N`
   - Right-click on the canvas and select "Add Start Node"
   - Right-click again and select "Add Speaker Node"
   - Drag from the Start node's output (right side) to the Speaker node's input (left side)

3. **Add Dialogue Content**
   - Select the Speaker node
   - Choose a speaker from the dropdown
   - Type your dialogue text in the text field

4. **Add Player Choices**
   - Add a Choice node for each player response option
   - Connect the Speaker node to multiple Choice nodes
   - Add another Speaker node after each choice for NPC responses

5. **End the Conversation**
   - Add an End node at the end of each dialogue path
   - Connect the last Speaker/Choice nodes to End nodes

6. **Save and Export**
   - Press `Ctrl+S` to save as `.dtree` file
   - Press `Ctrl+E` to export as `.json` for game use

---

## Interface Overview

```
+------------------------------------------------------------------+
|  [New] [Open] [Save] | [Export JSON] | [Search...] | [Test] [Help]|
+----------+-----------------------------------------------------------+
|          |                                                          |
| NODE     |                    CANVAS AREA                           |
| PALETTE  |                                                          |
|          |   +--------+      +----------+      +-------+           |
| [Start]  |   | Start  |----->| Speaker  |----->| End   |           |
| [Speaker]|   +--------+      +----------+      +-------+           |
| [Choice] |                                                          |
| [Branch] |                                                          |
| [End]    |                                                          |
| -------- |                                                          |
| [Skill]  |                                                          |
| [Flag]   |                                                          |
| [Quest]  |                                                          |
| [etc...] |                                                          |
|          +----------------------------------------------------------+
|          | dialogue_id: my_dialogue | Nodes: 3 | Zoom: 100%        |
+----------+----------------------------------------------------------+
```

### Main Components

| Component | Description |
|-----------|-------------|
| **Toolbar** | File operations, export, search, testing, and help |
| **Node Palette** | Drag-and-drop node types onto the canvas |
| **Canvas** | Visual workspace for building dialogue trees |
| **Status Bar** | Shows dialogue ID, node count, and zoom level |
| **Property Panel** | Slides out when a node is selected for detailed editing |

### Canvas Controls

| Action | Control |
|--------|---------|
| Pan | Middle mouse button drag, or right-click drag |
| Zoom | Scroll wheel |
| Select | Left-click on node |
| Multi-select | Ctrl+click or drag selection box |
| Connect | Drag from output slot to input slot |
| Delete connection | Right-click on connection line |
| Context menu | Right-click on empty canvas area |

---

## Node Types Reference

### Core Nodes (MVP)

#### Start Node
- **Color:** Green
- **Purpose:** Entry point for the dialogue
- **Inputs:** None
- **Outputs:** 1 (flow)
- **Fields:** None
- **Rules:** Every dialogue must have exactly one Start node

#### Speaker Node
- **Color:** Varies by speaker (see Speaker Colors)
- **Purpose:** NPC dialogue line
- **Inputs:** 1 (flow)
- **Outputs:** 1 (flow)
- **Fields:**
  - Speaker dropdown (NPC, Merchant, Guard, etc.)
  - Dialogue text (max 500 characters)
  - Portrait path (optional)
- **Notes:** Text is displayed to the player during gameplay

#### Choice Node
- **Color:** Blue (player color)
- **Purpose:** Player dialogue option
- **Inputs:** 1 (flow)
- **Outputs:** 1 (flow)
- **Fields:**
  - Choice text (what the player sees as an option)
- **Notes:** Multiple choices can connect from a single Speaker node

#### Branch Node
- **Color:** Yellow/Orange
- **Purpose:** Conditional branching based on game state
- **Inputs:** 1 (flow)
- **Outputs:** 2 (True/False)
- **Fields:**
  - Condition key (variable name)
  - Operator (==, !=, >, <, >=, <=)
  - Value (comparison value)
- **Notes:** Routes dialogue based on game flags or variables

#### End Node
- **Color:** Red
- **Purpose:** Terminates dialogue
- **Inputs:** 1 (flow)
- **Outputs:** None
- **Fields:**
  - End type dropdown:
    - `normal` - Standard conversation end
    - `combat` - Triggers combat after dialogue
    - `trade` - Opens trade interface
    - `exit` - Exits area/scene
- **Notes:** Every dialogue path should end with an End node

### Advanced Nodes (Phase 2)

#### Skill Check Node
- **Color:** Purple
- **Purpose:** Test player skill against difficulty
- **Inputs:** 1 (flow)
- **Outputs:** 2 (Success/Fail)
- **Fields:**
  - Skill dropdown (persuasion, intimidation, deception, etc.)
  - DC (Difficulty Class) spinner (1-30)
- **Notes:** Game rolls player skill vs DC; dialogue branches on result

#### Flag Check Node
- **Color:** Cyan
- **Purpose:** Check a game flag/variable value
- **Inputs:** 1 (flow)
- **Outputs:** 2 (True/False)
- **Fields:**
  - Flag name (string identifier)
  - Operator (==, !=, >, <, >=, <=)
  - Value (expected value)
- **Notes:** Used for quest states, world flags, etc.

#### Flag Set Node
- **Color:** Cyan (darker)
- **Purpose:** Set a game flag/variable
- **Inputs:** 1 (flow)
- **Outputs:** 1 (flow)
- **Fields:**
  - Flag name (string identifier)
  - Value (value to set)
- **Notes:** Modifies game state during dialogue

#### Quest Node
- **Color:** Gold
- **Purpose:** Quest state manipulation
- **Inputs:** 1 (flow)
- **Outputs:** 1 (flow)
- **Fields:**
  - Quest ID (string identifier)
  - Action dropdown:
    - `start` - Begin quest
    - `complete` - Mark quest complete
    - `fail` - Mark quest failed
    - `update` - Update quest stage
  - Stage (optional, for update action)
- **Notes:** Integrates with quest system

#### Reputation Node
- **Color:** Magenta
- **Purpose:** Modify faction reputation
- **Inputs:** 1 (flow)
- **Outputs:** 1 (flow)
- **Fields:**
  - Faction dropdown (or custom)
  - Amount spinner (+/- reputation change)
- **Notes:** Affects player standing with factions

#### Item Node
- **Color:** Brown/Tan
- **Purpose:** Give, take, or check items
- **Inputs:** 1 (flow)
- **Outputs:** 1 or 2 (depends on action)
- **Fields:**
  - Action dropdown:
    - `give` - Give item to player (1 output)
    - `take` - Remove item from player (1 output)
    - `check` - Check if player has item (2 outputs: Has/Doesn't Have)
  - Item ID (string identifier)
  - Quantity spinner
- **Notes:** Integrates with inventory system

### Speaker Colors

| Speaker | Color |
|---------|-------|
| Player | Blue (#4A90D9) |
| NPC | Gray (#808080) |
| Merchant | Gold (#D4A84B) |
| Guard | Steel Blue (#4682B4) |
| Noble | Purple (#9370DB) |
| Enemy | Red (#CD5C5C) |
| Narrator | White (#CCCCCC) |
| Custom | Configurable |

---

## Creating Dialogue Trees

### Basic Linear Dialogue

```
[Start] --> [Speaker: "Hello, traveler."] --> [Speaker: "Safe travels."] --> [End]
```

### Branching Choices

```
[Start] --> [Speaker: "What brings you here?"]
                    |
         +----------+-----------+
         |          |           |
    [Choice:   [Choice:    [Choice:
     Trade]    Quest]      Leave]
         |          |           |
    [Speaker]  [Speaker]   [End]
```

### Conditional Branch

```
[Start] --> [Branch: has_key == true]
                    |
            +-------+-------+
            |               |
      (True)|         (False)|
    [Speaker:         [Speaker:
     "Welcome"]        "Need key"]
            |               |
         [End]           [End]
```

### Skill Check Example

```
[Start] --> [Speaker: "Guards! Halt!"]
                    |
            [Skill Check:
             Persuasion DC 15]
                    |
            +-------+-------+
            |               |
      (Pass)|         (Fail)|
    [Speaker:         [Speaker:
     "Move along"]     "Come with us"]
            |               |
         [End]        [End: combat]
```

---

## Keyboard Shortcuts

### File Operations

| Shortcut | Action |
|----------|--------|
| `Ctrl+N` | New dialogue |
| `Ctrl+O` | Open dialogue |
| `Ctrl+S` | Save dialogue |
| `Ctrl+Shift+S` | Save As |
| `Ctrl+E` | Export to JSON |

### Edit Operations

| Shortcut | Action |
|----------|--------|
| `Ctrl+Z` | Undo |
| `Ctrl+Shift+Z` | Redo |
| `Ctrl+Y` | Redo (alternative) |
| `Delete` | Delete selected nodes |
| `Ctrl+D` | Duplicate selected nodes |
| `Ctrl+A` | Select all nodes |
| `Escape` | Deselect all |

### Quick Add Nodes

| Shortcut | Action |
|----------|--------|
| `1` | Add Start node |
| `2` | Add Speaker node |
| `3` | Add Choice node |
| `4` | Add Branch node |
| `5` | Add End node |

### Navigation & Testing

| Shortcut | Action |
|----------|--------|
| `F1` | Show help dialog |
| `F3` | Find next search result |
| `Shift+F3` | Find previous search result |
| `F5` | Toggle test mode |

---

## Testing Dialogue

### Starting a Test

1. Click "Test (F5)" or press `F5`
2. Test panel appears on the right side
3. Dialogue starts from the Start node

### Test Panel Features

| Feature | Description |
|---------|-------------|
| **Speaker/Text Display** | Shows current dialogue line |
| **Choice Buttons** | Click to make player choices |
| **State Viewer** | Shows simulated flags, quests, reputation |
| **Back Button** | Undo last choice |
| **Restart Button** | Start over from beginning |
| **Jump to Node** | Skip to any node for testing |
| **Skill Check Toggle** | Force pass/fail for testing |
| **Coverage Tracking** | Shows which nodes have been visited |

### Simulated State

During testing, the following are tracked but not actually applied:
- Flags set/changed
- Quest states
- Reputation changes
- Items given/taken

This allows full testing without affecting actual game state.

---

## Validation & Error Handling

### Automatic Validation

Click "Validate" to check for issues:

| Issue Type | Severity | Description |
|------------|----------|-------------|
| Missing Start | Error | No Start node found |
| Multiple Starts | Error | More than one Start node |
| Dead End | Error/Warning | Non-End node with no outgoing connections |
| Orphan Node | Warning | Node with no incoming connections |
| Unreachable | Warning | Node not connected to Start |
| Empty Field | Warning | Required field is empty |
| Circular Reference | Warning | Cycle detected in node connections |

### Validation Panel

- Click on any issue to jump to the problem node
- Warning icons appear on nodes with issues
- Errors block export (warnings don't)

### Error Notifications

Toast notifications appear for:
- File load errors
- Invalid file formats
- Missing referenced files (portraits)
- Export errors

---

## Export Format

### File Locations

| File Type | Location | Purpose |
|-----------|----------|---------|
| `.dtree` | `res://data/dialogue/` | Editor save files |
| `.json` | `res://data/dialogue/exported/` | Game runtime files |

### Export JSON Structure

```json
{
  "dialogue_id": "merchant_greeting",
  "version": 1,
  "start_node": "Start_1",
  "nodes": {
    "Start_1": {
      "type": "Start",
      "next": ["Speaker_2"]
    },
    "Speaker_2": {
      "type": "Speaker",
      "speaker": "Merchant",
      "text": "Welcome to my shop!",
      "portrait": "res://assets/portraits/merchant.png",
      "next": ["Choice_3", "Choice_4"]
    },
    "Choice_3": {
      "type": "Choice",
      "text": "Show me your wares.",
      "next": ["End_5"]
    },
    "Choice_4": {
      "type": "Choice",
      "text": "Never mind.",
      "next": ["End_6"]
    },
    "End_5": {
      "type": "End",
      "end_type": "trade"
    },
    "End_6": {
      "type": "End",
      "end_type": "normal"
    }
  }
}
```

### Node Type Export Fields

#### Start Node
```json
{
  "type": "Start",
  "next": ["node_id"]
}
```

#### Speaker Node
```json
{
  "type": "Speaker",
  "speaker": "string",
  "text": "string",
  "portrait": "res://path (optional)",
  "next": ["node_id", ...]
}
```

#### Choice Node
```json
{
  "type": "Choice",
  "text": "string",
  "next": ["node_id"]
}
```

#### Branch Node
```json
{
  "type": "Branch",
  "condition_key": "string",
  "operator": "==|!=|>|<|>=|<=",
  "value": "any",
  "next_true": "node_id",
  "next_false": "node_id"
}
```

#### End Node
```json
{
  "type": "End",
  "end_type": "normal|combat|trade|exit"
}
```

#### Skill Check Node
```json
{
  "type": "SkillCheck",
  "skill": "string",
  "dc": number,
  "next_success": "node_id",
  "next_fail": "node_id"
}
```

#### Flag Check Node
```json
{
  "type": "FlagCheck",
  "flag_name": "string",
  "operator": "==|!=|>|<|>=|<=",
  "value": "any",
  "next_true": "node_id",
  "next_false": "node_id"
}
```

#### Flag Set Node
```json
{
  "type": "FlagSet",
  "flag_name": "string",
  "value": "any",
  "next": ["node_id"]
}
```

#### Quest Node
```json
{
  "type": "Quest",
  "quest_id": "string",
  "action": "start|complete|fail|update",
  "stage": "string (optional)",
  "next": ["node_id"]
}
```

#### Reputation Node
```json
{
  "type": "Reputation",
  "faction": "string",
  "amount": number,
  "next": ["node_id"]
}
```

#### Item Node
```json
{
  "type": "Item",
  "action": "give|take|check",
  "item_id": "string",
  "quantity": number,
  "next": ["node_id"],
  "next_has": "node_id (for check)",
  "next_missing": "node_id (for check)"
}
```

### Game Integration Example

```gdscript
# Loading dialogue in your game
func start_dialogue(dialogue_id: String) -> void:
    var path = "res://data/dialogue/exported/%s.json" % dialogue_id
    var file = FileAccess.open(path, FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())

    current_dialogue = json
    current_node = json.start_node
    _show_node(current_node)

func _show_node(node_id: String) -> void:
    var node = current_dialogue.nodes[node_id]

    match node.type:
        "Speaker":
            dialogue_ui.show_text(node.speaker, node.text)
            # Handle choices if multiple next
        "Choice":
            # This is typically handled as part of speaker display
            pass
        "End":
            _end_dialogue(node.end_type)
        "SkillCheck":
            var result = _roll_skill_check(node.skill, node.dc)
            var next = node.next_success if result else node.next_fail
            _show_node(next)
        # ... handle other types
```

---

## Troubleshooting

### Common Issues

#### "No Start node found"
**Problem:** Dialogue won't export or test
**Solution:** Add exactly one Start node and connect it to the rest of your dialogue

#### "Dead end detected"
**Problem:** Dialogue path has no ending
**Solution:** Connect the flagged node to an End node or another dialogue node

#### "Orphan node detected"
**Problem:** Node is not connected to anything
**Solution:** Either connect the node to the dialogue flow or delete it

#### Portrait not showing
**Problem:** Portrait appears as placeholder
**Solution:**
1. Check the file path is correct
2. Ensure the image file exists at that path
3. Use supported formats: PNG, JPG, WebP

#### Large dialogue trees are slow
**Problem:** Canvas becomes laggy with many nodes
**Solution:**
1. Minimap is auto-disabled for 1000+ nodes
2. Consider splitting very large dialogues
3. Use search to navigate instead of scrolling

#### Circular reference warning
**Problem:** Nodes connect in a loop
**Solution:** This may be intentional (repeating dialogue options). If not, check your connections for unintended loops.

#### File won't load
**Problem:** Error loading .dtree file
**Solution:**
1. File may be corrupted - check for backup
2. Check file permissions
3. Ensure file is valid JSON format

### Recovery

#### Recovering from crash
Auto-save creates recovery files. On next launch:
1. A recovery dialog appears
2. Choose "Recover" to restore work
3. Choose "Discard" to start fresh

#### Finding auto-save files
Location: `user://dialogue_editor_autosave/`

---

## Best Practices

### Organization

1. **Use consistent naming**
   - dialogue_id: `location_npc_topic` (e.g., `tavern_barkeep_rumors`)
   - Keep names lowercase with underscores

2. **Keep dialogues focused**
   - One topic per dialogue tree
   - Split large conversations into multiple trees

3. **Comment complex branches**
   - Use speaker text to add designer notes
   - Mark test/debug paths clearly

### Structure

1. **Single entry point**
   - Always one Start node
   - Never multiple entry points

2. **Clear endings**
   - Every path leads to an End node
   - Use appropriate end types

3. **Avoid deep nesting**
   - Flatten when possible
   - Use flags for complex state tracking

### Testing

1. **Test all paths**
   - Use coverage tracking to ensure all nodes visited
   - Test both success and failure for skill checks

2. **Validate before export**
   - Fix all errors
   - Review warnings

3. **Test in-game**
   - Editor testing simulates; verify in actual game
   - Check portraits, sounds, and effects

### Performance

1. **Keep node count reasonable**
   - Under 500 nodes per tree is optimal
   - Very large trees (1000+) may impact editor performance

2. **Use efficient branching**
   - Combine related checks
   - Avoid redundant flag checks

---

## Appendix: File Format Reference

### .dtree File Structure (Editor Format)

```json
{
  "version": 1,
  "dialogue_id": "string",
  "metadata": {
    "created": "ISO date",
    "modified": "ISO date",
    "author": "string"
  },
  "canvas": {
    "scroll_offset": {"x": 0, "y": 0},
    "zoom": 1.0
  },
  "nodes": [
    {
      "id": "node_id",
      "type": "NodeType",
      "position_x": 100,
      "position_y": 200,
      // type-specific fields...
    }
  ],
  "connections": [
    {
      "from_node": "node_id",
      "from_port": 0,
      "to_node": "node_id",
      "to_port": 0
    }
  ]
}
```

### Version History

| Version | Changes |
|---------|---------|
| 1 | Initial format |

---

**Need more help?** Press `F1` in the editor for the keyboard shortcuts reference, or visit the project documentation.
