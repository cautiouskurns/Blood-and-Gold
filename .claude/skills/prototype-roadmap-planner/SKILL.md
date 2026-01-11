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

#### Task 1.1: [Task Name]
**Estimated Time:** [X hours]
**Description:** [What to build]
**Acceptance Criteria:**
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]

**Files to Create/Modify:**
- `[file path]` - [purpose]
- `[file path]` - [purpose]

**Dependencies:** None / [Task X.Y must be complete]

---

#### Task 1.2: [Task Name]
**Estimated Time:** [X hours]
**Description:** [What to build]
**Acceptance Criteria:**
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]

**Files to Create/Modify:**
- `[file path]` - [purpose]

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

5. **Map dependencies:**
   - Which tasks must complete before others
   - Typically: data structures → systems → content → polish

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
- ✅ All phases from GDD are included
- ✅ Each phase broken into concrete, testable tasks
- ✅ Tasks are 1-3 hours each (trackable progress)
- ✅ Critical path identified (shortest route to playable)
- ✅ Daily schedule created for timeline
- ✅ All deliverables from GDD mapped to tasks
- ✅ Test criteria from GDD included in checkpoints
- ✅ Content checklist extracted from GDD scope
- ✅ Risk mitigation mapped to tasks

---

## Key Principles

**DO:**
- ✅ Extract phases directly from GDD (don't invent new structure)
- ✅ Break deliverables into concrete, actionable tasks
- ✅ Include specific file paths and acceptance criteria
- ✅ Create testable checkpoints after each phase
- ✅ Identify critical path to playable core loop
- ✅ Map risks to mitigation tasks

**DON'T:**
- ❌ Add tasks not related to GDD deliverables
- ❌ Make tasks too large (>3 hours is too big)
- ❌ Skip test criteria or acceptance criteria
- ❌ Ignore dependencies between tasks
- ❌ Create vague tasks ("make it better")
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

## Example Output Structure

For Dungeon Investor prototype, roadmap would have:

**Phase 1: Core Loop Foundation (Day 1 AM)**
- Task 1.1: Dungeon Room Display (1h)
- Task 1.2: Drag-Drop Placement System (2h)
- Task 1.3: Basic Auto-Battle Combat (2h)

**Phase 2: Economy System (Day 1 PM)**
- Task 2.1: Gold Counter UI (30min)
- Task 2.2: Shop System (1.5h)
- Task 2.3: Purchase/Refund Logic (1h)
- Task 2.4: Gold Earning on Hero Death (30min)

**Phase 3: Full Content (Day 2 AM)**
- Task 3.1: Implement 5 Monster Types (2h)
- Task 3.2: Implement 3 Trap Types (1.5h)
- Task 3.3: Implement 3 Hero Types (1h)

**Phase 4: Wave Progression (Day 2 PM)**
- Task 4.1: Wave Counter & System (1h)
- Task 4.2: Hero Stat Scaling (1h)
- Task 4.3: Win/Lose Conditions (1h)
- Task 4.4: Restart Functionality (30min)

**Phase 5: Polish (Day 3)**
- Task 5.1: Damage Numbers (1h)
- Task 5.2: Combat Pacing Tweaks (1h)
- Task 5.3: UI Clarity Pass (1.5h)
- Task 5.4: Death Animations (1h)
- Task 5.5: Win/Lose Screens (1h)

Each task includes:
- Time estimate
- Acceptance criteria (testable)
- File paths
- Dependencies

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
