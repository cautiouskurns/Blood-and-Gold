# Tool Roadmap: Data Table Editor

**Spec:** `.claude/skills/prototype-roadmap-planner/Data Table Editor - Design Specification.md`
**Created:** 2026-01-14
**Implementer:** Use `tool-feature-implementer` skill to build features

---

## Overview

```mermaid
graph LR
    P1["Phase 1: MVP<br/>Basic table viewing & editing"]
    P2["Phase 2: Workflow<br/>Efficient daily editing"]
    P3["Phase 3: Polish<br/>Advanced features & UX"]

    P1 --> P2 --> P3

    style P1 fill:#e53e3e,stroke:#c53030,color:#fff
    style P2 fill:#d69e2e,stroke:#b7791f,color:#fff
    style P3 fill:#38a169,stroke:#2f855a,color:#fff
```

**Goal:** Spreadsheet-style editor plugin for managing all game data (items, abilities, enemies, NPCs) in a central, visual interface with schema-based validation.

---

## Phase 1: MVP (Minimum Viable Tool)

**Goal:** Load JSON tables, display in a grid, edit cells, save changes back to files.

**Exit Criteria:** Can view and edit any JSON table with basic data types (string, integer, boolean).

---

### Feature 1.1: Plugin Setup ✅

**Description:** Create the base EditorPlugin structure with a main dock panel that appears in the Godot editor.

**Implementation Tasks:**
- [x] Create `addons/data_table_editor/` directory structure
- [x] Create `plugin.cfg` with metadata (name, description, author, version)
- [x] Create `plugin.gd` extending EditorPlugin
- [x] Register main panel as editor main screen (like 2D/3D/Script views)
- [x] Create `scenes/main_panel.tscn` with HSplitContainer layout
- [x] Create `scripts/main_panel.gd` for panel controller

**Files to Create/Modify:**
- `addons/data_table_editor/plugin.cfg`
- `addons/data_table_editor/plugin.gd`
- `addons/data_table_editor/scenes/main_panel.tscn`
- `addons/data_table_editor/scripts/main_panel.gd`

**Success Criteria:**
- [x] Plugin appears in Project Settings > Plugins
- [x] "Data Tables" tab appears in editor main screen when plugin enabled
- [x] Main panel shows empty split container layout

---

### Feature 1.2: Table Sidebar ✅

**Description:** Left panel Tree showing all tables organized by category, with row counts.

**Dependencies:** Feature 1.1 (Plugin Setup)

**Implementation Tasks:**
- [x] Add Tree node to left side of HSplitContainer
- [x] Create `scripts/table_sidebar.gd` for sidebar logic
- [x] Implement `scan_data_folder()` to find all .json files in `data/` recursively
- [x] Parse JSON files to extract table metadata (schema name, row count)
- [x] Build tree with categories (Items, Abilities, Enemies) as collapsible parents
- [x] Show table name and row count: "weapons (42 rows)"
- [x] Connect item_selected signal to load table in grid
- [x] Add search filtering for table list
- [x] Add category icons using Godot editor icons
- [x] Add right-click context menu (Rename, Duplicate, Export, Delete)
- [x] Add visual states for modified (*) and error (!) tables

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/main_panel.tscn`
- `addons/data_table_editor/scripts/table_sidebar.gd`

**Success Criteria:**
- [x] Sidebar shows all JSON files from `data/` folder
- [x] Tables grouped by subfolder (items, abilities, enemies)
- [x] Row counts display correctly
- [x] Clicking table name triggers table load
- [x] Search filter works to narrow down table list
- [x] Category icons display correctly
- [x] Context menu appears on right-click

---

### Feature 1.3: Schema Loading ✅

**Description:** Load schema definitions from JSON files to understand column types and validation rules.

**Dependencies:** Feature 1.2 (Table Sidebar)

**Implementation Tasks:**
- [x] Create `scripts/schema_loader.gd` utility class
- [x] Define schema JSON format (columns array with name, type, required, etc.)
- [x] Implement `load_schema(schema_name: String) -> Dictionary`
- [x] Cache loaded schemas to avoid re-parsing
- [x] Create example schema: `data/_schemas/weapons.schema.json`
- [x] Handle missing schema gracefully (infer types from data)
- [x] Add validation support for column types
- [x] Support for special types: enum, dice, resource_path, table_ref

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/schema_loader.gd`
- `data/_schemas/weapons.schema.json` (example)

**Success Criteria:**
- [x] Schemas load from `data/_schemas/` folder
- [x] Schema provides column definitions (name, type, required, default)
- [x] Missing schema doesn't crash - infers from data
- [x] Schema cache prevents redundant file reads
- [x] Validation methods available for cell values

---

### Feature 1.4: Table Grid View ✅

**Description:** Display table data in a Tree with columns (spreadsheet-style grid).

**Dependencies:** Feature 1.2 (Table Sidebar), Feature 1.3 (Schema Loading)

**Implementation Tasks:**
- [x] Create `scripts/table_grid.gd` for grid logic
- [x] Add Tree node to right side of HSplitContainer
- [x] Configure Tree with columns based on schema
- [x] Set column titles from schema column names
- [x] Implement `load_data(data, schema)` to populate rows
- [x] Create TreeItems for each row in JSON data
- [x] Set cell text for each column based on data type
- [x] Implement row selection (single-click selects row)
- [x] Add type-aware cell styling (booleans, negative numbers)
- [x] Add signals for row_selected, cell_edited, selection_changed

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/main_panel.tscn`
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [x] Clicking table in sidebar loads data into grid
- [x] Column headers match schema definition
- [x] All rows display with correct cell values
- [x] Rows are selectable
- [x] Cell styling reflects data types (green for true, gray for false, red for negative)

---

### Feature 1.5: Inline Cell Editing ✅

**Description:** Double-click a cell to edit its value inline with appropriate input control.

**Dependencies:** Feature 1.4 (Table Grid View)

**Implementation Tasks:**
- [x] Connect `item_edited` signal on Tree
- [x] Make columns editable in Tree configuration
- [x] Implement cell editing for basic types:
  - String: LineEdit (default Tree behavior)
  - Integer: Text input with validation
  - Boolean: Checkbox toggle (CELL_MODE_CHECK)
- [x] Validate input on edit complete using SchemaLoader
- [x] Update internal data model on valid edit
- [x] Mark row as modified (visual indicator with * suffix and background tint)
- [x] Emit validation_error signal for invalid input
- [x] Revert to original value on validation failure

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/table_grid.gd`
- `addons/data_table_editor/scripts/main_panel.gd`

**Success Criteria:**
- [x] Double-click cell enables editing
- [x] String cells show text input
- [x] Boolean cells toggle on click (checkbox mode)
- [x] Integer cells accept only numbers (validated)
- [x] Modified rows show visual indicator (* and yellow tint)
- [x] Validation errors display in status bar

---

### Feature 1.6: Add/Delete Rows ✅

**Description:** Toolbar buttons to add new rows and delete selected rows.

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [x] Create toolbar HBoxContainer above grid
- [x] Add "Add Row" button with tooltip
- [x] Add "Delete" button with tooltip
- [x] Add "Duplicate" button with tooltip
- [x] Add "Move Up/Down" buttons with tooltips
- [x] Implement `_on_add_row_pressed()` - creates row with default values from schema
- [x] Implement `_on_delete_pressed()` - removes selected rows (supports multi-select)
- [x] Implement `_on_duplicate_pressed()` - duplicates selected row with unique ID
- [x] Auto-generate unique IDs for new/duplicated rows
- [x] Update internal data model
- [x] Refresh grid display after changes
- [x] Select newly added/duplicated rows
- [x] Enable multi-select mode (Ctrl/Shift+click)

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/main_panel.tscn`
- `addons/data_table_editor/scripts/main_panel.gd`
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [x] "Add Row" creates new row at end of table
- [x] New row has default values from schema
- [x] New rows get auto-generated unique IDs
- [x] "Delete" removes selected row(s) - supports multi-select
- [x] "Duplicate" creates copy with unique ID
- [x] Grid updates immediately after add/delete
- [x] Newly added/duplicated rows are auto-selected

---

### Feature 1.7: Save to JSON ✅

**Description:** Save modified table data back to the original JSON file.

**Dependencies:** Feature 1.6 (Add/Delete Rows)

**Implementation Tasks:**
- [x] Add "Save" button to toolbar
- [x] Track dirty state (has unsaved changes)
- [x] Implement `save_table()` to write JSON
- [x] Format JSON with proper indentation for readability
- [x] Update dirty state after save
- [x] Show save success/failure feedback in status bar
- [x] Add confirmation before switching tables with unsaved changes
- [x] Keyboard shortcut Ctrl+S

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/main_panel.gd`
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [x] "Save" button writes changes to JSON file
- [x] JSON is properly formatted (indented)
- [x] Dirty indicator clears after save
- [x] File contains correct data when reopened
- [x] Success feedback shown after save (green "Saved!" message)
- [x] Confirmation dialog when switching tables with unsaved changes

---

### Phase 1 Technical Setup ✅

- [x] Create `addons/data_table_editor/` directory structure
- [x] Create `plugin.cfg` with metadata
- [x] Create `plugin.gd` EditorPlugin base
- [x] Create `data/` and `data/_schemas/` folders
- [x] Create example data: `data/items/weapons.json`
- [x] Enable plugin in Project Settings

---

## Phase 2: Workflow Improvements

**Goal:** Make daily editing efficient with search, sort, validation, and better editing UI.

**Prerequisites:** Phase 1 complete

---

### Feature 2.1: Search/Filter ✅

**Description:** Search box to filter visible rows by text match across all columns.

**Dependencies:** Feature 1.4 (Table Grid View)

**Implementation Tasks:**
- [x] Add LineEdit search box to filter bar above grid
- [x] Implement `filter_rows(search_text: String)`
- [x] Filter as user types (live search)
- [x] Match against all visible columns
- [x] Case-insensitive matching
- [x] Show match count: "X of Y rows"
- [x] Clear button to reset filter
- [x] Escape key to clear filter
- [x] Ctrl+F to focus filter box

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/main_panel.tscn`
- `addons/data_table_editor/scripts/table_grid.gd`
- `addons/data_table_editor/scripts/main_panel.gd`

**Success Criteria:**
- [x] Typing in search box filters visible rows
- [x] Only matching rows display in grid
- [x] Match count updates in real-time
- [x] Clear button shows all rows again
- [x] Filter clears when switching tables

---

### Feature 2.2: Column Sorting ✅

**Description:** Click column headers to sort ascending/descending.

**Dependencies:** Feature 1.4 (Table Grid View)

**Implementation Tasks:**
- [x] Connect column header click signal
- [x] Track current sort column and direction
- [x] Implement `sort_by_column(column: int, ascending: bool)`
- [x] Handle sorting for different types (string, int, float, boolean)
- [x] Show sort indicator arrow in column header
- [x] Click again to reverse sort direction

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [x] Clicking column header sorts by that column
- [x] Sort direction toggles on repeated clicks
- [x] Sort indicator shows in active column header (▲/▼)
- [x] Sorting works correctly for all data types

---

### Feature 2.3: Enum Dropdown ✅

**Description:** Enum-type columns show dropdown with predefined options instead of free text.

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [x] Detect enum type columns from schema
- [x] Extract enum options from schema definition
- [x] Override edit behavior for enum columns (disabled inline text edit)
- [x] Create PopupMenu for enum cell editing
- [x] Populate with enum options from schema
- [x] Apply selection back to cell and emit cell_edited signal
- [x] Show checkmark on currently selected option

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [x] Enum columns show dropdown popup on double-click
- [x] Dropdown contains all options from schema
- [x] Selection updates cell value correctly
- [x] Row marked as modified after change

---

### Feature 2.4: Dice Notation Validation ✅

**Description:** Dice-type columns validate format (e.g., "1d8+2") and show calculated average.

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [x] Create `scripts/dice_parser.gd` utility class
- [x] Implement regex validation: `\d+d\d+([\+\-]\d+)?`
- [x] Calculate average roll: (dice_count * (dice_sides + 1) / 2) + modifier
- [x] Calculate min/max roll
- [x] Show validation indicator (✓/✗) suffix on dice cells
- [x] Show avg/min/max in tooltip on hover
- [x] Highlight invalid entries with red text and background
- [x] Update weapons schema to use "dice" type for damage column

**Files Created/Modified:**
- `addons/data_table_editor/scripts/dice_parser.gd` (NEW)
- `addons/data_table_editor/scripts/table_grid.gd`
- `addons/data_table_editor/scripts/schema_loader.gd`
- `data/_schemas/weapons.schema.json`

**Success Criteria:**
- [x] Valid dice notation shows green text with ✓ suffix
- [x] Invalid notation shows red text with ✗ suffix and red background
- [x] Tooltip shows "Avg: X | Min: Y | Max: Z"
- [x] "1d8+2", "2d6", "1d20-1" all validate correctly

---

### Feature 2.5: Detail Panel ✅

**Description:** Bottom/right panel showing full editing form for selected row with all fields.

**Dependencies:** Feature 1.4 (Table Grid View)

**Implementation Tasks:**
- [x] Add VSplitContainer to right side for grid + detail
- [x] Create `scripts/detail_panel.gd`
- [x] Generate form fields from schema columns
- [x] Show field labels with validation feedback (required fields, dice validation)
- [x] Two-way binding: grid selection updates panel, panel edits update grid
- [x] Support multiline text (TextEdit) for description/notes fields
- [x] Type-specific controls: CheckBox (boolean), SpinBox (int/float), OptionButton (enum)

**Files Created/Modified:**
- `addons/data_table_editor/scenes/main_panel.tscn` - Added VSplitContainer and DetailPanel
- `addons/data_table_editor/scripts/detail_panel.gd` (NEW)
- `addons/data_table_editor/scripts/main_panel.gd` - Added detail panel wiring
- `addons/data_table_editor/scripts/table_grid.gd` - Added update_cell() method

**Success Criteria:**
- [x] Selecting row shows details in panel
- [x] All schema columns appear as form fields
- [x] Editing in panel updates grid cell
- [x] Editing in grid updates detail panel field
- [x] Multiline fields expand for long text (description, notes, etc.)

---

### Feature 2.6: Undo/Redo

**Description:** Track changes and allow undo/redo with Ctrl+Z / Ctrl+Y.

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [ ] Create `scripts/undo_manager.gd` to track actions
- [ ] Define action types: EditCell, AddRow, DeleteRow, MoveRow
- [ ] Push actions to history stack on change
- [ ] Implement `undo()` and `redo()` methods
- [ ] Add Undo/Redo buttons to toolbar
- [ ] Connect keyboard shortcuts Ctrl+Z, Ctrl+Y
- [ ] Limit history stack size (e.g., 100 actions)

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/undo_manager.gd`
- `addons/data_table_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Ctrl+Z undoes last edit
- [ ] Ctrl+Y redoes undone action
- [ ] Multiple undos work correctly
- [ ] Undo works for add/delete rows too

---

### Feature 2.7: Resource Path Browser

**Description:** Resource-path columns show browse button to select files from project.

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [ ] Detect resource_path type columns from schema
- [ ] Create custom cell editor with path text + browse button
- [ ] Open EditorFileDialog configured with filter from schema
- [ ] Apply selected path back to cell
- [ ] Show preview thumbnail for image resources
- [ ] Validate path exists in project

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/cell_editors/resource_path_editor.gd`

**Success Criteria:**
- [ ] Resource path columns show browse button
- [ ] File dialog filters by schema-defined types (e.g., "*.png")
- [ ] Selected path appears in cell
- [ ] Invalid paths show error indicator

---

### Feature 2.8: Keyboard Navigation

**Description:** Navigate and edit cells using keyboard (Tab, Enter, Arrow keys).

**Dependencies:** Feature 1.5 (Inline Cell Editing)

**Implementation Tasks:**
- [ ] Handle Tab key: move to next cell
- [ ] Handle Shift+Tab: move to previous cell
- [ ] Handle Enter: confirm edit, move to cell below
- [ ] Handle Escape: cancel current edit
- [ ] Handle Arrow keys: move selection between cells
- [ ] Handle F2: start editing selected cell

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [ ] Tab moves through cells left-to-right, top-to-bottom
- [ ] Enter confirms edit and moves down
- [ ] Escape cancels edit without saving
- [ ] F2 starts editing current cell

---

## Phase 3: Polish & Edge Cases

**Goal:** Production-ready with advanced features, better UX, and error handling.

**Prerequisites:** Phase 2 complete, used in real workflows

---

### Feature 3.1: Schema Editor UI

**Description:** Visual interface for creating and editing table schemas without writing JSON.

**Dependencies:** Feature 1.3 (Schema Loading)

**Implementation Tasks:**
- [ ] Create `scenes/schema_editor.tscn` popup dialog
- [ ] Show table metadata (name, display_name, category, icon)
- [ ] Show columns list with add/delete/reorder
- [ ] Column editor: name, type dropdown, required checkbox, etc.
- [ ] Enum editor: add/remove options
- [ ] Validation settings per column type
- [ ] Preview generated schema JSON
- [ ] Save to `data/_schemas/` folder

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/schema_editor.tscn`
- `addons/data_table_editor/scripts/schema_editor.gd`

**Success Criteria:**
- [ ] Can create new schema without writing JSON
- [ ] Can add columns with all type options
- [ ] Enum columns allow defining options
- [ ] Generated schema matches expected format

---

### Feature 3.2: Table References

**Description:** Columns that reference rows in other tables show dropdown populated from target table.

**Dependencies:** Feature 2.3 (Enum Dropdown)

**Implementation Tasks:**
- [ ] Detect table_ref type columns from schema
- [ ] Load target table specified in schema
- [ ] Extract ID and display name from target rows
- [ ] Create dropdown populated with target table entries
- [ ] Support nullable references (include "none" option)
- [ ] Show referenced item name in cell (not just ID)
- [ ] Click to jump to referenced row

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/cell_editors/table_ref_editor.gd`

**Success Criteria:**
- [ ] Table reference columns show dropdown with target table rows
- [ ] Cell displays referenced item's name
- [ ] Selecting from dropdown sets correct ID value
- [ ] Null/none option available if schema allows

---

### Feature 3.3: CSV Import

**Description:** Import data from CSV files (from Google Sheets, Excel exports).

**Dependencies:** Feature 1.7 (Save to JSON)

**Implementation Tasks:**
- [ ] Add "Import" dropdown to toolbar
- [ ] Implement CSV parser handling quoted strings and commas
- [ ] Show import preview dialog
- [ ] Map CSV columns to schema columns
- [ ] Option to replace or append data
- [ ] Validate imported data against schema
- [ ] Report import errors

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/importers/csv_importer.gd`
- `addons/data_table_editor/scenes/import_dialog.tscn`

**Success Criteria:**
- [ ] Can import CSV file from Google Sheets export
- [ ] Column mapping works correctly
- [ ] Invalid rows reported with details
- [ ] Successfully imports valid data

---

### Feature 3.4: Export Options

**Description:** Export table data to CSV, formatted JSON, or Markdown for documentation.

**Dependencies:** Feature 1.7 (Save to JSON)

**Implementation Tasks:**
- [ ] Add "Export" dropdown to toolbar
- [ ] Implement CSV export with proper escaping
- [ ] Implement formatted JSON export (pretty-printed)
- [ ] Implement Markdown table export
- [ ] Show file save dialog with format selection
- [ ] Option to export only selected rows
- [ ] Option to export only visible columns

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/exporters/csv_exporter.gd`
- `addons/data_table_editor/scripts/exporters/markdown_exporter.gd`

**Success Criteria:**
- [ ] CSV export opens correctly in Excel/Sheets
- [ ] JSON export is properly formatted
- [ ] Markdown export renders as table

---

### Feature 3.5: Validation Summary

**Description:** Panel showing all validation errors across the table with click-to-navigate.

**Dependencies:** Feature 2.4 (Dice Validation)

**Implementation Tasks:**
- [ ] Create validation panel at bottom of editor
- [ ] Run validation on all rows when table loads
- [ ] List errors: row ID, column, error message
- [ ] Click error to select and scroll to that cell
- [ ] Show error count in sidebar for each table
- [ ] Re-run validation on cell edit

**Files to Create/Modify:**
- `addons/data_table_editor/scenes/validation_panel.tscn`
- `addons/data_table_editor/scripts/validation_panel.gd`

**Success Criteria:**
- [ ] All validation errors listed in panel
- [ ] Clicking error navigates to cell
- [ ] Error count shows in table sidebar
- [ ] Errors update as data changes

---

### Feature 3.6: Auto-Save

**Description:** Automatically save changes after a delay, with toggle to enable/disable.

**Dependencies:** Feature 1.7 (Save to JSON)

**Implementation Tasks:**
- [ ] Add auto-save toggle in status bar
- [ ] Implement debounced save (e.g., 2 seconds after last change)
- [ ] Show "Saving..." indicator during save
- [ ] Show "Saved" confirmation briefly
- [ ] Remember auto-save preference in editor settings
- [ ] Skip auto-save if file externally modified

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/main_panel.gd`

**Success Criteria:**
- [ ] Changes auto-save after 2 seconds of inactivity
- [ ] Toggle controls auto-save behavior
- [ ] Visual feedback shows save status
- [ ] No data loss on editor crash

---

### Feature 3.7: Duplicate Row

**Description:** Duplicate selected row(s) with new unique IDs.

**Dependencies:** Feature 1.6 (Add/Delete Rows)

**Implementation Tasks:**
- [ ] Add "Duplicate" button to toolbar
- [ ] Implement `duplicate_selected_rows()`
- [ ] Copy all cell values from selected rows
- [ ] Generate new unique ID for duplicated rows
- [ ] Insert duplicates immediately after originals
- [ ] Connect Ctrl+D shortcut

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/table_grid.gd`

**Success Criteria:**
- [ ] Duplicate creates copy with new ID
- [ ] All values copied except ID
- [ ] Works with multiple selected rows
- [ ] Ctrl+D shortcut works

---

### Feature 3.8: Bulk Edit

**Description:** Edit a field value across multiple selected rows at once.

**Dependencies:** Feature 3.7 (Duplicate Row)

**Implementation Tasks:**
- [ ] Detect when multiple rows selected
- [ ] Show bulk edit option in detail panel
- [ ] Allow setting a column value for all selected
- [ ] Show confirmation: "Update 5 rows?"
- [ ] Apply change to all selected rows
- [ ] Support undo for bulk operations

**Files to Create/Modify:**
- `addons/data_table_editor/scripts/detail_panel.gd`

**Success Criteria:**
- [ ] Can select multiple rows (Ctrl+Click)
- [ ] Bulk edit option appears in detail panel
- [ ] Changing value updates all selected rows
- [ ] Single undo reverts bulk change

---

### Phase 3 Documentation

- [ ] Create usage guide in `docs/tools/data-table-editor-guide.md`
- [ ] Document schema format specification
- [ ] Document keyboard shortcuts
- [ ] Add inline code comments for complex logic

---

## Future Ideas (Backlog)

Ideas that might be valuable but aren't committed:

- **Card View:** Visual cards for items showing icons (alternative to grid)
- **Quick Filter Chips:** One-click filter buttons for common values
- **Calculated Fields:** Show derived values (damage average, DPS)
- **Copy/Paste Rows:** Clipboard support for rows
- **Recent Tables:** Remember last opened tables
- **Table Comparison:** Diff view between two versions
- **Version History:** Track changes over time
- **Runtime Hot Reload:** Update game data without restart

---

## Dependencies

| Dependency | Required By | Notes |
|------------|-------------|-------|
| `data/` folder structure | Feature 1.2 | Tables stored as JSON files |
| Schema JSON format | Feature 1.3 | Must define format first |
| Tree node with columns | Feature 1.4 | Godot built-in, no external dep |

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Tree performance with 1000+ rows | Slow scrolling, UI lag | Implement virtual scrolling or pagination in Phase 3 |
| Complex schema validation | Bugs, data corruption | Start with simple types, add complex validation incrementally |
| File conflicts with external edits | Data loss | Detect external changes, prompt for reload |
| Plugin conflicts with other tools | Editor crashes | Test with character assembler, dialogue editor enabled |

---

## Implementation Order Summary

**Phase 1 (MVP):**
1. Plugin Setup
2. Table Sidebar
3. Schema Loading
4. Table Grid View
5. Inline Cell Editing
6. Add/Delete Rows
7. Save to JSON

**Phase 2 (Workflow):**
1. Search/Filter
2. Column Sorting
3. Enum Dropdown
4. Dice Notation Validation
5. Detail Panel
6. Undo/Redo
7. Resource Path Browser
8. Keyboard Navigation

**Phase 3 (Polish):**
1. Schema Editor UI
2. Table References
3. CSV Import
4. Export Options
5. Validation Summary
6. Auto-Save
7. Duplicate Row
8. Bulk Edit

---

## Quick Start

To begin implementation:

```bash
# Create plugin directory structure
mkdir -p addons/data_table_editor/scenes
mkdir -p addons/data_table_editor/scripts
mkdir -p data/_schemas
mkdir -p data/items
```

Then use the `tool-feature-implementer` skill:

```
Implement Feature 1.1: Plugin Setup for Data Table Editor
```

Work through features in order, testing each before proceeding to the next.
