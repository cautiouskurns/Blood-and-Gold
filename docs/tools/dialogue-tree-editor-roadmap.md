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
- [ ] Replace main_panel content with GraphEdit node
- [ ] Create `dialogue_canvas.gd` script for GraphEdit
- [ ] Configure GraphEdit properties:
  - [ ] Enable grid and snapping (20px)
  - [ ] Enable minimap (bottom-right)
  - [ ] Set zoom limits (25% - 200%)
- [ ] Implement `connection_request` signal handler
- [ ] Implement `disconnection_request` signal handler
- [ ] Implement pan with middle mouse button
- [ ] Implement zoom with scroll wheel
- [ ] Add right-click context menu (placeholder)

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn`
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`

**Success Criteria:**
- [ ] Canvas displays with visible grid
- [ ] Can pan with middle mouse button
- [ ] Can zoom with scroll wheel (25%-200%)
- [ ] Minimap visible in corner
- [ ] Snapping works when moving nodes

---

### Feature 1.3: Node Palette & Node Creation

**Description:** Side panel with draggable node types that can be added to the canvas.

**Dependencies:** Feature 1.2

**Implementation Tasks:**
- [ ] Create `node_palette.tscn` as VBoxContainer
- [ ] Add palette to left side of main panel (HSplitContainer)
- [ ] Create draggable buttons for each MVP node type:
  - [ ] Start node button
  - [ ] Speaker node button
  - [ ] Choice node button
  - [ ] Branch node button
  - [ ] End node button
- [ ] Implement drag-and-drop from palette to canvas
- [ ] Implement right-click canvas → Add Node submenu
- [ ] Generate unique node IDs on creation

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn`
- `addons/dialogue_editor/scenes/node_palette.tscn`
- `addons/dialogue_editor/scripts/node_palette.gd`
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`

**Success Criteria:**
- [ ] Palette visible on left side
- [ ] Can drag node type onto canvas to create
- [ ] Can right-click canvas to add nodes
- [ ] Each node gets unique ID
- [ ] Separator visible between MVP and Phase 2 nodes

---

### Feature 1.4: Core Node Types (GraphNodes)

**Description:** Implement the 5 MVP node types as GraphNode scenes with appropriate inputs/outputs.

**Dependencies:** Feature 1.3

**Implementation Tasks:**
- [ ] Create base `dialogue_node.gd` with common functionality
- [ ] Create `start_node.tscn` and `start_node.gd`:
  - [ ] No input slot
  - [ ] One output slot
  - [ ] Green color styling
- [ ] Create `speaker_node.tscn` and `speaker_node.gd`:
  - [ ] One input slot
  - [ ] Multiple output slots (dynamic)
  - [ ] Speaker dropdown field
  - [ ] Multi-line text field (500 char limit)
  - [ ] Portrait field (optional)
  - [ ] Color by speaker
- [ ] Create `choice_node.tscn` and `choice_node.gd`:
  - [ ] One input slot
  - [ ] One output slot
  - [ ] Text field for player response
  - [ ] Blue color (player)
- [ ] Create `branch_node.tscn` and `branch_node.gd`:
  - [ ] One input slot
  - [ ] Multiple output slots (per condition)
  - [ ] Condition type dropdown
  - [ ] Condition value field
  - [ ] Yellow/orange color
- [ ] Create `end_node.tscn` and `end_node.gd`:
  - [ ] One input slot
  - [ ] No output slot
  - [ ] End type dropdown (normal, combat, trade, exit)
  - [ ] Red color styling

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/nodes/dialogue_node.gd` (base)
- `addons/dialogue_editor/scenes/nodes/start_node.tscn`
- `addons/dialogue_editor/scripts/nodes/start_node.gd`
- `addons/dialogue_editor/scenes/nodes/speaker_node.tscn`
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd`
- `addons/dialogue_editor/scenes/nodes/choice_node.tscn`
- `addons/dialogue_editor/scripts/nodes/choice_node.gd`
- `addons/dialogue_editor/scenes/nodes/branch_node.tscn`
- `addons/dialogue_editor/scripts/nodes/branch_node.gd`
- `addons/dialogue_editor/scenes/nodes/end_node.tscn`
- `addons/dialogue_editor/scripts/nodes/end_node.gd`

**Success Criteria:**
- [ ] All 5 node types can be created
- [ ] Each node has correct input/output slots
- [ ] Speaker node text field has 500 char limit
- [ ] Speaker dropdown shows character options
- [ ] Nodes are color-coded by type
- [ ] Can edit all node properties inline

---

### Feature 1.5: Node Connections

**Description:** Visual connection system allowing nodes to be linked with arrows.

**Dependencies:** Feature 1.4

**Implementation Tasks:**
- [ ] Configure slot types and colors in each node
- [ ] Implement connection validation (prevent invalid connections)
- [ ] Style connection lines (bezier curves)
- [ ] Color connections based on source node type
- [ ] Implement connection deletion (right-click or drag away)
- [ ] Prevent multiple connections to same input slot
- [ ] Allow multiple connections from same output slot (for choices)
- [ ] Update node data when connections change

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`
- `addons/dialogue_editor/scripts/nodes/dialogue_node.gd`

**Success Criteria:**
- [ ] Can drag from output to input to connect
- [ ] Connection lines are visible and styled
- [ ] Cannot connect output to output
- [ ] Cannot connect to same node
- [ ] Can delete connections
- [ ] Speaker can connect to multiple choices

---

### Feature 1.6: Save/Load System (.dtree)

**Description:** Save dialogue trees to custom .dtree format and load them back.

**Dependencies:** Feature 1.5

**Implementation Tasks:**
- [ ] Define .dtree JSON structure (per spec)
- [ ] Create `dialogue_tree_data.gd` Resource class
- [ ] Implement `serialize_tree()` → Dictionary
- [ ] Implement `deserialize_tree(data)` → rebuild canvas
- [ ] Serialize node positions and zoom/offset
- [ ] Add File menu to toolbar:
  - [ ] New (Ctrl+N)
  - [ ] Open (Ctrl+O)
  - [ ] Save (Ctrl+S)
  - [ ] Save As (Ctrl+Shift+S)
- [ ] Implement file dialogs for open/save
- [ ] Track "dirty" state (unsaved changes indicator)
- [ ] Prompt to save on close if dirty
- [ ] Store canvas zoom and scroll position

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd`
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`
- `addons/dialogue_editor/scenes/main_panel.tscn` (add toolbar)
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Can save tree to .dtree file
- [ ] Can load .dtree file and recreate tree exactly
- [ ] Canvas position/zoom restored on load
- [ ] Unsaved changes show indicator (*)
- [ ] Prompted to save before closing
- [ ] Keyboard shortcuts work

---

### Feature 1.7: JSON Export

**Description:** Export dialogue tree to game-readable JSON format.

**Dependencies:** Feature 1.6

**Implementation Tasks:**
- [ ] Define export JSON structure (per spec - runtime format)
- [ ] Create `dialogue_exporter.gd` utility
- [ ] Transform internal format to game format:
  - [ ] Flatten node structure
  - [ ] Convert connections to "next" arrays
  - [ ] Strip editor-only data (positions)
  - [ ] Identify start node
- [ ] Add Export menu item (Ctrl+E)
- [ ] Add Export button to toolbar
- [ ] Default export location: `res://data/dialogue/`
- [ ] Auto-name export file from dialogue_id

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_exporter.gd`
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Export produces valid JSON
- [ ] Exported format matches spec exactly
- [ ] Start node correctly identified
- [ ] All connections converted to "next" references
- [ ] No editor data in export (positions, etc.)
- [ ] Game can load and parse exported JSON

---

### Feature 1.8: Undo/Redo System

**Description:** Full undo/redo support for all canvas operations.

**Dependencies:** Feature 1.5

**Implementation Tasks:**
- [ ] Integrate Godot's UndoRedo class
- [ ] Wrap node creation in undo action
- [ ] Wrap node deletion in undo action
- [ ] Wrap connection creation in undo action
- [ ] Wrap connection deletion in undo action
- [ ] Wrap node property changes in undo action
- [ ] Wrap node movement in undo action
- [ ] Add Edit menu with Undo/Redo
- [ ] Implement Ctrl+Z (undo) and Ctrl+Shift+Z (redo)
- [ ] Show action name in Edit menu

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Can undo node creation
- [ ] Can undo node deletion
- [ ] Can undo connection changes
- [ ] Can undo property edits
- [ ] Can redo all above
- [ ] Undo history survives node selection changes
- [ ] Keyboard shortcuts work

---

### Phase 1 Technical Setup

- [ ] Create `addons/dialogue_editor/` directory structure
- [ ] Create `plugin.cfg` with metadata
- [ ] Create `plugin.gd` EditorPlugin base
- [ ] Enable plugin in Project Settings
- [ ] Create `res://data/dialogue/` directory for exports

---

## Phase 2: Workflow Improvements

**Goal:** Make dialogue authoring efficient for daily use.

**Prerequisites:** Phase 1 complete

---

### Feature 2.1: Advanced Node Types

**Description:** Add the 6 Phase 2 node types for game logic integration.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [ ] Create `skill_check_node.tscn` and script:
  - [ ] Skill dropdown (persuasion, intimidation, etc.)
  - [ ] DC (difficulty class) spinner
  - [ ] Two outputs: success, fail
- [ ] Create `flag_check_node.tscn` and script:
  - [ ] Flag name field (with autocomplete if registry exists)
  - [ ] Operator dropdown (==, !=, >, <)
  - [ ] Value field
  - [ ] Two outputs: true, false
- [ ] Create `flag_set_node.tscn` and script:
  - [ ] Flag name field
  - [ ] Value field
  - [ ] One output
- [ ] Create `quest_node.tscn` and script:
  - [ ] Quest ID field (with autocomplete if registry exists)
  - [ ] Action dropdown (start, complete, fail, update)
  - [ ] One output
- [ ] Create `reputation_node.tscn` and script:
  - [ ] Faction dropdown
  - [ ] Amount spinner (+/-)
  - [ ] One output
- [ ] Create `item_node.tscn` and script:
  - [ ] Action dropdown (give, take, check)
  - [ ] Item ID field
  - [ ] Quantity spinner
  - [ ] Two outputs for "check" action

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/nodes/skill_check_node.tscn`
- `addons/dialogue_editor/scripts/nodes/skill_check_node.gd`
- `addons/dialogue_editor/scenes/nodes/flag_check_node.tscn`
- `addons/dialogue_editor/scripts/nodes/flag_check_node.gd`
- `addons/dialogue_editor/scenes/nodes/flag_set_node.tscn`
- `addons/dialogue_editor/scripts/nodes/flag_set_node.gd`
- `addons/dialogue_editor/scenes/nodes/quest_node.tscn`
- `addons/dialogue_editor/scripts/nodes/quest_node.gd`
- `addons/dialogue_editor/scenes/nodes/reputation_node.tscn`
- `addons/dialogue_editor/scripts/nodes/reputation_node.gd`
- `addons/dialogue_editor/scenes/nodes/item_node.tscn`
- `addons/dialogue_editor/scripts/nodes/item_node.gd`
- `addons/dialogue_editor/scripts/node_palette.gd` (add to palette)
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` (export support)

**Success Criteria:**
- [ ] All 6 new node types available in palette
- [ ] Each node has correct inputs/outputs
- [ ] Export includes new node types correctly
- [ ] Nodes serialize/deserialize properly

---

### Feature 2.2: In-Editor Dialogue Testing

**Description:** Play through dialogue in the editor without running the game.

**Dependencies:** Feature 2.1

**Implementation Tasks:**
- [ ] Create `test_panel.tscn` dialog/popup
- [ ] Display current speaker and text
- [ ] Show portrait if available
- [ ] Display choice buttons for player responses
- [ ] Highlight current node on canvas
- [ ] Track and display simulated state:
  - [ ] Flags set during test
  - [ ] Reputation changes
  - [ ] Items given/taken
  - [ ] Quests started/completed
- [ ] Add "Back" button (undo last choice)
- [ ] Add "Restart" button
- [ ] Add "Skip to Node" dropdown
- [ ] Simulate skill checks (pass/fail toggle)
- [ ] Add F5 shortcut to start test
- [ ] Track which nodes visited (coverage)

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/test_panel.tscn`
- `addons/dialogue_editor/scripts/test_panel.gd`
- `addons/dialogue_editor/scripts/dialogue_runner.gd` (test execution)
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Can play through dialogue choosing options
- [ ] Current node highlighted on canvas
- [ ] Can see simulated flag/quest changes
- [ ] Can go back to previous choice
- [ ] Can restart from beginning
- [ ] Can jump to any node
- [ ] Coverage tracking shows visited nodes

---

### Feature 2.3: Search & Filter

**Description:** Find nodes by speaker, text content, or ID.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [ ] Add search bar to toolbar
- [ ] Implement search by:
  - [ ] Node ID
  - [ ] Speaker name
  - [ ] Dialogue text content
  - [ ] Node type
- [ ] Highlight matching nodes on canvas
- [ ] Add "Find Next" / "Find Previous" (F3 / Shift+F3)
- [ ] Jump to and select found node
- [ ] Show result count
- [ ] Add filter dropdown to show only certain node types

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/main_panel.tscn`
- `addons/dialogue_editor/scripts/search_manager.gd`
- `addons/dialogue_editor/scripts/dialogue_canvas.gd`

**Success Criteria:**
- [ ] Can search by text content
- [ ] Can search by speaker
- [ ] Matching nodes highlighted
- [ ] Can cycle through results
- [ ] Can filter canvas to show only certain types

---

### Feature 2.4: Validation System

**Description:** Detect and report structural issues in dialogue trees.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [ ] Create `dialogue_validator.gd`
- [ ] Detect orphan nodes (no incoming connections except Start)
- [ ] Detect dead ends (non-End nodes with no outgoing connections)
- [ ] Detect missing Start node
- [ ] Detect multiple Start nodes
- [ ] Detect unreachable nodes (not connected to Start)
- [ ] Detect empty text fields
- [ ] Add "Validate" button to toolbar
- [ ] Show validation results panel
- [ ] Click result to jump to problem node
- [ ] Show warning icons on invalid nodes
- [ ] Validate before export (optional block)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_validator.gd`
- `addons/dialogue_editor/scenes/validation_panel.tscn`
- `addons/dialogue_editor/scripts/validation_panel.gd`
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Detects orphan nodes
- [ ] Detects dead ends
- [ ] Detects missing/multiple start
- [ ] Detects empty required fields
- [ ] Can click to jump to problem
- [ ] Warning icons on canvas
- [ ] Option to validate before export

---

### Feature 2.5: Speaker Color Coding

**Description:** Automatically color nodes based on speaker for visual clarity.

**Dependencies:** Feature 1.4

**Implementation Tasks:**
- [ ] Define color palette per speaker (from spec)
- [ ] Create speaker → color mapping (configurable)
- [ ] Apply color to Speaker nodes based on speaker field
- [ ] Apply player color to Choice nodes
- [ ] Add color legend to palette or status bar
- [ ] Allow custom speaker colors in settings
- [ ] Update colors when speaker changes

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd`
- `addons/dialogue_editor/scripts/nodes/choice_node.gd`
- `addons/dialogue_editor/scripts/speaker_colors.gd`
- `addons/dialogue_editor/scenes/node_palette.tscn` (color legend)

**Success Criteria:**
- [ ] Speaker nodes colored by speaker
- [ ] Choice nodes always blue (player)
- [ ] Colors match spec palette
- [ ] Color updates when speaker changes
- [ ] Legend visible showing color meanings

---

### Feature 2.6: Auto-Save

**Description:** Automatically save work to prevent data loss.

**Dependencies:** Feature 1.6

**Implementation Tasks:**
- [ ] Implement auto-save timer (configurable, default 60s)
- [ ] Save to temp file (not overwrite original)
- [ ] Detect unsaved changes trigger
- [ ] Add auto-save indicator to status bar
- [ ] Recover from auto-save on crash
- [ ] Add auto-save toggle in settings
- [ ] Show "Recovered from auto-save" dialog if applicable

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/auto_save_manager.gd`
- `addons/dialogue_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Auto-saves every 60 seconds when dirty
- [ ] Does not overwrite manual saves
- [ ] Recovery works after crash
- [ ] Can disable auto-save
- [ ] Status bar shows last auto-save time

---

## Phase 3: Polish & Edge Cases

**Goal:** Production-ready tool that handles edge cases gracefully.

**Prerequisites:** Phase 2 complete, tool used in real workflows

---

### Feature 3.1: Property Panel

**Description:** Dedicated slide-out panel for editing selected node properties.

**Dependencies:** Phase 1 complete

**Implementation Tasks:**
- [ ] Create `property_panel.tscn` as slide-out panel
- [ ] Show when node selected, hide when deselected
- [ ] Display all node properties with appropriate editors
- [ ] Larger text area for dialogue (easier editing than inline)
- [ ] Character counter for text fields
- [ ] Portrait preview for Speaker nodes
- [ ] Add "Apply" and "Cancel" buttons (or auto-apply)
- [ ] Animate slide in/out

**Files to Create/Modify:**
- `addons/dialogue_editor/scenes/property_panel.tscn`
- `addons/dialogue_editor/scripts/property_panel.gd`
- `addons/dialogue_editor/scenes/main_panel.tscn`

**Success Criteria:**
- [ ] Panel slides out when node selected
- [ ] All properties editable
- [ ] Character counter visible
- [ ] Portrait preview works
- [ ] Changes apply to node

---

### Feature 3.2: Keyboard Shortcuts

**Description:** Comprehensive keyboard shortcuts for power users.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [ ] Implement all shortcuts from spec:
  - [ ] Ctrl+N - New
  - [ ] Ctrl+O - Open
  - [ ] Ctrl+S - Save
  - [ ] Ctrl+Shift+S - Save As
  - [ ] Ctrl+E - Export
  - [ ] Ctrl+Z - Undo
  - [ ] Ctrl+Shift+Z - Redo
  - [ ] F5 - Test dialogue
  - [ ] Delete - Delete selected nodes
  - [ ] Ctrl+D - Duplicate selected
  - [ ] Ctrl+A - Select all
  - [ ] Escape - Deselect all
  - [ ] F3 - Find next
  - [ ] 1-5 - Quick add node types
- [ ] Add Help menu with shortcut reference
- [ ] Allow shortcut customization (future)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/main_panel.gd`
- `addons/dialogue_editor/scripts/shortcut_manager.gd`

**Success Criteria:**
- [ ] All listed shortcuts work
- [ ] No conflicts with Godot shortcuts
- [ ] Help menu shows shortcut list

---

### Feature 3.3: Error Handling & Edge Cases

**Description:** Graceful handling of errors and edge cases.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [ ] Handle corrupted .dtree files (show error, don't crash)
- [ ] Handle missing referenced files (portraits, audio)
- [ ] Handle very long dialogue text (truncate display, not data)
- [ ] Handle 500+ node trees (performance)
- [ ] Handle circular references in Branch nodes
- [ ] Empty tree handling (new file state)
- [ ] Handle special characters in text
- [ ] Handle node ID collisions on paste
- [ ] Add error notification system

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/error_handler.gd`
- Various existing scripts (add try/catch, validation)

**Success Criteria:**
- [ ] Corrupted files show error message
- [ ] Missing files show placeholder
- [ ] 500+ nodes perform smoothly
- [ ] No crashes from user input
- [ ] Circular references detected

---

### Feature 3.4: Documentation & Help

**Description:** In-editor help and usage documentation.

**Dependencies:** Phase 2 complete

**Implementation Tasks:**
- [ ] Create `docs/tools/dialogue-tree-editor-guide.md`
- [ ] Add Help menu with:
  - [ ] Quick Start Guide
  - [ ] Keyboard Shortcuts
  - [ ] Node Type Reference
  - [ ] Troubleshooting
- [ ] Add tooltips to all buttons and fields
- [ ] Add "What's This?" mode (click for help)
- [ ] Document export format for game integration

**Files to Create/Modify:**
- `docs/tools/dialogue-tree-editor-guide.md`
- `addons/dialogue_editor/scripts/main_panel.gd`
- Various scene files (add tooltips)

**Success Criteria:**
- [ ] Guide covers all features
- [ ] All buttons have tooltips
- [ ] Help accessible from editor
- [ ] Export format documented

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

### Phase 1 Progress
- [x] Feature 1.1: Plugin Setup
- [ ] Feature 1.2: Visual Node Canvas
- [ ] Feature 1.3: Node Palette
- [ ] Feature 1.4: Core Node Types
- [ ] Feature 1.5: Node Connections
- [ ] Feature 1.6: Save/Load System
- [ ] Feature 1.7: JSON Export
- [ ] Feature 1.8: Undo/Redo System

### Phase 2 Progress
- [ ] Feature 2.1: Advanced Node Types
- [ ] Feature 2.2: In-Editor Testing
- [ ] Feature 2.3: Search & Filter
- [ ] Feature 2.4: Validation System
- [ ] Feature 2.5: Speaker Color Coding
- [ ] Feature 2.6: Auto-Save

### Phase 3 Progress
- [ ] Feature 3.1: Property Panel
- [ ] Feature 3.2: Keyboard Shortcuts
- [ ] Feature 3.3: Error Handling
- [ ] Feature 3.4: Documentation

---

**Total Features:** 18 (8 MVP + 6 Workflow + 4 Polish)

**To implement a feature, run:**
```
/tool-feature-implementer Feature X.X from Dialogue Tree Editor
```
