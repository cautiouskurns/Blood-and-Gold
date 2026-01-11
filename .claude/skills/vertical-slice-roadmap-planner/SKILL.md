---
name: vertical-slice-roadmap-planner
description: Read a vertical slice GDD and generate a phased roadmap of features that need to be implemented, organized into logical phases with high-level feature descriptions.
domain: project
type: planner
version: 2.0.0
allowed-tools:
  - Read
  - Write
  - Glob
---

# Vertical Slice Roadmap Planner Skill

This skill reads a vertical slice GDD and generates a phased implementation roadmap. It extracts all features from the GDD, organizes them into logical phases based on dependencies, and outputs high-level feature descriptions. These features can then be turned into detailed specs using `feature-spec-generator`.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "create roadmap for vertical slice"
- Asks "plan implementation phases for vertical slice"
- Wants to break down vertical slice into actionable phases
- Has a vertical slice GDD and needs an implementation plan
- Says "what features do I need to build for the vertical slice?"

---

## Core Principle

**Roadmaps organize vision into phases**:
- ✅ Extract all features from vertical slice GDD
- ✅ Organize features into logical phases (by dependency and priority)
- ✅ Each phase has a clear purpose and deliverable
- ✅ Features described at high level (details come from feature-spec-generator)
- ✅ Roadmap is a planning tool, not a detailed implementation guide

---

## Roadmap Output Structure

The skill generates a simple, clean roadmap:

```markdown
# [GAME TITLE] - Vertical Slice Implementation Roadmap

**Based On:** Vertical Slice GDD v[X.Y.Z]
**Timeline:** [X weeks/months from GDD]
**Created:** [Date]

---

## Phase 1: [Phase Name] ([Timeline from GDD])

**Purpose:** [What this phase accomplishes - from GDD or inferred]

**Features to Implement:**

### [Feature 1 Name]
**Type:** New Feature / Refactor / Polish
**Priority:** Critical / High / Medium / Low
**Description:** [High-level description from GDD]
**Dependencies:** [What must exist first, if any]

### [Feature 2 Name]
**Type:** New Feature / Refactor / Polish
**Priority:** Critical / High / Medium / Low
**Description:** [High-level description from GDD]
**Dependencies:** [What must exist first, if any]

**Phase Deliverable:** [What should be working after this phase]

---

## Phase 2: [Phase Name] ([Timeline from GDD])

**Purpose:** [What this phase accomplishes]

**Features to Implement:**

[Same format as Phase 1]

**Phase Deliverable:** [What should be working after this phase]

---

[Continue for all phases from GDD]

---

## Feature Spec Roadmap

Use `feature-spec-generator` to create detailed specs for these features:

- [ ] [Feature 1 from Phase 1]
- [ ] [Feature 2 from Phase 1]
- [ ] [Feature 3 from Phase 2]
- [... etc]

**Workflow:**
1. Start with Phase 1 features
2. Use `/feature-spec-generator [feature name]` for each feature
3. Implement features following the spec
4. Move to next phase when current phase deliverable is met

---

## Asset Production

**Art Assets Needed:** [Extracted from GDD's quality bar section]
**Audio Assets Needed:** [Extracted from GDD's audio section]
**Timeline:** [When assets are needed, from GDD]

---

**END OF ROADMAP**
```

---

## Workflow

### Step 1: Read Vertical Slice GDD

1. **Find the vertical slice GDD:**
   - Look for `docs/*vertical-slice*.md` or ask user for path
   - Read the entire GDD

2. **Extract key information:**
   - Timeline (from GDD's development phases)
   - Features IN the vertical slice (from "What's IN" section)
   - New features being added (from "New Features" section)
   - Features being polished (from "Core Features - Being Polished")
   - Quality bar requirements (visual, audio, game feel)
   - Phase breakdown (if GDD has suggested phases)

---

### Step 2: Categorize Features

**Organize extracted features into categories:**

1. **New Features** (doesn't exist in prototype)
   - From GDD's "New Features (Additions to Prototype)" section
   - Priority from GDD (Critical/High/Medium/Low)

2. **Refactor/Polish** (exists but needs improvement)
   - From GDD's "Core Features (From Prototype - Being Polished)"
   - Extract what enhancements are needed

3. **Content/Assets** (art, audio, data)
   - From GDD's quality bar sections
   - Audio requirements
   - Art requirements

---

### Step 3: Organize into Phases

**Map features to phases based on:**

1. **GDD's suggested phases** (if provided)
   - Most vertical slice GDDs have a "Development Phases" section
   - Use that as the phase structure

2. **If no phases in GDD, infer logical phases:**
   - Phase 1: Foundation (core systems, refactoring)
   - Phase 2: New Features (meta progression, new content)
   - Phase 3: Polish (audio, visual, juice)
   - Phase 4: Testing & Balance (playtesting, bug fixes)

3. **Respect dependencies:**
   - Foundation systems must come before features that use them
   - Content can be parallel to systems work
   - Polish comes after core functionality

---

### Step 4: Generate Roadmap Document

**For each phase:**

1. **Extract phase info from GDD:**
   - Phase name (from GDD or inferred)
   - Timeline (weeks or hours from GDD)
   - Purpose (what this phase accomplishes)

2. **List features in this phase:**
   - Feature name
   - Type (New / Refactor / Polish)
   - Priority (from GDD)
   - High-level description (from GDD)
   - Dependencies (what must exist first)

3. **Define phase deliverable:**
   - What should be working when phase is complete
   - From GDD's success criteria or inferred

---

### Step 5: Create Feature Spec Checklist

**List all features that need detailed specs:**
- Complex new systems
- Features requiring design decisions
- Features with acceptance criteria in GDD

**Format:**
```
- [ ] [Feature Name] - Use /feature-spec-generator
```

---

### Step 6: Extract Asset Requirements

**From GDD's quality bar sections:**
- Art assets needed (sprites, UI, VFX)
- Audio assets needed (music tracks, SFX count)
- Timeline for asset production

---

### Step 7: Save Roadmap

**Save to:** `docs/[game-name]-vertical-slice-roadmap.md`

**Output to user:**
```
Created vertical slice roadmap with:
- [X] phases over [timeline]
- [X] features to implement
- [X] features need detailed specs (use feature-spec-generator)

Next steps:
1. Review roadmap: docs/[game]-vertical-slice-roadmap.md
2. Start with Phase 1
3. Use /feature-spec-generator for each feature before implementing
```

---

## Example Interaction

**User:** "Create roadmap for vertical slice"

**Skill:**
```
Reading vertical slice GDD...

Found: docs/Vertical-Slice-GDD.md
- 4 month timeline (16 weeks)
- 4 development phases defined
- 8 new features to add
- 6 systems to refactor/polish
- Asset production requirements

Organizing features into phases...

Phase 1: Meta Progression Foundation (Weeks 1-4)
- 4 features (Scrap System, Unlocks, Tech Tree, Tutorial)

Phase 2: Content Variety (Weeks 5-8)
- 3 features (3 Mechs, 2 Arenas, Weapon Evolutions)

Phase 3: Audio/Visual Polish (Weeks 9-12)
- 4 features (Art Replacement, Audio Production, VFX, UI Polish)

Phase 4: Playtesting & Final Polish (Weeks 13-16)
- 3 features (Internal Playtest, External Playtest, Bug Fixing)

Generating roadmap document...

Roadmap saved to: docs/Mech-Survivors-vertical-slice-roadmap.md

Total: 14 features across 4 phases
Recommended: Use /feature-spec-generator for critical features
```

---

## Integration with Other Skills

### Reads From:
- `vertical-slice-gdd-generator` - Input GDD defining the slice

### Feeds Into:
- `feature-spec-generator` - Create detailed specs for each feature in roadmap
- `changelog-updater` - Track progress as features complete

### Works With:
- `systems-bible-updater` - Document systems as they're built
- `version-control-helper` - Manage commits per phase

---

## Quality Checklist

Before finalizing roadmap:
- ✅ All features from GDD "What's IN" are included
- ✅ Features organized into logical phases (respects dependencies)
- ✅ Each phase has clear purpose and deliverable
- ✅ Priorities from GDD are preserved
- ✅ Timeline from GDD is used
- ✅ Feature descriptions are high-level (not detailed)
- ✅ Feature spec checklist includes complex features

---

## Key Principles

**DO:**
- ✅ Extract features directly from GDD (don't make up features)
- ✅ Use GDD's phase structure if provided
- ✅ Keep feature descriptions high-level
- ✅ Respect dependencies and logical ordering
- ✅ Create a planning tool, not an implementation guide

**DON'T:**
- ❌ Add hardcoded example content
- ❌ Invent features not in the GDD
- ❌ Write detailed implementation steps
- ❌ Prescribe specific code solutions
- ❌ Assume timeline (use GDD's timeline)

---

## Example Output

For a vertical slice GDD with meta progression, multiple mechs, and polish, the roadmap might have:

**Phase 1: Meta Progression (4 weeks)**
- Feature: Scrap Currency System
- Feature: Unlock Tree
- Feature: Tech Tree
- Feature: Tutorial System

**Phase 2: Content Variety (4 weeks)**
- Feature: 3 Mech Chassis
- Feature: 2 Arenas
- Feature: Weapon Evolutions

**Phase 3: Polish (4 weeks)**
- Feature: Final Art Replacement
- Feature: Audio Integration
- Feature: VFX System
- Feature: UI Polish

**Phase 4: Testing (4 weeks)**
- Feature: Balance Pass
- Feature: Bug Fixing
- Feature: Performance Optimization

Each feature has:
- Type (New/Refactor/Polish)
- Priority (from GDD)
- Description (from GDD)
- Dependencies (inferred)

---

This skill is a **simple extraction and organization tool** that turns a vertical slice GDD into an actionable roadmap. Detailed implementation comes from feature specs generated with `feature-spec-generator`.
