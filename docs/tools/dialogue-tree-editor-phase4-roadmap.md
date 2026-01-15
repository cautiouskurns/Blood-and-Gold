# Tool Roadmap: Dialogue Tree Editor - Phase 4 Enhancements

**Spec:** `docs/tools/dialogue-tree-editor-phase4-spec.md`
**Created:** 2026-01-13
**Implementer:** Use `tool-feature-implementer` skill to build features
**Base:** Phase 1-3 Complete (current working editor)

---

## Overview

```mermaid
graph LR
    P4A["Phase 4A: Templates<br/>Reusable patterns"]
    P4B["Phase 4B: Expressions<br/>Complex conditions"]
    P4C["Phase 4C: Text Tags<br/>Dynamic content"]
    P4D["Phase 4D: Grouping<br/>Organization"]
    P4E["Phase 4E: Localization<br/>Multi-language"]

    P4A --> P4B --> P4C --> P4D --> P4E

    style P4A fill:#e53e3e,stroke:#c53030,color:#fff
    style P4B fill:#dd6b20,stroke:#c05621,color:#fff
    style P4C fill:#d69e2e,stroke:#b7791f,color:#fff
    style P4D fill:#38a169,stroke:#2f855a,color:#fff
    style P4E fill:#3182ce,stroke:#2b6cb0,color:#fff
```

**Goal:** Transform the Dialogue Tree Editor from a basic authoring tool into a production-ready system supporting templates, complex logic, dynamic text, visual organization, and multi-language content.

---

## Phase 4A: Node Templates & Snippets

**Goal:** Enable writers to save and reuse common dialogue patterns.

**Exit Criteria:** Writer can save a selection of nodes as a template and insert it into any dialogue tree.

---

### Feature 4A.1: Template Data Format ✅ COMPLETE

**Description:** Define the template resource format and create the manager class for save/load operations.

**Implementation Tasks:**
- [x] Create `template_data.gd` Resource class with:
  - [x] Template name, description, tags
  - [x] Serialized node data (array of node dictionaries)
  - [x] Connection data (array of connection tuples)
  - [x] Relative positions (centered on origin)
  - [x] Variable placeholders metadata
- [x] Create `template_manager.gd` singleton for:
  - [x] Loading templates from `user://dialogue_templates/`
  - [x] Loading built-in templates from addon folder
  - [x] Saving custom templates
  - [x] Template validation
- [x] Define `.dttemplate` file extension and format

**Files Created:**
- `addons/dialogue_editor/scripts/templates/template_data.gd` ✅
- `addons/dialogue_editor/scripts/templates/template_manager.gd` ✅
- `addons/dialogue_editor/data/built_in_templates/basic_greeting.dttemplate` ✅

**Success Criteria:**
- [x] Can create TemplateData resource programmatically
- [x] Can save template to disk
- [x] Can load template from disk
- [x] Template format versioned for future compatibility

---

### Feature 4A.2: Save Selection as Template ✅ COMPLETE

**Description:** Allow users to select nodes on canvas and save them as a reusable template.

**Dependencies:** Feature 4A.1

**Implementation Tasks:**
- [x] Add "Save as Template" to right-click context menu (when nodes selected)
- [x] Add Ctrl+Shift+T keyboard shortcut
- [x] Create save template dialog:
  - [x] Template name (required)
  - [x] Description (optional)
  - [x] Tags for categorization (optional)
  - [x] Preview of selected nodes
- [x] Implement selection serialization:
  - [x] Capture all selected nodes with their data
  - [x] Capture connections between selected nodes
  - [x] Normalize positions relative to selection center
  - [x] Detect and preserve internal connections only
- [x] Validate template (must have at least 2 connected nodes)

**Files Created/Modified:**
- `addons/dialogue_editor/scripts/templates/save_template_dialog.gd` ✅
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (selection serialization) ✅
- `addons/dialogue_editor/scripts/main_panel.gd` (menu items, shortcut, wiring) ✅

**Success Criteria:**
- [x] Can select 3+ nodes and save as template
- [x] Template captures all node properties
- [x] Template captures internal connections
- [x] Dialog validates input before saving
- [x] Templates persist in user folder

---

### Feature 4A.3: Insert Template ✅ COMPLETE

**Description:** Insert a saved template into the current dialogue tree.

**Dependencies:** Feature 4A.1, 4A.2

**Implementation Tasks:**
- [x] Add "Insert Template" submenu to right-click context menu
- [x] Populate submenu with available templates (built-in + custom)
- [x] Implement template insertion:
  - [x] Generate new unique IDs for all nodes
  - [x] Position nodes at cursor/canvas center
  - [x] Create all internal connections
  - [x] Auto-connect to selected node's output (if applicable)
  - [x] Select all newly created nodes
- [x] Add to undo/redo system as single action
- [x] Handle ID collisions gracefully

**Files Modified:**
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (template submenu, insertion logic, undo/redo)

**Success Criteria:**
- [x] Can insert template from context menu
- [x] Inserted nodes have unique IDs (no collisions)
- [x] Internal connections recreated correctly
- [x] Can undo entire template insertion
- [x] Nodes positioned near cursor

---

### Feature 4A.4: Built-in Template Library ✅ COMPLETE

**Description:** Create pre-made templates for common dialogue patterns.

**Dependencies:** Feature 4A.1

**Implementation Tasks:**
- [x] Create `built_in_templates.gd` with template definitions
- [x] Implement "Basic Greeting" template:
  - [x] Start → Speaker (NPC greeting) → 3 Choices → Ends
- [x] Implement "Shop Interaction" template:
  - [x] Speaker → Choices (Buy/Sell/Browse/Leave) → Ends
- [x] Implement "Quest Offer" template:
  - [x] Speaker (description) → Choices (Accept/Decline) → Quest nodes → Ends
- [x] Implement "Skill Check Gate" template:
  - [x] Speaker → Skill Check → Success/Fail branches → Ends
- [x] Implement "Information Loop" template:
  - [x] Speaker → Multiple question choices → Return to menu → Exit
- [x] Package as `.dttemplate` files in addon folder

**Files Created:**
- `addons/dialogue_editor/scripts/templates/built_in_templates.gd` ✅
- `addons/dialogue_editor/data/built_in_templates/basic_greeting.dttemplate` ✅
- `addons/dialogue_editor/data/built_in_templates/shop_interaction.dttemplate` ✅
- `addons/dialogue_editor/data/built_in_templates/quest_offer.dttemplate` ✅
- `addons/dialogue_editor/data/built_in_templates/skill_check_gate.dttemplate` ✅
- `addons/dialogue_editor/data/built_in_templates/information_loop.dttemplate` ✅

**Success Criteria:**
- [x] All 5 built-in templates available
- [x] Each template is a valid, usable dialogue pattern
- [x] Templates appear in insert menu under category sections

---

### Feature 4A.5: Template Library Panel ✅ COMPLETE

**Description:** Add a dedicated UI panel for browsing and managing templates.

**Dependencies:** Features 4A.1-4A.4

**Implementation Tasks:**
- [x] Create `template_library_panel.gd` as collapsible section in palette
- [x] Display template tree with categories:
  - [x] Built-in templates (read-only, with visual distinction)
  - [x] Custom templates (editable)
- [x] Add template preview on selection (shows name, description, node count, tags, placeholders)
- [x] Add template management buttons:
  - [x] Import template (file dialog)
  - [x] Export template (file dialog)
  - [x] Delete custom template (with confirmation)
  - [x] Refresh button
- [x] Support drag-and-drop from library to canvas
- [x] Add search/filter for templates (searches name, description, tags)

**Files Created/Modified:**
- `addons/dialogue_editor/scripts/template_library_panel.gd` ✅
- `addons/dialogue_editor/scripts/main_panel.gd` (integration, signal handlers) ✅
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (template drop handling) ✅
- `addons/dialogue_editor/scenes/main_panel.tscn` (UI layout) ✅

**Success Criteria:**
- [x] Template library visible in left panel below Node Palette
- [x] Can expand/collapse template categories
- [x] Can drag template to canvas to insert
- [x] Can double-click template to insert at canvas center
- [x] Can import/export templates
- [x] Can delete custom templates (built-in protected)

---

## Phase 4B: Variables & Expression System

**Goal:** Enable complex conditional logic with compound expressions and variable tracking.

**Exit Criteria:** Writer can use expressions like `reputation >= 50 and has_item("key")` in Branch nodes.

---

### Feature 4B.1: Expression Lexer ✅ COMPLETE

**Description:** Tokenize expression strings into a stream of typed tokens.

**Implementation Tasks:**
- [x] Create `expression_lexer.gd` with token types:
  - [x] NUMBER (integer, float)
  - [x] STRING (quoted)
  - [x] BOOLEAN (true, false)
  - [x] IDENTIFIER (variable names)
  - [x] OPERATOR (==, !=, >, <, >=, <=, +, -, *, /)
  - [x] KEYWORD (and, or, not)
  - [x] PUNCTUATION (parentheses, comma, dot)
- [x] Implement `tokenize(expression: String) -> Array[Token]`
- [x] Handle whitespace and comments
- [x] Report lexer errors with position

**Files Created:**
- `addons/dialogue_editor/scripts/expressions/expression_lexer.gd` ✅
- `addons/dialogue_editor/scripts/expressions/test_lexer.gd` ✅

**Success Criteria:**
- [x] Tokenizes `reputation >= 50` correctly
- [x] Tokenizes `has_item("key") and player_level > 10` correctly
- [x] Handles string literals with escapes
- [x] Reports position of invalid characters

---

### Feature 4B.2: Expression Parser ✅ COMPLETE

**Description:** Parse token stream into an Abstract Syntax Tree (AST).

**Dependencies:** Feature 4B.1

**Implementation Tasks:**
- [x] Create `expression_parser.gd` with AST node types:
  - [x] BinaryOp (left, operator, right)
  - [x] UnaryOp (operator, operand)
  - [x] Literal (value)
  - [x] Variable (name, with dot notation support)
  - [x] FunctionCall (name, arguments)
  - [x] MemberAccessNode (object.member)
  - [x] IndexAccessNode (object[index])
- [x] Implement recursive descent parser:
  - [x] `parse_expression()` - top level
  - [x] `parse_or()` - or expressions
  - [x] `parse_and()` - and expressions
  - [x] `parse_comparison()` - ==, !=, etc.
  - [x] `parse_term()` - +, -
  - [x] `parse_factor()` - *, /
  - [x] `parse_unary()` - not, -
  - [x] `parse_postfix()` - function calls, member access, index access
  - [x] `parse_primary()` - literals, variables, parenthesized expressions
- [x] Generate helpful parse error messages
- [x] Implement `validate(expression: String) -> Result`
- [x] Implement AST Visitor pattern for evaluation/compilation
- [x] Implement AST pretty printer for debugging

**Files Created:**
- `addons/dialogue_editor/scripts/expressions/expression_parser.gd` ✅
- `addons/dialogue_editor/scripts/expressions/test_parser.gd` ✅

**Success Criteria:**
- [x] Parses simple comparisons: `x > 5`
- [x] Parses compound expressions: `a and b or c`
- [x] Parses function calls: `has_item("sword")`
- [x] Parses nested expressions: `(a or b) and c`
- [x] Returns clear error messages for invalid syntax

---

### Feature 4B.3: Expression Evaluator ✅ COMPLETE

**Description:** Evaluate parsed expressions against a context of variable values.

**Dependencies:** Feature 4B.2

**Implementation Tasks:**
- [x] Create `expression_evaluator.gd` with:
  - [x] `evaluate(ast: ASTNode, context: Dictionary) -> Variant`
  - [x] Built-in functions:
    - [x] `has_item(item_id)` - check inventory
    - [x] `has_flag(flag_name)` - check game flags
    - [x] `quest_state(quest_id)` - get quest status
    - [x] `quest_complete(quest_id)` - check if quest complete
    - [x] `random()` - random float 0-1
    - [x] `random_int(min, max)` - random integer
    - [x] `count(item_id)` - item quantity
    - [x] `min(a, b)`, `max(a, b)`, `abs(x)`, `clamp(x, min, max)`
    - [x] `floor(x)`, `ceil(x)`, `round(x)`
    - [x] `len(x)`, `upper(str)`, `lower(str)`
    - [x] `is_number(x)`, `is_string(x)`, `is_bool(x)`
  - [x] Type coercion rules (string to number, bool to number, etc.)
  - [x] Error handling for missing variables (strict mode optional)
  - [x] Short-circuit evaluation for `and`/`or`
- [x] Create `expression_context.gd` to manage test values:
  - [x] Player stats management
  - [x] Inventory management
  - [x] Flag management
  - [x] Quest state management
  - [x] Serialization/deserialization
- [x] Static convenience methods `eval()` and `check()`

**Files Created:**
- `addons/dialogue_editor/scripts/expressions/expression_evaluator.gd` ✅
- `addons/dialogue_editor/scripts/expressions/expression_context.gd` ✅
- `addons/dialogue_editor/scripts/expressions/test_evaluator.gd` ✅

**Success Criteria:**
- [x] Evaluates `5 > 3` to `true`
- [x] Evaluates `reputation >= 50` with context `{reputation: 60}` to `true`
- [x] Evaluates `has_item("key") and gold > 100` correctly
- [x] Built-in functions work in test mode
- [x] Missing variables return sensible defaults or errors

---

### Feature 4B.4: Expression Editor UI ✅ COMPLETE

**Description:** Create a rich text editor component for expressions with syntax highlighting.

**Dependencies:** Feature 4B.2

**Implementation Tasks:**
- [x] Create `expression_editor.gd` using CodeEdit:
  - [x] Syntax highlighting for keywords, operators, strings, numbers
  - [x] Real-time validation on text change (with debounce timer)
  - [x] Error display in status bar with colored indicator
  - [x] Valid/invalid status icon
- [x] Implement autocomplete:
  - [x] Trigger on typing or Ctrl+Space
  - [x] Show known variables from current tree
  - [x] Show built-in functions with descriptions
  - [x] Show common variable suggestions
  - [x] Uses CodeEdit's built-in code completion system
- [x] Add "Test Expression" mini-panel:
  - [x] Auto-extracts variables from expression
  - [x] Input fields for variable values
  - [x] "Evaluate" button
  - [x] Colored result display (green=true, red=false)
- [x] Create compact `expression_field.gd` for inline use in nodes

**Files Created:**
- `addons/dialogue_editor/scripts/expressions/expression_editor.gd` ✅
- `addons/dialogue_editor/scripts/expressions/expression_field.gd` ✅
- `addons/dialogue_editor/scenes/expression_editor.tscn` ✅

**Success Criteria:**
- [x] Syntax highlighting works correctly (keywords pink, functions cyan, strings green, numbers purple)
- [x] Invalid expressions show error in status bar with red text
- [x] Status bar shows specific error message
- [x] Autocomplete suggests variables and functions
- [x] Can test expression with sample values in test panel

---

### Feature 4B.5: Update Branch Node (Dual-Mode) ✅ COMPLETE

**Description:** Add expression support to Branch node while keeping the simple dropdown mode. Writers can choose between "Simple" mode (dropdowns) for basic checks or "Expression" mode for complex logic.

**Dependencies:** Feature 4B.4

**Design Rationale:**
- Simple dropdown mode covers 80% of use cases (single flag/item/skill checks)
- Expression mode enables complex conditions without forcing complexity on all users
- Auto-conversion allows switching between modes seamlessly
- Non-technical writers aren't intimidated by expressions

**Implementation Tasks:**
- [x] Add mode toggle to Branch node UI:
  - [x] "Simple" mode (default): existing dropdown-based UI
  - [x] "Expression" mode: expression editor with syntax highlighting
  - [x] "Switch to Expression" button that auto-converts current dropdown to expression
- [x] Keep existing dropdown UI for Simple mode:
  - [x] condition_type dropdown (FLAG_CHECK, ITEM_CHECK, SKILL_CHECK, etc.)
  - [x] key/value fields based on type
  - [x] Add "+ Add Condition" for multiple simple conditions (AND'd together)
- [x] Add Expression mode UI:
  - [x] Expression editor component (from 4B.4)
  - [x] Validation indicator
  - [x] Test button
- [x] Implement auto-conversion (Simple → Expression):
  - [x] `FLAG_CHECK` + key + value → `has_flag("key") == value` or `flag_key == value`
  - [x] `ITEM_CHECK` + item → `has_item("item")`
  - [x] `SKILL_CHECK` + skill + dc → `skill_check("skill", dc)`
  - [x] Multiple conditions → `cond1 and cond2 and cond3`
- [x] Update serialization/deserialization:
  - [x] Store mode ("simple" or "expression")
  - [x] Simple mode: store condition_type, key, value (existing format)
  - [x] Expression mode: store raw expression string
  - [x] Both modes: store compiled expression for runtime evaluation
- [x] Migrate existing Branch node data on load:
  - [x] Old nodes load as Simple mode (backward compatible)
  - [x] No forced migration to expressions
- [x] Update export format:
  - [x] Always export as expression (unified runtime format)
  - [x] Game runtime only needs expression evaluator
- [x] Update test mode to evaluate both modes

**Files Modified:**
- `addons/dialogue_editor/scripts/nodes/branch_node.gd` ✅ (dual-mode UI with mode toggle, Simple/Expression views)
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` ✅ (exports expression field for unified runtime)
- `addons/dialogue_editor/scripts/dialogue_runner.gd` ✅ (expression evaluation with context building)

**UI Mockup (Simple Mode):**
```
┌─ Condition ──────────────────────────────┐
│ Mode: ● Simple  ○ Expression             │
├──────────────────────────────────────────┤
│ Type: [Flag Check ▼]                     │
│ Flag: [has_royal_token    ]              │
│ Value: [true ▼]                          │
│                                          │
│ [+ AND]              [→ Expression]      │
└──────────────────────────────────────────┘
```

**UI Mockup (Expression Mode):**
```
┌─ Condition ──────────────────────────────┐
│ Mode: ○ Simple  ● Expression             │
├──────────────────────────────────────────┤
│ [reputation >= 50 and has_item("key")  ] │
│                                          │
│ ✓ Valid                    [Test...]     │
└──────────────────────────────────────────┘
```

**Success Criteria:**
- [x] Branch node defaults to Simple mode
- [x] Can toggle between Simple and Expression modes
- [x] "Switch to Expression" converts dropdown to equivalent expression
- [x] Old dialogue trees load in Simple mode (backward compatible)
- [x] Both modes evaluate correctly in test mode
- [x] Export always outputs expression format for runtime

---

### Feature 4B.6: Variable Browser Panel ✅ COMPLETE

**Description:** Add a panel showing all variables used across the dialogue tree.

**Dependencies:** Feature 4B.2

**Implementation Tasks:**
- [x] Create `variable_browser_panel.gd`:
  - [x] Scan all nodes for variable references
  - [x] Display in categorized list (flags, items, quests, player, custom)
  - [x] Show variable name and where it's used
  - [x] Show test value (editable)
- [x] Add collapsible panel to left panel (below Template Library)
- [x] Real-time update when expressions change (on canvas_changed)
- [x] Click variable to highlight nodes using it
- [x] Test values stored and accessible

**Files Created/Modified:**
- `addons/dialogue_editor/scripts/ui/variable_browser_panel.gd` ✅
- `addons/dialogue_editor/scripts/main_panel.gd` ✅ (integrate panel, signal handlers)

**Success Criteria:**
- [x] Shows all variables from expressions
- [x] Can set test values
- [x] Click variable highlights usage
- [x] Updates as expressions are edited

---

### Feature 4B.7: Set Expression Node ✅ COMPLETE

**Description:** New node type for setting multiple variables in one action.

**Dependencies:** Feature 4B.3

**Implementation Tasks:**
- [x] Create `set_expression_node.gd`:
  - [x] Multiple assignment rows (variable = expression)
  - [x] Add/remove assignment buttons
  - [x] Validate each expression
  - [x] One input, one output
- [x] Add to node palette under "Advanced" section
- [x] Implement serialization/deserialization
- [x] Update exporter for new node type
- [x] Update test mode to execute assignments

**Files Created/Modified:**
- `addons/dialogue_editor/scripts/nodes/set_expression_node.gd` ✅
- `addons/dialogue_editor/scripts/node_palette.gd` ✅
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` ✅
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` ✅
- `addons/dialogue_editor/scripts/dialogue_runner.gd` ✅

**Success Criteria:**
- [x] Can create Set Expression node
- [x] Can add multiple assignments
- [x] Assignments execute in test mode
- [x] Exports correctly to JSON

---

## Phase 4C: Conditional Text Tags

**Goal:** Enable dynamic text with variable insertion and inline conditionals.

**Exit Criteria:** Writer can use `{player_name}` and `{if noble}Lord{/if}` syntax in dialogue.

---

### Feature 4C.1: Variable Tag Parser ✅ COMPLETE

**Description:** Parse `{variable_name}` tags in dialogue text.

**Implementation Tasks:**
- [x] Create `tag_parser.gd` with:
  - [x] `parse_tags(text: String) -> Array[Tag]`
  - [x] Tag types: VARIABLE, CONDITIONAL_START, CONDITIONAL_ELSE, CONDITIONAL_END, TEXT
  - [x] Handle nested tags (stub for Phase 4C.2)
  - [x] Handle escape sequences `\{` for literal braces
- [x] Support dot notation: `{player.stats.strength}`
- [x] Validate variable names
- [x] Report parse errors with position

**Files Created:**
- `addons/dialogue_editor/scripts/text_tags/tag_parser.gd` ✅
- `addons/dialogue_editor/scripts/text_tags/test_tag_parser.gd` ✅ (test script)

**Success Criteria:**
- [x] Parses `Hello, {player_name}!` correctly
- [x] Parses `{player.gold}` with dot notation
- [x] Handles escaped braces
- [x] Reports error for unclosed tags

---

### Feature 4C.2: Conditional Tag Parser ✅ COMPLETE

**Description:** Parse `{if condition}...{else}...{/if}` syntax.

**Dependencies:** Feature 4C.1, 4B.2

**Implementation Tasks:**
- [x] Extend tag_parser.gd for conditional syntax:
  - [x] `{if expression}` - start conditional
  - [x] `{elif expression}` - else-if branch (added)
  - [x] `{else}` - else branch (optional)
  - [x] `{/if}` or `{endif}` - end conditional
- [x] Support nested conditionals with depth tracking
- [x] Validate condition expressions using expression parser (basic syntax check)
- [x] Create AST representation of conditional text (ConditionalBlock class)

**Files Modified:**
- `addons/dialogue_editor/scripts/text_tags/tag_parser.gd` ✅ (extended with conditionals)
- `addons/dialogue_editor/scripts/text_tags/test_tag_parser.gd` ✅ (added 11 conditional tests)

**Success Criteria:**
- [x] Parses `{if noble}Lord{else}Friend{/if}` correctly
- [x] Validates condition syntax (balanced parentheses, non-empty)
- [x] Handles nested conditionals with max_nesting_depth tracking
- [x] Reports mismatched if/endif errors

---

### Feature 4C.3: Tag Renderer

**Description:** Render tagged text with variable values and evaluated conditionals.

**Dependencies:** Features 4C.1, 4C.2, 4B.3

**Implementation Tasks:**
- [ ] Create `tag_renderer.gd` with:
  - [ ] `render(text: String, context: Dictionary) -> String`
  - [ ] Variable substitution from context
  - [ ] Conditional evaluation and branch selection
  - [ ] Handle missing variables (show placeholder or warning)
- [ ] Support formatting in rendered output (for BBCode)
- [ ] Caching for repeated renders

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/text_tags/tag_renderer.gd` (new)

**Success Criteria:**
- [ ] Renders `Hello, {name}!` with context `{name: "Alice"}` → `Hello, Alice!`
- [ ] Renders conditionals correctly based on context
- [ ] Missing variables show `{variable_name}` or configurable placeholder

---

### Feature 4C.4: Formatting Tags

**Description:** Support BBCode-style formatting tags in dialogue text.

**Implementation Tasks:**
- [ ] Create `formatting_tags.gd` with supported tags:
  - [ ] `[b]bold[/b]`
  - [ ] `[i]italic[/i]`
  - [ ] `[color=red]colored[/color]`
  - [ ] `[shake]effect[/shake]` (passthrough for game)
  - [ ] `[wave]effect[/wave]` (passthrough for game)
  - [ ] `[pause=1.5]` (timing hint for game)
  - [ ] `[speed=0.5]` (typewriter speed)
- [ ] Pass through to export (game handles rendering)
- [ ] Validate tag nesting
- [ ] Preview formatting in editor using RichTextLabel

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/text_tags/formatting_tags.gd` (new)
- `addons/dialogue_editor/scripts/text_tags/tag_parser.gd` (integrate)

**Success Criteria:**
- [ ] BBCode tags preserved in export
- [ ] Validates proper tag nesting
- [ ] Editor preview shows basic formatting (bold, italic, color)

---

### Feature 4C.5: Text Preview in Property Panel

**Description:** Show rendered preview of tagged text in the property panel.

**Dependencies:** Features 4C.1-4C.4

**Implementation Tasks:**
- [ ] Extend property_panel.gd for Speaker/Choice nodes:
  - [ ] Add "Preview" section below text field
  - [ ] Use RichTextLabel for formatted preview
  - [ ] Render with current test values from Variable Browser
- [ ] Add "Set Test Values" button to open Variable Browser
- [ ] Real-time update as text is edited
- [ ] Show tag errors inline

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/property_panel.gd` (extend)
- `addons/dialogue_editor/scripts/ui/variable_browser_panel.gd` (integration)

**Success Criteria:**
- [ ] Preview shows rendered text with variables substituted
- [ ] Conditionals render based on test values
- [ ] Formatting (bold, italic, color) visible
- [ ] Invalid tags highlighted

---

### Feature 4C.6: Export with Tags

**Description:** Update export format to properly include tagged text.

**Dependencies:** Feature 4C.1

**Implementation Tasks:**
- [ ] Update dialogue_exporter.gd:
  - [ ] Preserve tag syntax in exported text
  - [ ] Add `variables_used` array to node data
  - [ ] Add `has_conditionals` flag to node data
- [ ] Update export validation:
  - [ ] Warn if variables have no known source
  - [ ] Validate all conditional expressions
- [ ] Document tag syntax in export format

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` (extend)

**Success Criteria:**
- [ ] Tags preserved exactly in JSON export
- [ ] Game runtime can parse exported tags
- [ ] Validation catches undefined variables

---

## Phase 4D: Node Grouping & Organization

**Goal:** Enable visual organization of large dialogue trees.

**Exit Criteria:** Writer can group nodes visually, collapse groups, and navigate organized trees.

---

### Feature 4D.1: Visual Node Groups

**Description:** Allow drawing colored boxes around node clusters with labels.

**Implementation Tasks:**
- [ ] Create `node_group.gd` as a custom canvas element:
  - [ ] Colored rectangle background (semi-transparent)
  - [ ] Title label at top
  - [ ] Resizable by dragging corners
  - [ ] Can be moved (moves with contained nodes option)
- [ ] Add "Create Group" to context menu (when nodes selected)
- [ ] Store groups in .dtree file:
  - [ ] Group ID, name, color
  - [ ] Position and size
  - [ ] Contained node IDs (for selection purposes)
- [ ] Groups render behind nodes (z-order)
- [ ] Double-click group label to edit

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/groups/node_group.gd` (new)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (group rendering, interaction)
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` (serialization)

**Success Criteria:**
- [ ] Can create group around selected nodes
- [ ] Group has colored background and label
- [ ] Can resize group
- [ ] Groups save/load correctly
- [ ] Can edit group title

---

### Feature 4D.2: Group Operations

**Description:** Enable operations on groups as a unit.

**Dependencies:** Feature 4D.1

**Implementation Tasks:**
- [ ] Implement "Select All in Group" (click group background)
- [ ] Implement "Move Group" (moves all contained nodes)
- [ ] Implement "Delete Group" (removes group box, keeps nodes)
- [ ] Implement "Dissolve Group" (same as delete)
- [ ] Add group color picker to context menu
- [ ] Add group to right-click menu:
  - [ ] Rename Group
  - [ ] Change Color
  - [ ] Select Contents
  - [ ] Delete Group

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/groups/node_group.gd` (extend)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (group operations)
- `addons/dialogue_editor/scripts/main_panel.gd` (context menu)

**Success Criteria:**
- [ ] Clicking group selects all contained nodes
- [ ] Moving group moves all nodes inside
- [ ] Can change group color
- [ ] Can rename group
- [ ] Deleting group leaves nodes intact

---

### Feature 4D.3: Collapsible Groups

**Description:** Allow groups to be collapsed to a single summary node.

**Dependencies:** Feature 4D.1, 4D.2

**Implementation Tasks:**
- [ ] Add collapse/expand button to group header
- [ ] When collapsed:
  - [ ] Hide all contained nodes
  - [ ] Show group as single rectangle with title
  - [ ] Display connection stubs (inputs/outputs that connect outside)
  - [ ] Show node count badge
- [ ] When expanded:
  - [ ] Show all contained nodes normally
  - [ ] Group box visible around them
- [ ] Preserve connections when collapsing/expanding
- [ ] Collapsed state saved in .dtree file

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/groups/node_group.gd` (collapse logic)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (connection routing)
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` (save collapsed state)

**Success Criteria:**
- [ ] Can collapse group to summary view
- [ ] Connections still visible to/from collapsed group
- [ ] Can expand to see full contents
- [ ] Collapsed state persists on save/load

---

### Feature 4D.4: Group Panel in Palette

**Description:** Add a panel listing all groups for quick navigation.

**Dependencies:** Feature 4D.1

**Implementation Tasks:**
- [ ] Create `group_list_panel.gd`:
  - [ ] List all groups in current dialogue
  - [ ] Show group name and node count
  - [ ] Color indicator matching group color
  - [ ] Click to jump to group
  - [ ] Collapse/expand toggle buttons
- [ ] Add to palette as collapsible section
- [ ] Update when groups created/deleted/renamed
- [ ] Drag to reorder groups (visual order)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/ui/group_list_panel.gd` (new)
- `addons/dialogue_editor/scripts/node_palette.gd` (integrate)
- `addons/dialogue_editor/scenes/main_panel.tscn` (layout)

**Success Criteria:**
- [ ] Groups listed in palette
- [ ] Click group jumps to its location
- [ ] Can collapse/expand from list
- [ ] List updates in real-time

---

### Feature 4D.5: Auto-Group by Speaker

**Description:** Automatically create groups based on speaker or conversation topic.

**Dependencies:** Feature 4D.1

**Implementation Tasks:**
- [ ] Add "Auto-Group" button to toolbar/menu
- [ ] Implement grouping strategies:
  - [ ] By Speaker: Group nodes by dominant speaker
  - [ ] By Branch: Group each major branch path
  - [ ] By Selection: Group currently selected nodes
- [ ] Create dialog to choose strategy
- [ ] Generate non-overlapping group layouts
- [ ] Assign colors automatically (one per speaker/branch)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/groups/auto_grouper.gd` (new)
- `addons/dialogue_editor/scripts/main_panel.gd` (menu item)

**Success Criteria:**
- [ ] Auto-group by speaker creates logical groups
- [ ] Groups don't overlap
- [ ] Each speaker gets distinct color
- [ ] Can undo auto-grouping

---

## Phase 4E: Localization Support

**Goal:** Enable multi-language dialogue with string table export/import.

**Exit Criteria:** Writer can export strings, have them translated, import back, and preview in any language.

---

### Feature 4E.1: Localization Key Generation

**Description:** Automatically generate stable localization keys for all text fields.

**Implementation Tasks:**
- [ ] Create `localization_manager.gd` with:
  - [ ] Key format: `{dialogue_id}.{node_id}.{field}` (e.g., `tavern_greeting.Speaker_1.text`)
  - [ ] Key stability: same key for same content across saves
  - [ ] Regenerate key only when node is recreated (new ID)
- [ ] Store localization keys in node data
- [ ] Add `localization_enabled` flag to dialogue metadata
- [ ] Generate keys on save if enabled

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/localization/localization_manager.gd` (new)
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` (add key storage)
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` (store text key)
- `addons/dialogue_editor/scripts/nodes/choice_node.gd` (store text key)

**Success Criteria:**
- [ ] Keys generated for all text fields
- [ ] Keys stable across saves (unless node recreated)
- [ ] Keys follow predictable format
- [ ] Can enable/disable localization per dialogue

---

### Feature 4E.2: String Table Export

**Description:** Export all localizable strings to CSV or PO format.

**Dependencies:** Feature 4E.1

**Implementation Tasks:**
- [ ] Create `string_table_exporter.gd`:
  - [ ] CSV export with columns: key, context, char_limit, en, [other languages]
  - [ ] PO (gettext) format export
  - [ ] JSON format export
- [ ] Create export dialog:
  - [ ] Format selection (CSV/PO/JSON)
  - [ ] Languages to include
  - [ ] Options: include context, include char limits
  - [ ] Output path selection
- [ ] Extract context from surrounding nodes (previous speaker text)
- [ ] Add char limit from text field max length
- [ ] Add Export → String Table menu item

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/localization/string_table_exporter.gd` (new)
- `addons/dialogue_editor/scripts/main_panel.gd` (menu, dialog)

**Success Criteria:**
- [ ] Can export CSV with all strings
- [ ] Context comments helpful for translators
- [ ] Character limits included
- [ ] CSV opens correctly in Excel/Sheets

---

### Feature 4E.3: String Table Import

**Description:** Import translated strings back into the editor.

**Dependencies:** Feature 4E.1, 4E.2

**Implementation Tasks:**
- [ ] Extend `localization_manager.gd` for import:
  - [ ] Parse CSV/PO/JSON files
  - [ ] Match keys to nodes
  - [ ] Store translations in dialogue data
- [ ] Create import dialog:
  - [ ] File selection
  - [ ] Preview of changes
  - [ ] Conflict resolution (key mismatch)
  - [ ] Language column mapping
- [ ] Handle missing keys (new nodes since export)
- [ ] Handle orphan keys (deleted nodes since export)
- [ ] Add Import → String Table menu item

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/localization/localization_manager.gd` (extend)
- `addons/dialogue_editor/scripts/main_panel.gd` (menu, dialog)
- `addons/dialogue_editor/scripts/dialogue_tree_data.gd` (store translations)

**Success Criteria:**
- [ ] Can import CSV with translations
- [ ] Translations stored in dialogue file
- [ ] Warns about missing/orphan keys
- [ ] Preview shows what will change

---

### Feature 4E.4: Language Preview

**Description:** Switch preview language in editor to see translated text.

**Dependencies:** Feature 4E.3

**Implementation Tasks:**
- [ ] Add language dropdown to toolbar:
  - [ ] Show available languages (from imported translations)
  - [ ] Default to primary language (EN)
  - [ ] Persist selection during session
- [ ] Update node display for selected language:
  - [ ] Speaker node shows translated text
  - [ ] Choice node shows translated text
  - [ ] Fall back to primary if translation missing
- [ ] Update property panel preview for language
- [ ] Update test mode to use selected language
- [ ] Highlight missing translations (different color/icon)

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/localization/language_preview.gd` (new)
- `addons/dialogue_editor/scripts/main_panel.gd` (toolbar dropdown)
- `addons/dialogue_editor/scripts/nodes/speaker_node.gd` (display translation)
- `addons/dialogue_editor/scripts/nodes/choice_node.gd` (display translation)
- `addons/dialogue_editor/scripts/property_panel.gd` (preview language)
- `addons/dialogue_editor/scripts/dialogue_runner.gd` (test in language)

**Success Criteria:**
- [ ] Language dropdown shows available languages
- [ ] Selecting language updates all node text
- [ ] Missing translations highlighted
- [ ] Test mode uses selected language

---

### Feature 4E.5: Localization in Export

**Description:** Update JSON export to use localization keys.

**Dependencies:** Feature 4E.1

**Implementation Tasks:**
- [ ] Update `dialogue_exporter.gd`:
  - [ ] Export mode: "keys" (localization keys) or "text" (raw text)
  - [ ] When using keys, `text` field contains key string
  - [ ] Add `localized: true` flag to export metadata
- [ ] Create companion translation file export:
  - [ ] Export all languages to single JSON
  - [ ] Format compatible with Godot TranslationServer
- [ ] Document export format for game integration

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/dialogue_exporter.gd` (extend)

**Success Criteria:**
- [ ] Export can output localization keys
- [ ] Game can look up keys in translation files
- [ ] Companion translation file usable by TranslationServer

---

### Feature 4E.6: Translation Progress Tracking

**Description:** Show translation completion status and highlight untranslated strings.

**Dependencies:** Feature 4E.3, 4E.4

**Implementation Tasks:**
- [ ] Add translation progress indicator to status bar:
  - [ ] "ES: 45/50 (90%)" format per language
  - [ ] Click to see details
- [ ] Create translation status panel:
  - [ ] List of languages with completion percentage
  - [ ] Click language to see missing strings
  - [ ] Click string to jump to node
- [ ] Highlight untranslated nodes on canvas:
  - [ ] Small icon or colored border
  - [ ] Only when viewing that language
- [ ] Add "Show Untranslated Only" filter

**Files to Create/Modify:**
- `addons/dialogue_editor/scripts/localization/translation_tracker.gd` (new)
- `addons/dialogue_editor/scripts/main_panel.gd` (status bar, panel)
- `addons/dialogue_editor/scripts/dialogue_canvas.gd` (highlight)

**Success Criteria:**
- [ ] Status bar shows translation progress
- [ ] Can see list of untranslated strings
- [ ] Can jump to untranslated nodes
- [ ] Clear visual indicator on untranslated nodes

---

## Dependencies

| Dependency | Required By | Notes |
|------------|-------------|-------|
| Expression Parser | 4B.3, 4B.4, 4C.2 | Core of expression system |
| Tag Parser | 4C.2, 4C.3 | Core of text tag system |
| Template Manager | 4A.2, 4A.3, 4A.4, 4A.5 | Template operations |
| Localization Manager | 4E.2, 4E.3, 4E.4, 4E.5 | Localization operations |
| Variable Browser | 4B.6, 4C.5 | Test value management |

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Expression parser complexity | High | Start with subset (no functions), add incrementally |
| Breaking existing dialogues | High | Migration path for old Branch node format |
| Localization key stability | Medium | Hash content for key stability, document key policy |
| Group collision detection | Medium | Simple bounds checking, manual adjustment |
| Performance with many groups | Low | Lazy rendering, collapse groups by default |

---

## Progress Tracking

### Phase 4A: Templates ✅ COMPLETE
- [x] Feature 4A.1: Template Data Format ✅
- [x] Feature 4A.2: Save Selection as Template ✅
- [x] Feature 4A.3: Insert Template ✅
- [x] Feature 4A.4: Built-in Template Library ✅
- [x] Feature 4A.5: Template Library Panel ✅

### Phase 4B: Expressions ✅ COMPLETE
- [x] Feature 4B.1: Expression Lexer ✅
- [x] Feature 4B.2: Expression Parser ✅
- [x] Feature 4B.3: Expression Evaluator ✅
- [x] Feature 4B.4: Expression Editor UI ✅
- [x] Feature 4B.5: Update Branch Node (Dual-Mode) ✅
- [x] Feature 4B.6: Variable Browser Panel ✅
- [x] Feature 4B.7: Set Expression Node ✅

### Phase 4C: Conditional Text
- [x] Feature 4C.1: Variable Tag Parser ✅
- [x] Feature 4C.2: Conditional Tag Parser ✅
- [ ] Feature 4C.3: Tag Renderer
- [ ] Feature 4C.4: Formatting Tags
- [ ] Feature 4C.5: Text Preview in Property Panel
- [ ] Feature 4C.6: Export with Tags

### Phase 4D: Node Grouping
- [ ] Feature 4D.1: Visual Node Groups
- [ ] Feature 4D.2: Group Operations
- [ ] Feature 4D.3: Collapsible Groups
- [ ] Feature 4D.4: Group Panel in Palette
- [ ] Feature 4D.5: Auto-Group by Speaker

### Phase 4E: Localization
- [ ] Feature 4E.1: Localization Key Generation
- [ ] Feature 4E.2: String Table Export
- [ ] Feature 4E.3: String Table Import
- [ ] Feature 4E.4: Language Preview
- [ ] Feature 4E.5: Localization in Export
- [ ] Feature 4E.6: Translation Progress Tracking

---

**Total Features:** 29 across 5 sub-phases

**To implement a feature, run:**
```
/tool-feature-implementer Feature 4X.Y from Dialogue Tree Editor Phase 4
```
