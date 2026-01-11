---
name: vertical-slice-gdd-generator
description: Expand a prototype GDD into a vertical slice GDD, adding polish, content scope, and quality bar definitions. Use this when prototype validates core mechanics and you're ready to build a polished representative slice.
domain: design
type: generator
version: 1.0.0
allowed-tools:
  - Read
  - Write
---

# Vertical Slice GDD Generator Skill

This skill takes a validated prototype GDD and expands it into a comprehensive vertical slice GDD, defining the polished, representative experience that demonstrates final game quality.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "expand prototype GDD to vertical slice"
- Asks "create vertical slice GDD"
- Prototype is validated and they want to plan the polished slice
- Says "plan vertical slice based on prototype"
- Wants to define quality bar and scope for vertical slice
- Transitioning from "does it work?" to "does it feel good?"

---

## Core Principle

**Vertical slices prove the vision**:
- ✅ Narrow in scope (1-2 levels, limited content)
- ✅ Deep in quality (final game polish)
- ✅ Representative of final experience
- ✅ Validates "this is worth building fully"
- ✅ Demonstrates to stakeholders/publishers
- ✅ Sets quality bar for full production

---

## Prototype GDD vs Vertical Slice GDD

| Aspect | Prototype GDD | Vertical Slice GDD |
|--------|---------------|---------------------|
| **Goal** | Test core questions | Prove final quality |
| **Scope** | Minimum viable features | Polished representative slice |
| **Quality** | Functional, not polished | Final game quality |
| **Content** | Placeholder (3 enemies) | Polished subset (5 enemies, all final art) |
| **Polish** | No juice, basic feedback | Full juice, VFX, audio, animations |
| **Duration** | Weekend to week | 2-4 weeks |
| **Success** | "Does mechanic work?" | "Would I buy this game?" |

---

## Vertical Slice GDD Structure

```markdown
# [GAME TITLE] - Vertical Slice GDD

**Version:** [X.Y.Z]
**Based On:** Prototype GDD v[X.Y.Z]
**Prototype Validation Results:** [Summary of prototype success]
**Vertical Slice Goal:** [What this slice proves]
**Timeline:** [Weeks]
**Team Size:** [Number]
**Target Completion:** [Date]

---

## EXECUTIVE SUMMARY

### Prototype Validation Summary

**What We Tested:**
[List of critical questions from prototype GDD]

**Results:**
- Q1: [Question] → ✅ PASSED / ⚠️ NEEDS ITERATION / ❌ FAILED
- Q2: [Question] → [Result with evidence]
- Q3: [Question] → [Result]

**Key Learnings:**
- [Insight 1 from playtesting]
- [Insight 2]
- [Changes needed based on prototype feedback]

### Vertical Slice Vision

**What We're Proving:**
[1-2 paragraphs: What does this vertical slice demonstrate? What question does it answer?]

**Slice Scope:**
- **Duration:** [X minutes/hours of polished gameplay]
- **Content:** [Specific content included]
- **Quality Bar:** [Visual/audio quality target - comparable game reference]

---

## 1. WHAT'S IN THE VERTICAL SLICE

### Core Features (From Prototype)

[List features proven in prototype, now getting polished]

#### [Feature 1]: [Name]
**Prototype Status:** ✅ Validated
**Vertical Slice Enhancements:**
- [Polish item 1 - e.g., "Add VFX for all weapon fires"]
- [Polish item 2 - e.g., "Implement screen shake on damage"]
- [Polish item 3 - e.g., "Add audio SFX for all actions"]
- [Iteration item - e.g., "Refine targeting algorithm based on playtest feedback"]

**Quality Bar:**
[Description of final quality - e.g., "Weapon firing should feel impactful with muzzle flash VFX, screen shake, and punchy SFX"]

#### [Feature 2]: [Name]
[Same format]

---

### New Features (Additions to Prototype)

[Features not in prototype but needed for vertical slice]

#### [New Feature 1]: [Name]
**Why Adding:** [Justification - e.g., "Playtesters wanted more build variety"]
**Scope:** [Detailed description]
**Implementation Priority:** High / Medium / Low
**Dependencies:** [What must exist first]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

---

### Content Scope

**Total Content Volume:**

| Content Type | Prototype | Vertical Slice | Notes |
|--------------|-----------|----------------|-------|
| Enemy Types | 3 | 5 | Add Artillery and Elite |
| Weapon Types | 3 | 5 | Add Missiles and Flamethrower |
| Player Abilities | 0 | 0 | Not in slice scope |
| Arenas/Maps | 1 (basic) | 1 (polished) | Final art, not placeholder |
| Boss Fights | 0 | 1 | 15-min final boss |
| UI Screens | 3 | 6 | Add options, credits, how-to-play |

**Asset Production:**
- All placeholder art replaced with final quality
- All systems have audio SFX
- Background music (1 main theme, 1 boss theme)
- UI polished with animations and transitions

---

## 2. QUALITY BAR

### Visual Quality

**Art Style:** [Description - e.g., "Pixel art, 32x32 sprites, limited color palette"]

**Reference Quality:** [Comparable games - e.g., "Vampire Survivors polish level"]

**Specific Requirements:**
- **Player/Character:** [Animation requirements, visual polish]
- **Enemies/NPCs:** [Number of types, animation states, visual effects]
- **Interactions:** [What needs visual feedback - attacks, abilities, etc.]
- **UI:** [Polish level, animations, consistency]
- **VFX:** [Particle effects needed for key moments]

---

### Audio Quality

**Music:**
- [Track 1]: [Style, purpose - e.g., main theme, boss theme, etc.]
- [Track 2]: [Style, purpose]

**SFX:**
- [Category 1 sounds]: [Description - e.g., player actions, attacks]
- [Category 2 sounds]: [Description - e.g., enemy/NPC sounds]
- [Category 3 sounds]: [Description - e.g., UI sounds]
- Ambient: [Background ambience if applicable]

**Reference Quality:** [Comparable games or quality level]

---

### Game Feel (Juice)

**Required Polish:**

**Player Actions:**
- **[Core Action 1]:** [Polish requirements - particles, shake, sound, animation]
- **[Core Action 2]:** [Polish requirements]
- **[Important Moment 1]:** [Polish requirements]
- **[Important Moment 2]:** [Polish requirements]

**Interaction Feel:**
- **[Primary Interaction]:** [Visual/audio/haptic feedback]
- **[Impact/Hit Feedback]:** [Effects on successful action]
- **[Failure State]:** [How failure is communicated]

**UI Polish:**
- **Menu Transitions:** [Animation style and timing]
- **Button Interactions:** [Hover, click, feedback]
- **Progress Indicators:** [How bars/meters animate]

---

## 3. TECHNICAL REQUIREMENTS

### Performance Targets

**Vertical Slice Must Meet:**
- **FPS:** Solid 60 FPS with 100 enemies + 50 projectiles on screen
- **Load Time:** <2 seconds from menu to game
- **Memory:** <500 MB RAM usage
- **Build Size:** <100 MB (optimized assets)

**Optimizations Required:**
- Object pooling for bullets and enemies
- Off-screen culling for particles
- Cached targeting queries (not per-frame for all weapons)

---

### Code Quality

**Refactoring from Prototype:**
- [ ] All hardcoded values extracted to data files (.tres resources)
- [ ] Code quality issues from prototype refactored
- [ ] Scene optimization applied
- [ ] Architecture patterns established (signals, managers)

**Code Standards:**
- All scripts have type annotations
- No deprecated Godot 3.x syntax
- Signal connections documented
- Critical systems have comments

---

## 4. SCOPE BOUNDARIES

### What's IN the Vertical Slice

✅ **Gameplay:**
- Complete 15-minute run (tutorial difficulty)
- 5 weapon types with targeting rules
- 5 enemy types with distinct behaviors
- Level-up system with meaningful choices
- Final boss encounter at 15 minutes

✅ **Polish:**
- Final art for all assets
- Complete audio (music + SFX)
- Full juice (VFX, screen shake, animations)
- Polished UI with transitions

✅ **Screens:**
- Main menu (start, options, quit)
- Loadout screen (weapon rule setup)
- Game (HUD, pause menu)
- Level-up menu (upgrade choices)
- Death screen (stats, retry)
- Victory screen (if beat boss)

---

### What's OUT of Vertical Slice

❌ **Not Required:**
- Multiple difficulty modes (just balanced default)
- Meta-progression / unlocks (all content available)
- Multiple arenas (just 1 polished map)
- Endless mode beyond 15 minutes
- Leaderboards / online features
- Localization (English only)
- Advanced weapon rules (keep prototype's 2 rules: target + condition)
- Tutorial system (assume informed players)
- Cutscenes / story content

**Rationale:** Vertical slice proves core loop quality, not full game scope.

---

## 5. DEVELOPMENT PHASES

### Phase 1: [Phase Name] ([Timeline])

**Goal:** [What this phase accomplishes]

**Tasks:**
- [Task 1]
- [Task 2]
- [Task 3]

**Deliverable:** [Concrete output from this phase]

---

### Phase 2: [Phase Name] ([Timeline])

**Goal:** [What this phase accomplishes]

**Tasks:**
- [Task 1]
- [Task 2]
- [Task 3]

**Deliverable:** [Concrete output from this phase]

---

### Phase 3: [Phase Name] ([Timeline])

**Goal:** [What this phase accomplishes]

**Tasks:**
- [Task 1]
- [Task 2]
- [Task 3]

**Deliverable:** [Concrete output from this phase]

---

### Phase 4: [Phase Name] ([Timeline])

**Goal:** [What this phase accomplishes]

**Tasks:**
- [Task 1]
- [Task 2]
- [Task 3]

**Deliverable:** [Concrete output from this phase]

---

## 6. SUCCESS CRITERIA

### Validation Questions

**The vertical slice succeeds if it answers YES to:**

1. **Quality Question:** "Does this look/sound/feel like a finished game?"
   - External viewers assume it's close to release
   - No placeholder art or missing audio
   - Polish comparable to commercial indie games

2. **Engagement Question:** "Would I pay money for more of this?"
   - Playtesters want to continue beyond 15 minutes
   - "When's the full game coming?" reactions
   - Positive sentiment without major complaints

3. **Repeatability Question:** "Do I want to replay with different strategies?"
   - Players retry with different weapon setups
   - Discussion of optimal builds
   - "One more run" engagement

4. **Vision Question:** "Does this prove the full game concept?"
   - Stakeholders/publishers understand the full game vision
   - Scaling this slice to full game feels achievable
   - Core loop is proven and compelling

---

### Quantitative Targets

**Playtesting Metrics:**
- 80%+ complete full 15-minute run (not too hard)
- 60%+ retry after first run (engagement)
- Average 3+ runs per playtest session (replayability)
- 8/10+ satisfaction rating (quality)

**Technical Metrics:**
- 60 FPS maintained 95%+ of time
- Zero critical bugs
- <2 second load times

---

## 7. RISK ASSESSMENT

### Risks from Prototype

**Known Issues from Prototype:**
1. [Issue 1 from prototype playtest]
   - Mitigation: [How vertical slice addresses this]

2. [Issue 2]
   - Mitigation: [Solution]

### New Risks for Vertical Slice

**Risk: Art production takes longer than expected**
- Impact: HIGH (delays entire slice)
- Mitigation: Parallel art production, start Week 1
- Fallback: Reduce enemy types from 5 to 4

**Risk: Audio integration is complex**
- Impact: MEDIUM (affects polish)
- Mitigation: Use Godot AudioStreamPlayer, simple setup
- Fallback: Reduce SFX count, prioritize critical sounds

**Risk: Performance doesn't meet 60 FPS target**
- Impact: HIGH (quality bar not met)
- Mitigation: Object pooling, profiling in Week 3
- Fallback: Reduce max enemy count, optimize VFX

---

## 8. POST-SLICE DECISION TREE

### If Slice Succeeds (Validation Positive)

**Next Steps:**
1. Create Production GDD for full game
2. Plan content pipeline and team scaling
3. Estimate full production timeline
4. Seek funding/publishing if needed

**Full Game Scope:**
- [Expand from slice - e.g., "10 weapons, 15 enemy types, 5 arenas, 60-min endgame"]

---

### If Slice Needs Iteration

**Identify Issues:**
- [ ] Polish not at quality bar → More art/audio time
- [ ] Balance feels off → Tuning pass
- [ ] Core loop still unclear → Return to prototype, test variations

**Iteration Plan:**
- [Address specific issues]
- Retest in 1-2 weeks

---

### If Slice Fails Validation

**Pivot Options:**
- Return to prototype, test different mechanics
- Reduce scope (simpler game, faster to market)
- Cancel project (better to fail fast)

---

## 9. DELIVERABLES

### Final Vertical Slice Build

**Contents:**
- Standalone executable (Windows/Mac/Linux)
- 15-minute polished gameplay experience
- All final art and audio
- Presentation-ready (show to publishers/investors)

**Documentation:**
- This Vertical Slice GDD
- Playtest results summary
- Known issues log (minor bugs acceptable)
- Full game vision document (if proceeding to production)

---

## 10. BUDGET & RESOURCES

### Time Budget

**Total:** 4 weeks (160 hours for solo dev)

**Breakdown:**
- Programming: 60 hours (refactor, features, optimization)
- Art: 50 hours (sprites, animations, VFX)
- Audio: 20 hours (music, SFX, integration)
- Design/Balance: 20 hours (tuning, playtesting)
- Polish: 10 hours (final touches, bug fixes)

### Asset Needs

**Art:**
- Player sprite + animations (4 hours)
- 5 enemy sprites + animations (15 hours)
- 5 weapon projectile sprites (5 hours)
- UI art (10 hours)
- VFX sprites (8 hours)
- Background/arena (8 hours)

**Audio:**
- Music (2 tracks): 8 hours or $200 for composer
- SFX (30 sounds): 8 hours or $150 for SFX pack
- Integration: 4 hours

---

## APPENDICES

### Appendix A: Prototype Playtest Results
[Detailed findings from prototype validation]

### Appendix B: Reference Games Quality Comparison
[Screenshots/analysis of comparable games' polish level]

### Appendix C: Asset List
[Complete list of all art/audio assets needed]

---

**END OF VERTICAL SLICE GDD**

This document defines the polished representative slice that proves the game is worth building fully.
```

---

## Workflow

### Step 1: Read Prototype GDD

1. **Ask user for prototype GDD location:**
   - Default: `docs/[game]-prototype-gdd.md`
   - Or user specifies path

2. **Read prototype GDD:**
   - Extract critical questions and results
   - Identify validated features
   - Note areas needing iteration

3. **Ask about prototype results:**
   - "Did prototype validation succeed?"
   - "Which critical questions were answered positively?"
   - "What feedback did you get from playtesting?"

---

### Step 2: Define Vertical Slice Scope

**Ask user:**

```
Based on the prototype, let's define the vertical slice scope:

**1. What's the target experience duration?**
- Prototype was [X duration], vertical slice should be [Y duration]?
- What feels like a complete experience for your game type?

**2. What content expands from prototype?**
- What content types exist in prototype? (enemies, levels, abilities, etc.)
- How much content should vertical slice have?
- Any new features to add beyond prototype?

**3. What's the quality bar?**
- Visual reference: Which game's polish level?
- Audio: Full music + SFX, or just SFX?
- Juice: Full VFX, screen shake, particles?

**4. What's the timeline?**
- Typical: 2-4 weeks for vertical slice
- Your availability: [Hours per week]?

**5. What's the vertical slice proving?**
- What question must this slice answer?
- Who needs to be convinced? (yourself, team, publisher, players)
```

**Wait for responses.**

---

### Step 3: Define Quality Bar

**Ask about polish requirements:**

```
Let's define the quality bar:

**Visual Polish:**
- Replace all placeholder art? (Yes/No)
- Art style: [Pixel/Vector/3D/Minimal]?
- Reference quality: [Game name]?

**Audio:**
- Music tracks needed: [Main theme, boss theme, menu]?
- SFX coverage: [All actions, or just critical ones]?

**Game Feel (Juice):**
- Screen shake: [Always, sometimes, never]?
- Particle effects: [Minimal, moderate, heavy]?
- Damage numbers: [Yes/No]?
- UI animations: [Yes/No]?

**Performance:**
- FPS target: [30/60]?
- Max enemies on screen: [Number]?
```

---

### Step 4: Define Development Phases

**Break timeline into phases:**

1. **Calculate total hours:**
   - [Weeks] × [Hours/week] = Total hours

2. **Suggest phase breakdown:**
   - Week 1: Code refactor + asset production starts
   - Week 2: Audio integration + juice
   - Week 3: Balance + content completion
   - Week 4: Bug fixing + final polish

3. **Assign tasks to phases** based on dependencies

---

### Step 5: Generate Vertical Slice GDD

**Create comprehensive document with:**
1. Executive summary (prototype results + slice vision)
2. What's IN the slice (features + content)
3. Quality bar (visual/audio/feel)
4. Technical requirements (performance, code quality)
5. Scope boundaries (what's OUT)
6. Development phases (week-by-week plan)
7. Success criteria (validation questions + metrics)
8. Risk assessment
9. Post-slice decision tree
10. Budget & resources

**Save to:** `docs/[game]-vertical-slice-gdd.md`

---

## Example Interaction

**User:** "Expand [game] prototype GDD to vertical slice"

**Skill:**
```
I'll expand the [game] prototype GDD to a vertical slice GDD.

Reading prototype GDD... Found:
- [X] critical questions tested
- [Prototype structure/scope]
- Prototype validation: [SUCCESS/NEEDS ITERATION]

Now let's define the vertical slice:

**1. Timeline:** How long for vertical slice?
Prototype was [X duration]. Vertical slice typically 2-4 weeks.
Recommended: [X weeks] for [team size]

**2. Quality Bar:** What's the reference quality?
Prototype: [Current state]
Vertical Slice: Which game's polish level should we target?

**3. Content Scope:** Expand or keep same?
Prototype: [Content summary]
Vertical Slice: Same content but fully polished? Or add more?

**4. New Features:** Any additions based on prototype feedback?
Prototype feedback: [Key findings]
What should be addressed in vertical slice vs saved for production?
```

---

## Integration with Other Skills

### Builds On:
- `prototype-gdd-generator` - Reads prototype GDD as input

### Feeds Into:
- `vertical-slice-roadmap-planner` - Takes vertical slice GDD, creates feature roadmap
- `production-gdd-generator` - Vertical slice proves concepts for full production GDD

### Works With:
- `feature-spec-generator` - Each new feature in slice gets detailed spec
- `balance-tuner` - Balance pass is part of vertical slice development
- `juice-guide` - Polish requirements defined in quality bar section

---

## Quality Checklist

Before finalizing vertical slice GDD:
- ✅ Based on validated prototype (not starting from scratch)
- ✅ Scope is achievable in stated timeline
- ✅ Quality bar is clearly defined with references
- ✅ What's IN and OUT are explicit
- ✅ Development phases are realistic
- ✅ Success criteria are measurable
- ✅ Budget accounts for art/audio production time
- ✅ Risks are identified with mitigations

---

## Example Invocations

User: "Expand prototype GDD to vertical slice"
User: "Create vertical slice GDD from prototype"
User: "Plan vertical slice for Mech Survivors"
User: "Prototype validated, what's next?" → Skill suggests vertical slice GDD

---

## Workflow Summary

1. Read prototype GDD (or ask for location)
2. Ask about prototype validation results
3. Define vertical slice scope (duration, content, quality bar)
4. Define development timeline and phases
5. Generate comprehensive vertical slice GDD
6. Save to `docs/[game]-vertical-slice-gdd.md`
7. Remind user to use `vertical-slice-roadmap-planner` next to create feature roadmap

---

## Example: How This Works for Different Game Types

### Example 1: Action Roguelike (like Mech Survivors)
**Prototype validated:** "Program weapon rules → watch execution → iterate" works
**Vertical Slice adds:** VFX, audio, 5 polished weapons, boss fight, full juice
**Timeline:** 3-4 weeks
**Quality bar:** Vampire Survivors polish level

### Example 2: Puzzle Platformer
**Prototype validated:** Core movement + 3 puzzle mechanics work well
**Vertical Slice adds:** 10 polished levels, final art, music, level transitions
**Timeline:** 2-3 weeks
**Quality bar:** Celeste polish level

### Example 3: Turn-Based Strategy
**Prototype validated:** Grid combat + unit abilities feel tactical
**Vertical Slice adds:** 5 unit types, 3 polished maps, AI, full UI
**Timeline:** 4 weeks
**Quality bar:** Into the Breach polish level

---

This skill bridges the gap between "it works" (prototype) and "it's polished" (vertical slice), setting the quality bar for full production.
