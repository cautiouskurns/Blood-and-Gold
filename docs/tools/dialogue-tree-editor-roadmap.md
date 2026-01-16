# Tool Roadmap: Dialogue Tree Editor

**Spec:** `docs/tools/dialogue-tree-editor-spec.md`
**Created:** 2026-01-12
**Implementer:** Use `tool-feature-implementer` skill to build features

---

## Overview

```mermaid
graph LR
    P1["Phase 1: MVP<br/>Core editor working"]
    P2["Phase 2: Workflow<br/>Efficient authoring"]
    P3["Phase 3: Polish<br/>Production ready"]

    P1 --> P2 --> P3

    style P1 fill:#e53e3e,stroke:#c53030,color:#fff
    style P2 fill:#d69e2e,stroke:#b7791f,color:#fff
    style P3 fill:#38a169,stroke:#2f855a,color:#fff
```

**Goal:** Visual node editor for creating branching dialogue with 11,000+ lines across multiple games.

---

## Phase 1: MVP (Minimum Viable Tool)

**Goal:** Create, edit, save, and export basic dialogue trees visually.

**Exit Criteria:** Writer can create a simple dialogue tree with speaker lines, player choices, and export to JSON for game use.

---

### Feature 1.1: Plugin Setup & Main Screen Registration

**Description:** Create the editor plugin structure and register it as a main screen editor tab (like 2D, 3D, Script).

**Implementation Tasks:**
- [x] Create `addons/dialogue_editor/` directory structure
- [x] Create `plugin.cfg` with metadata
- [x] Create `plugin.gd` extending EditorPlugin
- [x] Implement `_has_main_screen()` returning true
- [x] Implement `_get_plugin_name()` returning "Dialogue"
- [x] Implement `_get_plugin_icon()` with appropriate icon
- [x] Create empty `main_panel.tscn` as placeholder
- [x] Register main panel in `_enter_tree()`
- [x] Clean up in `_exit_tree()`

**Files to Create/Modify:**
- `addons/dialogue_editor/plugin.cfg` ✓
- `addons/dialogue_editor/plugin.gd` ✓
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓
- `addons/dialogue_editor/icons/` (using built-in icon)

**Success Criteria:**
- [x] Plugin appears in Project Settings → Plugins
- [x] "Dialogue" tab appears in main editor toolbar when enabled
- [x] Clicking tab shows empty panel
- [x] No errors on enable/disable

---

### Feature 1.2: Visual Node Canvas

**Description:** GraphEdit-based canvas for placing and connecting dialogue nodes with pan/zoom support.

**Dependencies:** Feature 1.1

**Implementation Tasks:**
- [x] Replace main_panel content with GraphEdit node
- [x] Create `dialogue_canvas.gd` script for GraphEdit
- [x] Configure GraphEdit properties:
  - [x] Enable grid and snapping (20px)
  - [x] Enable minimap (bottom-right)
  - [x] Set zoom limits (25% - 200%)
- [x] Implement `connection_request` signal handler
- [x] Implement `disconnection_request` signal handler
- [x] Implement pan with middle mouse button
- [x] Implement zoom with scroll wheel
- [x] Add right-click context menu (placeholder)

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Canvas displays with visible grid
- [x] Can pan with middle mouse button
- [x] Can zoom with scroll wheel (25%-200%)
- [x] Minimap visible in corner
- [x] Snapping works when moving nodes

---

### Feature 1.3: Node Palette & Node Creation

**Description:** Side panel with draggable node types that can be added to the canvas.

**Dependencies:** Feature 1.2

**Implementation Tasks:**
- [x] Create `node_palette.tscn` as VBoxContainer
- [x] Add palette to left side of main panel (HSplitContainer)
- [x] Create draggable buttons for each MVP node type:
  - [x] Start node button
  - [x] Speaker node button
  - [x] Choice node button
  - [x] Branch node button
  - [x] End node button
- [x] Implement drag-and-drop from palette to canvas
- [x] Implement right-click canvas → Add Node submenu
- [x] Generate unique node IDs on creation

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓
- `addons/dialogue_editor/scripts/node_palette.gd` ✓
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓

**Success Criteria:**
- [x] Palette visible on left side
- [x] Can drag node type onto canvas to create
- [x] Can right-click canvas to add nodes
- [x] Each node gets unique ID
- [x] Separator visible between MVP and Phase 2 nodes

---

### Feature 1.4: Core Node Types (GraphNodes)

**Description:** Implement the 5 MVP node types as GraphNode scenes with appropriate inputs/outputs.

**Dependencies:** Feature 1.3

**Implementation Tasks:**
- [x] Create base `dialogue_node.gd` with common functionality
- [x] Create `start_node.tscn` and `start_node.gd`:
  - [x] No input slot
  - [x] One output slot
  - [x] Green color styling
- [x] Create `speaker_node.tscn` and `speaker_node.gd`:
  - [x] One input slot
  - [x] Multiple output slots (dynamic)
  - [x] Speaker dropdown field
  - [x] Multi-line text field (500 char limit)
  - [x] Portrait field (optional)
  - [x] Color by speaker
- [x] Create `choice_node.tscn` and `choice_node.gd`:
  - [x] One input slot
  - [x] One output slot
  - [x] Text field for player response
  - [x] Blue color (player)
- [x] Create `branch_node.tscn` and `branch_node.gd`:
  - [x] One input slot
  - [x] Multiple output slots (per condition)
  - [x] Condition type dropdown
  - [x] Condition value field
  - [x] Yellow/orange color
- [x] Create `end_node.tscn` and `end_node.gd`:
  - [x] One input slot
  - [x] No output slot
  - [x] End type dropdown (normal, combat, trade, exit)
  - [x] Red color styling

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/nodes/dialogue_node.gd` (base) ✓
- `addons/dialogue_editor/scripts/nodes/start_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/choice_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/branch_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/end_node.gd` ✓
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (updated to use new nodes)

**Success Criteria:**
- [x] All 5 node types can be created
- [x] Each node has correct input/output slots
- [x] Speaker node text field has 500 char limit
- [x] Speaker dropdown shows character options
- [x] Nodes are color-coded by type
- [x] Can edit all node properties inline

---

### Feature 1.5: Node Connections

**Description:** Visual connection system allowing nodes to be linked with arrows.

**Dependencies:** Feature 1.4

**Implementation Tasks:**
- [x] Configure slot types and colors in each node
- [x] Implement connection validation (prevent invalid connections)
- [x] Style connection lines (bezier curves)
- [x] Color connections based on source node type
- [x] Implement connection deletion (right-click or drag away)
- [x] Prevent multiple connections to same input slot
- [x] Allow multiple connections from same output slot (for choices)
- [x] Update node data when connections change

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓
- `addons/dialogue_editor/scripts/nodes/dialogue_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/start_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/choice_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/branch_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/end_node.gd` ✓

**Success Criteria:**
- [x] Can drag from output to input to connect
- [x] Connection lines are visible and styled
- [x] Cannot connect output to output
- [x] Cannot connect to same node
- [x] Can delete connections
- [x] Speaker can connect to multiple choices

---

### Feature 1.6: Save/Load System (.dtree)

**Description:** Save dialogue trees to custom .dtree format and load them back.

**Dependencies:** Feature 1.5

**Implementation Tasks:**
- [x] Define .dtree JSON structure (per spec)
- [x] Create `dialogue_tree_data.gd` Resource class
- [x] Implement `serialize_tree()` → Dictionary
- [x] Implement `deserialize_tree(data)` → rebuild canvas
- [x] Serialize node positions and zoom/offset
- [x] Add File menu to toolbar:
  - [x] New (Ctrl+N)
  - [x] Open (Ctrl+O)
  - [x] Save (Ctrl+S)
  - [x] Save As (Ctrl+Shift+S)
- [x] Implement file dialogs for open/save
- [x] Track "dirty" state (unsaved changes indicator)
- [x] Prompt to save on close if dirty
- [x] Store canvas zoom and scroll position

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` ✓
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Can save tree to .dtree file
- [x] Can load .dtree file and recreate tree exactly
- [x] Canvas position/zoom restored on load
- [x] Unsaved changes show indicator (*)
- [x] Prompted to save before closing
- [x] Keyboard shortcuts work

---

### Feature 1.7: JSON Export

**Description:** Export dialogue tree to game-readable JSON format.

**Dependencies:** Feature 1.6

**Implementation Tasks:**
- [x] Define export JSON structure (per spec - runtime format)
- [x] Create `dialogue_exporter.gd` utility
- [x] Transform internal format to game format:
  - [x] Flatten node structure
  - [x] Convert connections to "next" arrays
  - [x] Strip editor-only data (positions)
  - [x] Identify start node
- [x] Add Export menu item (Ctrl+E)
- [x] Add Export button to toolbar
- [x] Default export location: `res://data/dialogue/`
- [x] Auto-name export file from dialogue_id

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Export produces valid JSON
- [x] Exported format matches spec exactly
- [x] Start node correctly identified
- [x] All connections converted to "next" references
- [x] No editor data in export (positions, etc.)
- [x] Game can load and parse exported JSON

---

### Feature 1.8: Undo/Redo System

**Description:** Full undo/redo support for all canvas operations.

**Dependencies:** Feature 1.5

**Implementation Tasks:**
- [x] Integrate Godot's UndoRedo class
- [x] Wrap node creation in undo action
- [x] Wrap node deletion in undo action
- [x] Wrap connection creation in undo action
- [x] Wrap connection deletion in undo action
- [x] Wrap node property changes in undo action
- [x] Wrap node movement in undo action
- [x] Add Edit menu with Undo/Redo (keyboard shortcuts implemented)
- [x] Implement Ctrl+Z (undo) and Ctrl+Shift+Z (redo)
- [x] Show action name in Edit menu (via get_current_action_name API)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Can undo node creation
- [x] Can undo node deletion
- [x] Can undo connection changes
- [x] Can undo property edits
- [x] Can redo all above
- [x] Undo history survives node selection changes
- [x] Keyboard shortcuts work

---

### Phase 1 Technical Setup ✅

- [x] Create `addons/dialogue_editor/` directory structure
- [x] Create `plugin.cfg` with metadata
- [x] Create `plugin.gd` EditorPlugin base
- [x] Enable plugin in Project Settings
- [x] Create `res://data/dialogue/` directory for exports

---

## Phase 2: Workflow Improvements

**Goal:** Make dialogue authoring efficient for daily use.

**Prerequisites:** Phase 1 complete

---

### Feature 2.1: Advanced Node Types ✅

**Description:** Add the 6 Phase 2 node types for game logic integration.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [x] Create `skill_check_node.tscn` and script:
  - [x] Skill dropdown (persuasion, intimidation, etc.)
  - [x] DC (difficulty class) spinner
  - [x] Two outputs: success, fail
- [x] Create `flag_check_node.tscn` and script:
  - [x] Flag name field (with autocomplete if registry exists)
  - [x] Operator dropdown (==, !=, >, <)
  - [x] Value field
  - [x] Two outputs: true, false
- [x] Create `flag_set_node.tscn` and script:
  - [x] Flag name field
  - [x] Value field
  - [x] One output
- [x] Create `quest_node.tscn` and script:
  - [x] Quest ID field (with autocomplete if registry exists)
  - [x] Action dropdown (start, complete, fail, update)
  - [x] One output
- [x] Create `reputation_node.tscn` and script:
  - [x] Faction dropdown
  - [x] Amount spinner (+/-)
  - [x] One output
- [x] Create `item_node.tscn` and script:
  - [x] Action dropdown (give, take, check)
  - [x] Item ID field
  - [x] Quantity spinner
  - [x] Two outputs for "check" action

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/nodes/skill_check_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/flag_check_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/flag_set_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/quest_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/reputation_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/item_node.gd` ✓
- `addons/dialogue_editor/scripts/node_palette.gd` ✓ (add to palette)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (node creation support)
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` ✓ (export support)

**Success Criteria:**
- [x] All 6 new node types available in palette
- [x] Each node has correct inputs/outputs
- [x] Export includes new node types correctly
- [x] Nodes serialize/deserialize properly

---

### Feature 2.2: In-Editor Dialogue Testing ✅

**Description:** Play through dialogue in the editor without running the game.

**Dependencies:** Feature 2.1

**Implementation Tasks:**
- [x] Create `test_panel.tscn` dialog/popup
- [x] Display current speaker and text
- [x] Show portrait if available
- [x] Display choice buttons for player responses
- [x] Highlight current node on canvas
- [x] Track and display simulated state:
  - [x] Flags set during test
  - [x] Reputation changes
  - [x] Items given/taken
  - [x] Quests started/completed
- [x] Add "Back" button (undo last choice)
- [x] Add "Restart" button
- [x] Add "Skip to Node" dropdown
- [x] Simulate skill checks (pass/fail toggle)
- [x] Add F5 shortcut to start test
- [x] Track which nodes visited (coverage)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/test_panel.gd` ✓
- `addons/dialogue_editor/scripts/dialogue_runner.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓

**Success Criteria:**
- [x] Can play through dialogue choosing options
- [x] Current node highlighted on canvas
- [x] Can see simulated flag/quest changes
- [x] Can go back to previous choice
- [x] Can restart from beginning
- [x] Can jump to any node
- [x] Coverage tracking shows visited nodes

---

### Feature 2.3: Search & Filter ✅

**Description:** Find nodes by speaker, text content, or ID.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [x] Add search bar to toolbar
- [x] Implement search by:
  - [x] Node ID
  - [x] Speaker name
  - [x] Dialogue text content
  - [x] Node type
- [x] Highlight matching nodes on canvas
- [x] Add "Find Next" / "Find Previous" (F3 / Shift+F3)
- [x] Jump to and select found node
- [x] Show result count
- [x] Add filter dropdown to show only certain node types

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓
- `addons/dialogue_editor/scripts/search_manager.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Can search by text content
- [x] Can search by speaker
- [x] Matching nodes highlighted
- [x] Can cycle through results
- [x] Can filter canvas to show only certain types

---

### Feature 2.4: Validation System ✅

**Description:** Detect and report structural issues in dialogue trees.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [x] Create `dialogue_validator.gd`
- [x] Detect orphan nodes (no incoming connections except Start)
- [x] Detect dead ends (non-End nodes with no outgoing connections)
- [x] Detect missing Start node
- [x] Detect multiple Start nodes
- [x] Detect unreachable nodes (not connected to Start)
- [x] Detect empty text fields
- [x] Add "Validate" button to toolbar
- [x] Show validation results panel
- [x] Click result to jump to problem node
- [x] Show warning icons on invalid nodes
- [x] Validate before export (optional block)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_validator.gd` ✓
- `addons/dialogue_editor/scripts/validation_panel.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Detects orphan nodes
- [x] Detects dead ends
- [x] Detects missing/multiple start
- [x] Detects empty required fields
- [x] Can click to jump to problem
- [x] Warning icons on canvas
- [x] Option to validate before export

---

### Feature 2.5: Speaker Color Coding ✅

**Description:** Automatically color nodes based on speaker for visual clarity.

**Dependencies:** Feature 1.4

**Implementation Tasks:**
- [x] Define color palette per speaker (from spec)
- [x] Create speaker → color mapping (configurable)
- [x] Apply color to Speaker nodes based on speaker field
- [x] Apply player color to Choice nodes
- [x] Add color legend to palette or status bar
- [x] Allow custom speaker colors in settings
- [x] Update colors when speaker changes

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` ✓
- `addons/dialogue_editor/scripts/nodes/choice_node.gd` ✓
- `addons/dialogue_editor/scripts/speaker_colors.gd` ✓
- `addons/dialogue_editor/scripts/node_palette.gd` ✓ (color legend)

**Success Criteria:**
- [x] Speaker nodes colored by speaker
- [x] Choice nodes always blue (player)
- [x] Colors match spec palette
- [x] Color updates when speaker changes
- [x] Legend visible showing color meanings

---

### Feature 2.6: Auto-Save ✓

**Description:** Automatically save work to prevent data loss.

**Dependencies:** Feature 1.6

**Implementation Tasks:**
- [x] Implement auto-save timer (configurable, default 60s)
- [x] Save to temp file (not overwrite original)
- [x] Detect unsaved changes trigger
- [x] Add auto-save indicator to status bar
- [x] Recover from auto-save on crash
- [x] Add auto-save toggle in settings
- [x] Show "Recovered from auto-save" dialog if applicable

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/auto_save_manager.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Auto-saves every 60 seconds when dirty
- [x] Does not overwrite manual saves
- [x] Recovery works after crash
- [x] Can disable auto-save
- [x] Status bar shows last auto-save time

---

## Phase 3: Polish & Edge Cases ✅ COMPLETE

**Goal:** Production-ready tool that handles edge cases gracefully.

**Prerequisites:** Phase 2 complete, tool used in real workflows

---

### Feature 3.1: Property Panel ✅

**Description:** Dedicated slide-out panel for editing selected node properties.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [x] Create `property_panel.gd` as slide-out panel (programmatic UI)
- [x] Show when node selected, hide when deselected
- [x] Display all node properties with appropriate editors
- [x] Larger text area for dialogue (easier editing than inline)
- [x] Character counter for text fields
- [x] Portrait preview for Speaker nodes
- [x] Auto-apply changes (immediate update)
- [x] Animate slide in/out with tween

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/property_panel.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓

**Success Criteria:**
- [x] Panel slides out when node selected
- [x] All properties editable
- [x] Character counter visible
- [x] Portrait preview works
- [x] Changes apply to node

---

### Feature 3.2: Keyboard Shortcuts ✅

**Description:** Comprehensive keyboard shortcuts for power users.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [x] Implement all shortcuts from spec:
  - [x] Ctrl+N - New
  - [x] Ctrl+O - Open
  - [x] Ctrl+S - Save
  - [x] Ctrl+Shift+S - Save As
  - [x] Ctrl+E - Export
  - [x] Ctrl+Z - Undo
  - [x] Ctrl+Shift+Z - Redo
  - [x] F5 - Test dialogue
  - [x] Delete - Delete selected nodes
  - [x] Ctrl+D - Duplicate selected
  - [x] Ctrl+A - Select all
  - [x] Escape - Deselect all
  - [x] F3 - Find next
  - [x] 1-5 - Quick add node types
- [x] Add Help dialog with shortcut reference (F1 or Help button)
- [ ] Allow shortcut customization (future - backlog)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/main_panel.gd` ✓
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (selection/duplication methods)
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓ (Help button)

**Success Criteria:**
- [x] All listed shortcuts work
- [x] No conflicts with Godot shortcuts
- [x] Help dialog shows shortcut list

---

### Feature 3.3: Error Handling & Edge Cases ✅

**Description:** Graceful handling of errors and edge cases.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [x] Handle corrupted .dtree files (show error, don't crash)
- [x] Handle missing referenced files (portraits, audio)
- [x] Handle very long dialogue text (truncate display, not data)
- [x] Handle 500+ node trees (performance)
- [x] Handle circular references in Branch nodes
- [x] Empty tree handling (new file state)
- [x] Handle special characters in text
- [x] Handle node ID collisions on paste
- [x] Add error notification system

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/error_handler.gd` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓ (notifications, file loading validation)
- `addons/dialogue_editor/scripts/dialogue_validator.gd` ✓ (circular reference detection)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (ID collision handling, performance)
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` ✓ (portrait placeholders)

**Success Criteria:**
- [x] Corrupted files show error message
- [x] Missing files show placeholder
- [x] 500+ nodes perform smoothly
- [x] No crashes from user input
- [x] Circular references detected

---

### Feature 3.4: Documentation & Help ✅

**Description:** In-editor help and usage documentation.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [x] Create `docs/tools/dialogue-tree-editor-guide.md`
- [x] Add Help menu with:
  - [x] Quick Start Guide
  - [x] Keyboard Shortcuts
  - [x] Node Type Reference
  - [x] Troubleshooting
- [x] Add tooltips to all buttons and fields
- [x] Add "What's This?" mode (click for help)
- [x] Document export format for game integration

**Files to Create/Modify:**
- `docs/tools/dialogue-tree-editor-guide.md` ✓
- `addons/dialogue_editor/scripts/main_panel.gd` ✓ (Help system, tooltips, What's This mode)
- `addons/dialogue_editor/scenes/main_panel.tscn` ✓ (What's This button)

**Success Criteria:**
- [x] Guide covers all features
- [x] All buttons have tooltips
- [x] Help accessible from editor
- [x] Export format documented

---

## Phase 4: Enhancement Proposals (from docs/features/Dialogue Tree Editor - Enhancement Propo.md)

**Goal:** Advanced features for complex dialogue authoring.

**Prerequisites:** Phase 3 complete

---

### Feature 4D.1: Visual Node Groups ✅

**Description:** Allow drawing colored boxes around node clusters with labels for visual organization.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [x] Create `node_group.gd` as a custom canvas element:
  - [x] Colored rectangle background (semi-transparent)
  - [x] Title label at top
  - [x] Resizable by dragging corners/edges
  - [x] Can be moved (drag title bar or Ctrl+click)
- [x] Add "Create Group from Selection" to context menu (when nodes selected)
- [x] Store groups in .dtree file:
  - [x] Group ID, name, color
  - [x] Position and size
  - [x] Contained node IDs (for selection purposes)
- [x] Groups render behind nodes (z-order via separate container)
- [x] Double-click group label to edit title
- [x] Integrate with undo/redo system

**Files Created/Modified:**
- `addons/dialogue_editor/scripts/groups/node_group.gd` ✓ (new)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (group rendering, interaction)
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` ✓ (serialization)

**Success Criteria:**
- [x] Can create group around selected nodes via context menu
- [x] Group has colored background and label
- [x] Can resize group by dragging handles
- [x] Can move group by dragging title bar
- [x] Groups save/load correctly in .dtree files
- [x] Can edit group title via double-click
- [x] Undo/redo works for all group operations

---

### Feature 4D.2: Group Operations ✅

**Description:** Enable operations on groups as a unit.

**Dependencies:** Feature 4D.1

**Implementation Tasks:**
- [x] Implement "Select All in Group" (click group background)
- [x] Implement "Move Group" (moves all contained nodes)
- [x] Implement "Delete Group" (removes group box, keeps nodes)
- [x] Add group color picker to context menu
- [x] Add group right-click context menu:
  - [x] Select Contents
  - [x] Rename Group...
  - [x] Change Color...
  - [x] Delete Group

**Files Modified:**
- `addons/dialogue_editor/scripts/groups/node_group.gd` ✓ (new signals)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✓ (group operations, context menu)

**Success Criteria:**
- [x] Clicking group background selects all contained nodes
- [x] Moving group moves all nodes inside
- [x] Can change group color via color picker
- [x] Can rename group via context menu
- [x] Deleting group leaves nodes intact

---

### Feature 4D.3: Subgraph Nodes (Future)

**Description:** Encapsulate node clusters into reusable subgraph nodes.

**Status:** Not started (future enhancement)

---

## Future Ideas (Backlog)

Ideas that might be valuable but aren't committed:

- **Localization Support** - Multiple languages per tree
- **Voice Line Preview** - Play audio clips in editor
- **AI Dialogue Generation** - Generate response options via AI
- **Minimap Improvements** - Clickable minimap navigation
- **Node Templates** - Save/load common node patterns
- **Diff/Merge Tool** - Compare two dialogue trees
- **Import from Yarn/Ink** - Convert from other formats
- **Collaborative Editing** - Real-time multi-user editing
- **Analytics Integration** - Track which paths players take
- **Portrait Preview** - Show character portraits inline

---

## Dependencies

| Dependency | Required By | Notes |
|------------|-------------|-------|
| GraphEdit/GraphNode | Feature 1.2+ | Built into Godot 4.x |
| Character Database | Feature 1.4 | For speaker dropdown (can hardcode initially) |
| Quest Registry | Feature 2.1 | For quest autocomplete (optional) |
| Flag Registry | Feature 2.1 | For flag autocomplete (optional) |

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| GraphEdit limitations | High | Test complex trees early; may need custom rendering |
| Performance with 500+ nodes | Medium | Profile early; implement culling if needed |
| Complex undo/redo | Medium | Use Godot's built-in UndoRedo; test thoroughly |
| Data format changes | High | Version the .dtree format; write migration scripts |
| Godot version updates | Low | Pin to Godot 4.x; test on updates |

---

## Progress Tracking

### Phase 1 Progress ✅ COMPLETE
- [x] Feature 1.1: Plugin Setup
- [x] Feature 1.2: Visual Node Canvas
- [x] Feature 1.3: Node Palette
- [x] Feature 1.4: Core Node Types
- [x] Feature 1.5: Node Connections
- [x] Feature 1.6: Save/Load System
- [x] Feature 1.7: JSON Export
- [x] Feature 1.8: Undo/Redo System

### Phase 2 Progress
- [x] Feature 2.1: Advanced Node Types ✅
- [x] Feature 2.2: In-Editor Testing ✅
- [x] Feature 2.3: Search & Filter ✅
- [x] Feature 2.4: Validation System ✅
- [x] Feature 2.5: Speaker Color Coding ✅
- [x] Feature 2.6: Auto-Save

### Phase 3 Progress ✅ COMPLETE
- [x] Feature 3.1: Property Panel ✅
- [x] Feature 3.2: Keyboard Shortcuts ✅
- [x] Feature 3.3: Error Handling ✅
- [x] Feature 3.4: Documentation ✅

### Phase 4 Progress (Enhancement Proposals)
- [x] Feature 4D.1: Visual Node Groups ✅
- [x] Feature 4D.2: Group Operations ✅

---

**Total Features:** 20 (8 MVP + 6 Workflow + 4 Polish + 2 Enhancement)

**To implement a feature, run:**
```
/tool-feature-implementer Feature X.X from Dialogue Tree Editor
```
