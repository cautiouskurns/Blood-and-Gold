---
name: prototype-roadmap-planner
description: Read a prototype GDD and generate a phased implementation roadmap with concrete tasks, organized by implementation phases with specific deliverables and test criteria.
domain: project
type: planner
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Glob
---

# Prototype Roadmap Planner Skill

This skill reads a prototype GDD and generates a detailed implementation roadmap. It extracts implementation phases from the GDD, breaks down each phase into concrete tasks, and creates a day-by-day or hour-by-hour development plan for rapid prototyping.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "create roadmap for prototype"
- Asks "plan implementation for prototype"
- Wants to break down prototype into actionable tasks
- Has a prototype GDD and needs a development plan
- Says "what's my implementation plan?" or "what should I build first?"
- Wants a day-by-day breakdown of prototype work

---

## Core Principle

**Roadmaps turn design into action**:
- ✅ Extract implementation phases from prototype GDD
- ✅ Break each phase into concrete, testable tasks
- ✅ Create hour-by-hour or day-by-day timeline
- ✅ Define clear deliverables and test criteria for each phase
- ✅ Prioritize tasks to get playable core loop as fast as possible
- ✅ Roadmap is actionable, not abstract

---

## Visible-First Ordering Philosophy

**Build what you can SEE before what you can't.**

Traditional development often goes: Data → Systems → Features → UI. For prototypes, **invert this**:

```
VISIBLE-FIRST ORDER:
1. Visual elements (sprites, scenes, UI) ← See it first
2. Player interaction (input, feedback)  ← Feel it second
3. Core systems (logic, rules)           ← Make it work
4. Data structures (resources, configs)  ← Refine later
5. Polish (juice, effects)               ← Last
```

**Why Visible-First?**
- **Observable progress**: Seeing sprites move on screen motivates more than seeing console logs
- **Early feedback**: Spot design problems when you can see the game, not just read data
- **Testable sooner**: Playtest with placeholder logic, not placeholder visuals
- **Avoid over-engineering**: Build only the systems you actually need for what you see

**Example - Grid Combat:**

❌ Traditional Order (invisible progress):
1. Create grid data structure
2. Create pathfinding algorithm
3. Create unit stats system
4. Create UI to display it all
5. Finally see something

✅ Visible-First Order (observable progress):
1. Create grid visual (TileMap or sprites) ← See the board
2. Create unit sprites that can be placed ← See the pieces
3. Create click-to-select, click-to-move  ← Feel interaction
4. Add pathfinding for valid moves        ← Make it smart
5. Add stats and damage calculation       ← Make it meaningful

**At each step, you can SEE and FEEL progress.**

### Ordering Rules

1. **Scenes before scripts**: Create the visual scene structure first, add behavior second
2. **Sprites before data**: Use placeholder sprites immediately, define stat Resources later
3. **Hardcode before configure**: Hardcode values to get it working, extract to data files later
4. **Input before logic**: Get player clicking/pressing first, add game rules second
5. **Feedback before polish**: Show that something happened (even ugly), make it pretty later

### Dependency Mapping (Visible-First)

When mapping task dependencies, follow this order:

```
Phase 1: Core Visuals
├── Scene structure (Main.tscn, Game.tscn)
├── Player/unit sprites visible
├── Basic camera/viewport
└── Placeholder UI elements

Phase 2: Core Interaction
├── Input handling (click, WASD)
├── Visual feedback (selection, movement)
├── State changes visible (health bars, etc.)
└── Basic sound effects (optional)

Phase 3: Core Systems
├── Game logic (turn order, combat rules)
├── Data integration (stats affect outcomes)
├── Win/lose conditions
└── State management

Phase 4: Data & Balance
├── Extract hardcoded values to Resources
├── Create data files (JSON, .tres)
├── Balance pass (tune numbers)
└── Configuration systems

Phase 5: Polish
├── Animations and transitions
├── Juice (screenshake, particles)
├── UI polish
└── Audio polish
```

---

## Roadmap Output Structure

The skill generates a detailed, task-oriented roadmap:

```markdown
# [GAME TITLE] - Prototype Implementation Roadmap

**Based On:** Prototype GDD v[X.Y]
**Timeline:** [X days from GDD]
**Target:** [Core question from GDD]
**Created:** [Date]

---

## Quick Start

**Critical Path to Playable Core Loop:**
1. [Most important task from Phase 1]
2. [Most important task from Phase 1]
3. [First test milestone - "can play one round"]

**Estimated time to playable:** [X hours]

---

## Phase 1: [Phase Name] ([Timeline] - [X hours])

**Goal:** [What you're building - from GDD]

**Deliverables:**
- [Deliverable 1 from GDD]
- [Deliverable 2 from GDD]

**Test Criteria:** [How you know it works - from GDD]

### Tasks

#### Task 1.1: [Clear Action Verb] [Specific Thing]
**Time:** [X hours]

**What:** [One sentence describing the visible/testable outcome]

**How:**
- [Implementation step 1]
- [Implementation step 2]
- [Implementation step 3]

**Acceptance:**
- [ ] [Specific testable criterion - observable]
- [ ] [Specific testable criterion - observable]

**Files:**
- `[file path]` - [purpose]
- `[file path]` - [purpose]

**Hardcoded Values:**
- [Value name]: [value] (e.g., movement_speed: 200)
- [Value name]: [value]

**Dependencies:** None / [Task X.Y must be complete]

---

#### Task 1.2: [Clear Action Verb] [Specific Thing]
**Time:** [X hours]

**What:** [One sentence describing the visible/testable outcome]

**How:**
- [Implementation step 1]
- [Implementation step 2]

**Acceptance:**
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]

**Files:**
- `[file path]` - [purpose]

**Hardcoded Values:**
- [Value name]: [value]

**Dependencies:** [Task 1.1]

---

[Continue for all tasks in phase]

**Phase 1 Checkpoint:**
- [ ] All deliverables complete
- [ ] Test criteria passed: [test description]
- [ ] Ready to proceed to Phase 2

---

## Phase 2: [Phase Name] ([Timeline] - [X hours])

**Goal:** [What you're building - from GDD]

**Deliverables:**
- [Deliverable 1 from GDD]
- [Deliverable 2 from GDD]

**Test Criteria:** [How you know it works - from GDD]

### Tasks

[Same structure as Phase 1]

**Phase 2 Checkpoint:**
- [ ] All deliverables complete
- [ ] Test criteria passed: [test description]
- [ ] Ready to proceed to Phase 3

---

[Continue for all phases from GDD]

---

## Testing & Validation

**After Each Phase:**
- [ ] Run test criteria from phase
- [ ] Document any issues/blockers
- [ ] Adjust timeline if behind schedule

**Final Prototype Test (End of Timeline):**
- [ ] Can complete full playthrough
- [ ] Critical questions from GDD answerable
- [ ] Playtesters can understand core loop
- [ ] Success metrics measurable

---

## Risk Mitigation Plan

**From GDD Risk Section:**

**Risk:** [Risk from GDD]
**If This Happens:** [Fallback from GDD]
**Action Items:**
- [Specific task to mitigate]
- [Specific task to implement fallback]

[Repeat for each risk from GDD]

---

## Daily Schedule (for [X]-day timeline)

### Day 1: [Date]
**Focus:** [Phase name]
- Morning (4h): [Tasks]
- Afternoon (4h): [Tasks]
**End of Day Goal:** [Deliverable]

### Day 2: [Date]
**Focus:** [Phase name]
- Morning (4h): [Tasks]
- Afternoon (4h): [Tasks]
**End of Day Goal:** [Deliverable]

[Continue for each day]

---

## Content Checklist

**Assets to Create:**
- [ ] [Asset 1 from GDD content scope]
- [ ] [Asset 2 from GDD content scope]

**Data/Balance:**
- [ ] [Stats for units/enemies from GDD]
- [ ] [Configuration values]

---

**END OF ROADMAP**

**Next Steps:**
1. Review this roadmap
2. Set up development environment
3. Start Phase 1, Task 1.1
4. Test frequently, adjust timeline as needed
```

---

## Workflow

### Step 1: Read Prototype GDD

1. **Find the prototype GDD:**
   - Look for `docs/*prototype-gdd*.md` or ask user for path
   - Read the entire GDD

2. **Extract key information:**
   - Timeline (weekend/week/month from GDD)
   - Critical questions being tested
   - Implementation phases (from "Implementation Phases" section)
   - Each phase's goal, deliverables, test criteria
   - Content scope (units, mechanics, etc.)
   - Risk mitigation plans
   - Success metrics

---

### Step 2: Break Down Each Phase into Tasks

**For each implementation phase in the GDD:**

1. **Extract phase metadata:**
   - Phase name and timeline (e.g., "Day 1, Morning - 4h")
   - Goal statement
   - Deliverables list
   - Test criteria

2. **Infer concrete tasks from deliverables:**
   - Each deliverable becomes 1-3 tasks
   - Tasks should be 1-3 hours each (small enough to track progress)
   - Tasks should have clear acceptance criteria

**Example:**
GDD Deliverable: "WASD movement, one weapon, enemy spawning"

Becomes tasks:
- Task 1.1: Player Character with WASD Movement (2h)
- Task 1.2: Basic Weapon Auto-Fire System (1.5h)
- Task 1.3: Enemy Spawner and Basic Enemy (1.5h)

3. **Define acceptance criteria:**
   - What specific behaviors must work
   - How to test it
   - Observable success conditions

**Example:**
Task 1.1: Player Character with WASD Movement
Acceptance Criteria:
- [ ] Player sprite appears in center of screen
- [ ] W/A/S/D keys move player in correct directions
- [ ] Movement speed is 200 px/s
- [ ] Player cannot move off-screen

4. **Identify file paths:**
   - Where will code live (scripts/player/player.gd)
   - What scenes to create (scenes/player/Player.tscn)
   - Based on project structure and GDD organization

5. **Map dependencies (Visible-First):**
   - Which tasks must complete before others
   - Follow visible-first order: visuals → interaction → systems → data → polish
   - Prioritize tasks that produce observable results early

---

### Step 3: Create Critical Path

**Identify the shortest path to playable core loop:**
- Which tasks MUST complete to test the core mechanic?
- What's the absolute minimum to get "one round" working?
- Usually 3-5 tasks from Phase 1

**Output as "Quick Start" section:**
```
Critical Path to Playable Core Loop:
1. Player movement (Task 1.1)
2. Enemy spawning (Task 1.3)
3. Basic combat (Task 1.2)
Estimated time to playable: 5 hours
```

---

### Step 4: Generate Daily Schedule

**For short timelines (weekend/week):**
- Break phases into day-by-day chunks
- Assign tasks to morning/afternoon blocks
- Set end-of-day goals (deliverables)

**Example for weekend timeline:**
```
Day 1:
- Morning: Phase 1 (Core Loop Foundation)
- Afternoon: Phase 2 (Economy System)
End of Day Goal: Can place units and earn gold

Day 2:
- Morning: Phase 3 (Full Content)
- Afternoon: Phase 4 (Wave Progression)
End of Day Goal: Full 10-wave game loop works

Day 3:
- All day: Phase 5 (Polish & Juice)
End of Day Goal: Prototype ready for playtesting
```

---

### Step 5: Extract Content Checklist

**From GDD's "Content Scope" section:**
- List all units/enemies/items to create
- Extract stats and attributes
- Create checklist format

**Example:**
```
Content Checklist:
- [ ] Goblin (15g, 30 HP, 5 ATK)
- [ ] Skeleton (25g, 40 HP, 8 ATK)
- [ ] Warrior Hero (50 HP, 10 ATK, 20g drop)
```

---

### Step 6: Map Risk Mitigation to Tasks

**From GDD's "Risk Mitigation" section:**
- Each risk becomes potential task
- Mitigation = proactive task (do during normal dev)
- Fallback = conditional task (do if risk occurs)

**Example:**
```
Risk: Auto-battle too fast/confusing
Mitigation Task: Add damage numbers and 1-2s combat pacing (Phase 5, Task 5.2)
Fallback Task: Add "Pause" button during combat (conditional - if playtest reveals issue)
```

---

### Step 7: Save Roadmap

**Save to:** `docs/[game-name]-prototype-roadmap.md`

**Output to user:**
```
Created prototype roadmap with:
- [X] phases over [timeline]
- [X] concrete tasks
- Day-by-day schedule
- Critical path to playable in [X] hours

Next steps:
1. Review roadmap: docs/[game]-prototype-roadmap.md
2. Set up dev environment
3. Start Phase 1, Task 1.1
4. Test after each task, track progress
```

---

## Example Interaction

**User:** "Create roadmap for prototype"

**Skill:**
```
Reading prototype GDD...

Found: docs/dungeon-investor-prototype-gdd.md
- Weekend timeline (2-3 days)
- 5 implementation phases defined
- Testing: Economic auto-battle dungeon defense
- Goal: Answer 5 critical questions

Breaking down phases into tasks...

Phase 1: Core Loop Foundation (Day 1 AM, 4-5h)
- 3 tasks (Player setup, Drag-drop, Auto-battle)

Phase 2: Economy System (Day 1 PM, 3-4h)
- 4 tasks (Gold UI, Shop, Cost system, Payouts)

Phase 3: Full Content (Day 2 AM, 4-5h)
- 3 tasks (5 monsters, 3 traps, 3 heroes)

Phase 4: Wave Progression (Day 2 PM, 3-4h)
- 4 tasks (Wave system, Scaling, Win/lose, Restart)

Phase 5: Polish & Juice (Day 3, 4-6h)
- 5 tasks (Damage numbers, Animations, UI clarity, etc.)

Generating daily schedule...

Day 1: Core Loop + Economy → playable with gold system
Day 2: Full Content + Waves → complete 10-wave loop
Day 3: Polish → ready for playtesting

Critical path to playable: 5 hours (3 tasks from Phase 1)

Roadmap saved to: docs/dungeon-investor-prototype-roadmap.md

Total: 19 tasks across 5 phases over 3 days
Ready to start development!
```

---

## Integration with Other Skills

### Reads From:
- `prototype-gdd-generator` - Input GDD defining the prototype

### Feeds Into:
- `changelog-updater` - Track progress as tasks complete
- `systems-bible-updater` - Document systems as they're built

### Works With:
- `version-control-helper` - Manage commits per task/phase
- `gdscript-quality-checker` - Review code quality after each phase

---

## Quality Checklist

Before finalizing roadmap:

**Ordering & Structure:**
- ✅ Follows visible-first ordering (visuals → interaction → systems → data → polish)
- ✅ Early tasks produce observable results (not invisible infrastructure)
- ✅ All phases from GDD are included
- ✅ Critical path identified (shortest route to playable)

**Task Quality:**
- ✅ Each task uses 5-part format (What, How, Acceptance, Files, Hardcoded Values)
- ✅ Tasks are 1-3 hours each (trackable progress)
- ✅ Each phase broken into concrete, testable tasks
- ✅ Detail level is actionable but not over-specified
- ✅ Hardcoded values listed (to extract to data later)

**Coverage:**
- ✅ Daily schedule created for timeline
- ✅ All deliverables from GDD mapped to tasks
- ✅ Test criteria from GDD included in checkpoints
- ✅ Content checklist extracted from GDD scope
- ✅ Risk mitigation mapped to tasks

---

## Key Principles

**DO:**
- ✅ **Visible-first ordering**: Scenes → Interaction → Systems → Data → Polish
- ✅ Extract phases directly from GDD (don't invent new structure)
- ✅ Break deliverables into concrete, actionable tasks
- ✅ Include specific file paths and acceptance criteria
- ✅ Use 5-part task format: What, How, Acceptance, Files, Hardcoded Values
- ✅ Create testable checkpoints after each phase
- ✅ Identify critical path to playable core loop
- ✅ Map risks to mitigation tasks
- ✅ Hardcode values first, extract to Resources later

**DON'T:**
- ❌ Start with data structures before visuals (invisible progress)
- ❌ Build systems before you can see them working
- ❌ Add tasks not related to GDD deliverables
- ❌ Make tasks too large (>3 hours is too big)
- ❌ Skip test criteria or acceptance criteria
- ❌ Ignore dependencies between tasks
- ❌ Create vague tasks ("make it better")
- ❌ Over-specify tasks (save code details for implementation)
- ❌ Assume file structure (use project's actual structure)

---

## Task Breakdown Guidelines

### From GDD Deliverable to Tasks

**GDD says:** "WASD movement, one weapon, enemy spawning"

**Becomes:**
1. **Task: Player Character Setup**
   - Create Player.tscn scene
   - Create player.gd script with CharacterBody2D
   - Implement WASD input handling
   - Set movement speed to 200 px/s
   - Test: Player moves in all 4 directions

2. **Task: Basic Weapon System**
   - Create Weapon.gd script
   - Implement auto-fire timer
   - Spawn projectiles on timer tick
   - Test: Weapon fires automatically every second

3. **Task: Enemy Spawner**
   - Create Enemy.tscn scene
   - Create spawner.gd script
   - Spawn enemy every 3 seconds
   - Test: Enemies appear and move toward player

### Task Size Guidelines

**Good task sizes:**
- 1-3 hours of focused work
- Single responsibility (one system or feature)
- Testable in isolation
- Clear done criteria

**Too large:**
- "Implement combat system" (4-8 hours, multiple systems)
- Split into: damage calculation, health system, hit detection

**Too small:**
- "Add constant for move speed" (<15 min)
- Combine with larger task

---

## Feature Description Detail Level

Each task in the roadmap needs enough detail to be **actionable without ambiguity**, but not so much that it becomes a full specification. Use this framework:

### The 5-Part Task Description

Every task description should include these five elements:

```markdown
#### Task X.Y: [Clear Action Verb] [Specific Thing]

**What:** One sentence describing the visible/testable outcome.

**How:** 3-5 bullet points of implementation steps.

**Acceptance:** 2-4 checkbox criteria that prove it works.

**Files:** List of files to create or modify.

**Hardcoded Values:** Any magic numbers to use (extract to data later).
```

### Detail Level Examples

#### Too Vague (Unusable)
```markdown
#### Task 1.1: Add player movement
Create player movement system.
```
❌ What kind of movement? Grid? Free? How fast? What input?

#### Too Detailed (Over-specified)
```markdown
#### Task 1.1: Add player movement
Create a CharacterBody2D-based player controller using the
built-in input map system. The player should use a state
machine with Idle, Walking, and Running states. Movement
should use velocity-based physics with acceleration of
800 px/s² and deceleration of 1200 px/s². Maximum walk
speed is 150 px/s and run speed is 280 px/s when holding
Shift. Implement 8-directional movement with diagonal
normalization. Add dust particles when changing direction...
```
❌ This is a specification, not a roadmap task. Save this for implementation.

#### Just Right (Actionable)
```markdown
#### Task 1.1: Player Grid Movement

**What:** Player character moves between grid tiles using arrow keys/WASD.

**How:**
- Create Player.tscn with Sprite2D and CollisionShape2D
- Add player.gd with input handling
- Move one tile per keypress (no diagonal for now)
- Animate tween between tiles (0.2s duration)

**Acceptance:**
- [ ] Player sprite visible on grid
- [ ] Arrow keys move player one tile in pressed direction
- [ ] Player cannot move outside grid boundaries
- [ ] Movement has smooth tween animation

**Files:**
- `scenes/player/Player.tscn`
- `scripts/player/player.gd`

**Hardcoded Values:**
- Grid size: 64x64 pixels per tile
- Movement duration: 0.2 seconds
- Grid bounds: 12x12 tiles
```
✅ Clear what to build, how to approach it, how to test it, specific enough to start immediately.

### Detail Level by Task Type

#### Visual/Scene Tasks (High Visual Detail)
Focus on: What it looks like, where things are positioned, placeholder assets to use

```markdown
#### Task 2.1: Combat Grid Display

**What:** 12x12 grid visible in center of screen with distinct tiles.

**How:**
- Create CombatGrid.tscn with TileMapLayer
- Use placeholder tile (64x64 colored squares)
- Light tiles for walkable, dark for obstacles
- Center grid in viewport (1920x1080)

**Acceptance:**
- [ ] Grid renders 12x12 tiles
- [ ] Grid is centered on screen
- [ ] Walkable vs obstacle tiles visually distinct
- [ ] Grid scale appropriate (fills ~60% of screen width)

**Hardcoded Values:**
- Tile size: 64x64 pixels
- Walkable color: #4a5568
- Obstacle color: #1a202c
```

#### Interaction Tasks (High Behavior Detail)
Focus on: What input does, what feedback player sees

```markdown
#### Task 2.3: Unit Selection System

**What:** Click on friendly unit to select it, showing selection indicator.

**How:**
- Add Area2D with input detection to Unit.tscn
- Create selection_indicator.tscn (sprite or shader outline)
- Track currently_selected_unit in CombatManager
- Click empty tile or enemy = deselect

**Acceptance:**
- [ ] Clicking unit shows selection indicator
- [ ] Only one unit selected at a time
- [ ] Clicking elsewhere deselects
- [ ] Selected unit info appears in UI panel

**Hardcoded Values:**
- Selection indicator: Yellow outline, 2px
- Click detection radius: 32 pixels
```

#### System/Logic Tasks (High Rule Detail)
Focus on: Rules, formulas, edge cases

```markdown
#### Task 3.2: Attack Damage Calculation

**What:** When unit attacks, calculate and apply damage using stats.

**How:**
- Create damage_calculator.gd utility
- Formula: damage = attack_power - (defense / 2)
- Minimum damage: 1 (always deal at least 1)
- Apply damage to target's current_hp
- Emit signal when unit dies (hp <= 0)

**Acceptance:**
- [ ] Attack reduces target HP by calculated amount
- [ ] Defense reduces incoming damage
- [ ] Minimum 1 damage dealt even vs high defense
- [ ] Unit removed from grid when HP reaches 0

**Hardcoded Values:**
- Defense divisor: 2
- Minimum damage: 1
- Test values: Attacker (ATK 10) vs Defender (DEF 4) = 8 damage
```

#### Data/Resource Tasks (High Structure Detail)
Focus on: Data shape, field names, example values

```markdown
#### Task 4.1: Unit Stats Resource

**What:** Create Resource class to hold unit statistics.

**How:**
- Create UnitStats.gd extending Resource
- Export variables for: hp, attack, defense, move_range, attack_range
- Create 3 example .tres files (Soldier, Archer, Knight)
- Update Unit.tscn to use UnitStats resource

**Acceptance:**
- [ ] UnitStats resource class exists
- [ ] Can create .tres files with stats in editor
- [ ] Unit.tscn has exported UnitStats variable
- [ ] Changing .tres values affects unit behavior

**Example Data:**
- Soldier: HP 30, ATK 8, DEF 4, Move 3, Range 1
- Archer: HP 20, ATK 10, DEF 2, Move 3, Range 5
- Knight: HP 50, ATK 6, DEF 8, Move 2, Range 1
```

### What NOT to Include in Task Descriptions

❌ **Don't include:**
- Full code implementations (that's for coding time)
- Design justifications (that's in the GDD)
- Alternative approaches (pick one, note alternatives in comments if needed)
- Polish details (animations, particles, sounds - save for polish phase)
- Edge cases you haven't thought through yet

✅ **Do include:**
- Enough to start coding immediately
- Clear done criteria
- Specific numbers (even if they'll change later)
- File locations
- Dependencies on other tasks

---

## Example Output Structure

### Example 1: Dungeon Investor (Visible-First Ordering)

**Phase 1: Core Visuals & Scene (Day 1 Morning)**
- Task 1.1: Dungeon Room Grid Display (1h) ← SEE the board first
- Task 1.2: Monster/Trap Placeholder Sprites (30min) ← SEE units
- Task 1.3: Hero Placeholder Sprites (30min) ← SEE enemies
- Task 1.4: Gold Counter UI Element (30min) ← SEE economy

**Phase 2: Core Interaction (Day 1 Afternoon)**
- Task 2.1: Drag-Drop Monster Placement (1.5h) ← FEEL placement
- Task 2.2: Shop Panel with Clickable Items (1h) ← FEEL purchasing
- Task 2.3: Hero Spawning and Walking (1h) ← SEE heroes enter

**Phase 3: Core Systems (Day 2 Morning)**
- Task 3.1: Basic Auto-Battle Combat (1.5h) ← Combat logic
- Task 3.2: Purchase/Refund Gold Logic (1h) ← Economy logic
- Task 3.3: Hero Death → Gold Earned (30min) ← Reward loop
- Task 3.4: Wave Counter System (1h) ← Progression

**Phase 4: Content & Data (Day 2 Afternoon)**
- Task 4.1: Monster Stats Resource Class (30min)
- Task 4.2: Implement 5 Monster Variants (1.5h)
- Task 4.3: Implement 3 Trap Variants (1h)
- Task 4.4: Hero Stat Scaling Per Wave (30min)

**Phase 5: Polish (Day 3)**
- Task 5.1: Damage Numbers Floating Text (1h)
- Task 5.2: Death Animations (1h)
- Task 5.3: UI Clarity Pass (1h)
- Task 5.4: Win/Lose Screens (1h)

**Notice the ordering:**
- Phase 1: Everything visual (you can SEE the game board)
- Phase 2: Everything interactive (you can CLICK and DRAG)
- Phase 3: Everything logical (it starts WORKING)
- Phase 4: Everything data-driven (it becomes BALANCED)
- Phase 5: Everything polished (it feels GOOD)

### Example 2: Grid Combat (Visible-First Ordering)

**Phase 1: Visual Foundation (4h)**
- Task 1.1: Combat Grid TileMap (1h) ← SEE the battlefield
- Task 1.2: Unit Sprites on Grid (1h) ← SEE the pieces
- Task 1.3: HP Bars Above Units (1h) ← SEE health state
- Task 1.4: Turn Order UI Panel (1h) ← SEE who acts next

**Phase 2: Interaction Layer (4h)**
- Task 2.1: Click to Select Unit (1h) ← FEEL selection
- Task 2.2: Highlight Valid Move Tiles (1h) ← SEE options
- Task 2.3: Click to Move Unit (1h) ← FEEL movement
- Task 2.4: Click Enemy to Attack (1h) ← FEEL combat

**Phase 3: Game Logic (4h)**
- Task 3.1: Turn Order Calculation (1h)
- Task 3.2: Movement Range Validation (1h)
- Task 3.3: Attack Damage Calculation (1h)
- Task 3.4: Death and Victory Conditions (1h)

**Phase 4: Data Extraction (2h)**
- Task 4.1: UnitStats Resource Class (30min)
- Task 4.2: Create Unit .tres Files (30min)
- Task 4.3: Extract Hardcoded Values (30min)
- Task 4.4: Balance Pass (30min)

**Phase 5: Polish (2h)**
- Task 5.1: Movement Animation Tweens (30min)
- Task 5.2: Attack Animation (30min)
- Task 5.3: Damage Number Popups (30min)
- Task 5.4: Turn Transition Effects (30min)

Each task includes:
- Time estimate
- What/How/Acceptance criteria
- File paths
- Dependencies
- Hardcoded values

---

## Timeline Formats

### Weekend (2-3 days)
- Day-by-day breakdown
- Morning/afternoon blocks
- Hourly estimates
- End-of-day goals

### Week (5-7 days)
- Day-by-day breakdown
- Daily focus areas
- Half-day blocks
- Milestone at midpoint and end

### Two Weeks
- Week 1 / Week 2 breakdown
- Daily goals within weeks
- Weekly milestones
- Buffer time for iteration

### Month
- Weekly breakdown
- Phase-level milestones
- More flexible daily structure
- Regular playtest checkpoints

---

This skill transforms a prototype GDD into an **actionable, task-oriented roadmap** with concrete steps, time estimates, and testable checkpoints. It's designed for rapid prototyping where speed and clarity are critical.
