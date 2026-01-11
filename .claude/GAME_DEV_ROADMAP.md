# Game Development Roadmap with Claude Skills

**Purpose:** Master checklist and skill mapping for creating games from scratch

**How to Use:**
1. Start at Phase 1 for new game ideas
2. Check off skills as you use them
3. Skip phases if working on existing project
4. Return to earlier phases when pivoting/iterating

**Legend:**
- ✅ Skill exists and ready to use
- 📝 Skill planned but not yet created
- 🔄 Skill may need updates/improvements

---

## Phase 1: Ideation & Concept Development

**Goal:** Generate and validate game concepts based on constraints

### Skills for This Phase

#### ✅ `game-concept-generator`
**When to use:** Need game ideas, exploring what's possible within constraints
**Input:** Timeline, platform, team size, genre preferences
**Output:** 3-5 tailored game concepts with core loops and scope assessments
**Invoke with:** "Help me brainstorm game ideas" or "Generate game concepts for [constraints]"

#### ✅ `concept-validator`
**When to use:** Have a game idea, need to stress-test feasibility
**Input:** Game concept description
**Output:** Analysis of technical feasibility, scope warnings, similar games comparison
**Invoke with:** "Validate this game concept: [description]"

#### 📝 `reference-analyzer`
**When to use:** Want to understand what makes reference games work
**Input:** List of 2-5 games that inspire you
**Output:** Breakdown of mechanics, what to take/avoid, how they achieved their feel
**Invoke with:** "Analyze [Game X] for my [genre] game"

### Outputs from Phase 1
- [ ] 3-5 game concepts documented
- [ ] Primary concept selected
- [ ] Design pillars articulated (2-4 pillars)
- [ ] Reference games identified with specific takeaways

### Decision Point
**Proceed to Phase 2 if:** You can describe the core loop in one sentence and identify the single most important question to test.

---

## Phase 2: Prototype Planning & Documentation

**Goal:** Define what you're testing and create structured plan

### Skills for This Phase

#### ✅ `prototype-gdd-generator`
**When to use:** Need to document prototype plan before building
**Input:** Interactive Q&A about concept, mechanics, scope, success criteria
**Output:** Structured prototype GDD with critical questions, implementation phases
**Invoke with:** "Create a GDD for my [game type] prototype"

#### ✅ `prototype-roadmap-planner`
**When to use:** Have prototype GDD, need implementation roadmap
**Input:** Prototype GDD, current prototype state
**Output:** Feature spec roadmap with production phases, dependencies, weekly breakdown
**Invoke with:** "Create roadmap for prototype" or "Plan prototype   implementation"

#### ✅ `feature-spec-generator`
**When to use:** Need detailed specification for a specific feature
**Input:** Feature name and high-level description
**Output:** Detailed feature spec with acceptance criteria, technical approach, testing checklist
**Invoke with:** "Generate spec for [feature name]"

#### ✅ `feature-implementer`
**When to use:** Have a feature spec, ready to implement it
**Input:** Feature spec from `docs/features/`
**Output:** Complete implementation with scenes, scripts, resources + detailed report of what changed
**Reports:** What was done, gameplay changes, what player sees, how to test
**Invoke with:** "Implement [feature-name]" or "Implement docs/features/X.md"

#### ✅ `design-bible-updater`
**When to use:** Establishing design vision, documenting creative pillars and philosophy
**Input:** Interactive Q&A about vision, design pillars, player fantasy, reference games
**Output:** Comprehensive design bible documenting WHY design decisions are made
**Invoke with:** "Create design bible" or "Update design bible with [decision]"

### Outputs from Phase 2
- [ ] Prototype GDD created (`docs/[game]-prototype-gdd.md`)
- [ ] Design Bible created (`docs/design-bible.md`)
- [ ] Critical questions identified (3-5 questions)
- [ ] Success criteria defined (observable behaviors)
- [ ] Implementation phases planned with hour estimates
- [ ] Feature specs created for complex systems
- [ ] "What's OUT" list documented

### Decision Point
**Proceed to Phase 3 if:** You have clear success criteria and can build a testable prototype in stated timeline.

---

## Phase 3: Rapid Prototyping

**Goal:** Build minimum viable prototype to test core questions

### Skills for This Phase

#### ✅ `godot-project-setup`
**When to use:** Starting a new Godot project, need standard folder structure
**Input:** Target directory path (or use current directory)
**Output:** Professional folder structure (scenes/, scripts/, assets/, resources/ with organized subdirectories)
**Invoke with:** "Set up Godot project structure" or "Create Godot folders"

#### 📝 `prototype-scaffolder`
**When to use:** Starting implementation, need basic project structure with code templates
**Input:** GDD or feature list
**Output:** File structure, base scripts, scene templates
**Invoke with:** "Scaffold prototype for [game]" or "Create project structure"

#### 📝 `mechanic-implementation-guide`
**When to use:** Implementing a specific game mechanic, need technical guidance
**Input:** Mechanic description (e.g., "weapon rule system", "grid-based movement")
**Output:** Step-by-step Godot implementation guide, code patterns, common pitfalls
**Invoke with:** "How do I implement [mechanic] in Godot?"

#### 📝 `quick-art-generator`
**When to use:** Need placeholder art/assets for prototype
**Input:** Asset type (player sprite, enemy, UI element)
**Output:** Godot-ready placeholder assets (colored shapes, simple sprites)
**Invoke with:** "Generate placeholder art for [asset type]"

#### 📝 `debug-helper`
**When to use:** Stuck on a bug, need troubleshooting guidance
**Input:** Error message or unexpected behavior description
**Output:** Likely causes, debugging steps, solution suggestions
**Invoke with:** "Debug: [error description]"

#### ✅ `feature-implementer`
**When to use:** Have feature specs ready, want to implement them with full documentation
**Input:** Feature spec from `docs/features/`
**Output:** Working implementation + detailed report (what changed, what player sees, how to test)
**Invoke with:** "Implement [feature-name]"

#### ✅ `systems-bible-updater`
**When to use:** Documenting system architecture, implementation details, data flows
**Input:** System name, existing code to analyze
**Output:** Technical documentation of HOW systems work (architecture, APIs, dependencies)
**Invoke with:** "Document [system] architecture" or "Update systems bible"

### Outputs from Phase 3
- [ ] Core mechanic implemented and playable
- [ ] Supporting systems integrated
- [ ] Systems Bible started (`docs/systems-bible.md`)
- [ ] Win/lose conditions functional
- [ ] First playtest completed
- [ ] Critical questions have preliminary answers

### Decision Point
**Proceed to Phase 4 if:** Prototype answers core questions positively (score 15+/25) and you want to refine the code.

---

## Phase 4: Code Quality & Refactoring

**Goal:** Clean up prototype code, prepare for expansion

### Skills for This Phase

#### ✅ `gdscript-quality-checker`
**When to use:** Prototype works, need to assess code quality before expanding
**Input:** GDScript file(s) or directory to analyze
**Output:** Code review report with critical issues, warnings, suggestions
**Invoke with:** "Check code quality" or "Review [file/directory]"

#### ✅ `gdscript-refactor-executor`
**When to use:** Have quality report, want to apply recommended fixes
**Input:** Code review report from `gdscript-quality-checker`
**Output:** Applied refactorings, execution report
**Invoke with:** "Execute refactor fixes from [report]"

#### ✅ `data-driven-refactor`
**When to use:** Too many hardcoded values, want to externalize configuration
**Input:** GDScript files with hardcoded data
**Output:** Analysis of what to extract, recommended data formats, migration plan
**Invoke with:** "Separate data from logic" or "Make [system] data-driven"

#### ✅ `data-extractor`
**When to use:** Have data-driven refactor plan, ready to implement
**Input:** Data extraction analysis report
**Output:** Created data files (.tres, .json, .cfg), refactored scripts
**Invoke with:** "Extract data from [files]"

#### ✅ `scene-optimizer`
**When to use:** Scene files getting complex, performance concerns
**Input:** .tscn scene file(s)
**Output:** Scene analysis report with structural issues, optimization opportunities
**Invoke with:** "Optimize scene [scene-name].tscn" or "Check scene structure"

#### 📝 `code-architecture-reviewer`
**When to use:** Project structure feeling messy, need high-level assessment
**Input:** Project directory
**Output:** Architecture analysis, coupling issues, recommended patterns
**Invoke with:** "Review project architecture"

#### 📝 `performance-profiler-helper`
**When to use:** Game running slow, need performance optimization guidance
**Input:** Performance symptoms (FPS drops, stuttering)
**Output:** Profiling guidance, likely bottlenecks, optimization checklist
**Invoke with:** "Optimize performance" or "Why is my game slow?"

### Outputs from Phase 4
- [ ] Code quality report generated
- [ ] Critical issues fixed
- [ ] Data externalized to config files
- [ ] Scenes optimized for performance
- [ ] Architecture patterns established
- [ ] Refactoring execution reports saved

### Decision Point
**Proceed to Phase 5 if:** Code is clean, data-driven, and performance is acceptable for expansion.

---

## Phase 5: Vertical Slice Development

**Goal:** Create polished, representative slice of final game

### Skills for This Phase

#### ✅ `vertical-slice-gdd-generator`
**When to use:** Prototype validated, ready to plan polished vertical slice
**Input:** Prototype GDD, validation results, timeline
**Output:** Comprehensive vertical slice GDD (scope, quality bar, phases, budget)
**Invoke with:** "Expand prototype GDD to vertical slice" or "Create vertical slice GDD"

#### ✅ `vertical-slice-roadmap-planner`
**When to use:** Have vertical slice GDD, need implementation roadmap
**Input:** Vertical slice GDD, current prototype state
**Output:** Feature spec roadmap with production phases, dependencies, weekly breakdown
**Invoke with:** "Create roadmap for vertical slice" or "Plan vertical slice implementation"

#### 📝 `feature-prioritizer`
**When to use:** Too many feature ideas, need to focus on vertical slice essentials
**Input:** Feature backlog
**Output:** Prioritized list (must-have/should-have/nice-to-have), impact analysis
**Invoke with:** "Prioritize features for vertical slice"

#### ✅ `feature-implementer`
**When to use:** Have feature specs from roadmap, ready to implement with full tracking
**Input:** Feature spec from `docs/features/`
**Output:** Complete implementation + detailed report on changes, player impact, testing
**Note:** Consults game design docs (GDD, design bible) to ensure alignment
**Invoke with:** "Implement [feature-name]"

#### 📝 `balance-tuner`
**When to use:** Gameplay working but numbers feel off
**Input:** Game data (weapon stats, enemy HP, spawn rates)
**Output:** Balance analysis, recommended tweaks, tuning methodology
**Invoke with:** "Balance [system]" or "Tune [weapon/enemy] stats"

#### 📝 `juice-guide`
**When to use:** Mechanics work but feel flat, need game feel improvements
**Input:** Specific interaction (shooting, hitting, dying)
**Output:** Juice checklist (screen shake, particles, sound, animation), implementation guide
**Invoke with:** "Add juice to [interaction]" or "Improve game feel"

### Outputs from Phase 5
- [ ] Vertical Slice GDD created (`docs/[game]-vertical-slice-gdd.md`)
- [ ] Vertical Slice Roadmap created (`docs/vertical-slice-roadmap.md`)
- [ ] Feature specs generated for all major systems
- [ ] All vertical slice features implemented
- [ ] Balance pass completed
- [ ] Juice/polish added (screen shake, particles, feedback)
- [ ] Vertical slice playtest completed
- [ ] Quality bar achieved

### Decision Point
**Proceed to Phase 6 if:** Vertical slice represents the final game's quality and feel, and validates full production.

---

## Phase 6: Full Production

**Goal:** Expand vertical slice to complete game

### Skills for This Phase

#### ✅ `production-gdd-generator`
**When to use:** Transitioning from prototype to full production, need comprehensive GDD
**Input:** Interactive Q&A about full game vision, all systems, content scope, monetization
**Output:** Complete production GDD covering all aspects of full game
**Invoke with:** "Create production GDD" or "Expand prototype to full GDD"

#### ✅ `feature-spec-generator` (from Phase 2)
**When to use:** Each new feature needs detailed specification
**Invoke with:** "Generate spec for [feature]"

#### 📝 `content-pipeline-builder`
**When to use:** Need systematic way to create content (levels, enemies, weapons)
**Input:** Content type, quantity needed
**Output:** Content creation workflow, templates, tooling suggestions
**Invoke with:** "Create content pipeline for [content type]"

#### 📝 `system-integration-checker`
**When to use:** Adding new systems, worried about conflicts with existing code
**Input:** New system description
**Output:** Integration analysis, potential conflicts, API design suggestions
**Invoke with:** "How does [new system] integrate with existing code?"

#### 📝 `regression-test-planner`
**When to use:** Game getting complex, need to prevent breaking changes
**Input:** Core features list
**Output:** Test plan, critical paths to verify, automated testing suggestions
**Invoke with:** "Create test plan for [game]"

### Outputs from Phase 6
- [ ] Production GDD created (`docs/[game]-production-gdd.md`)
- [ ] All planned features implemented
- [ ] Content creation pipeline established
- [ ] Content assets created (levels/enemies/weapons)
- [ ] Systems integrated and tested
- [ ] Regression testing in place

### Decision Point
**Proceed to Phase 7 if:** All core features complete and game is feature-complete (content-complete may come later).

---

## Phase 7: Polish & Game Feel

**Goal:** Elevate presentation, juice, and overall feel

### Skills for This Phase

#### 📝 `juice-guide` (from Phase 5)
**When to use:** Systematically polish all interactions
**Invoke with:** "Add juice to [all interactions]"

#### 📝 `vfx-implementer`
**When to use:** Need particle effects, screen effects, visual feedback
**Input:** Event type (explosion, damage, powerup)
**Output:** Godot CPUParticles2D/GPUParticles2D setup, shader suggestions
**Invoke with:** "Create VFX for [event]"

#### 📝 `audio-integration-guide`
**When to use:** Adding sound effects and music
**Input:** Audio events list
**Output:** AudioStreamPlayer setup, audio bus configuration, implementation guide
**Invoke with:** "Integrate audio for [game]"

#### 📝 `ui-polish-checker`
**When to use:** UI functional but not polished
**Input:** UI scenes
**Output:** Polish checklist (animations, transitions, feedback), UX improvements
**Invoke with:** "Polish UI for [screen]"

#### 📝 `camera-feel-tuner`
**When to use:** Camera behavior needs refinement (shake, zoom, follow)
**Input:** Camera issues or desired feel
**Output:** Camera implementation guide, feel parameters, smoothing techniques
**Invoke with:** "Improve camera feel"

### Outputs from Phase 7
- [ ] All interactions juiced (screen shake, particles, etc.)
- [ ] VFX implemented for key events
- [ ] Sound effects integrated
- [ ] Music integrated
- [ ] UI polished with animations
- [ ] Camera feel refined
- [ ] Overall game feel improved

### Decision Point
**Proceed to Phase 8 if:** Game feels polished and is ready for external playtesting.

---

## Phase 8: Testing & Balancing

**Goal:** Playtest, gather feedback, balance gameplay

### Skills for This Phase

#### 📝 `playtest-planner`
**When to use:** Organizing playtesting sessions
**Input:** Game state, what you want to learn
**Output:** Playtest plan, questions to ask, data to collect, feedback form
**Invoke with:** "Plan playtest for [game]"

#### 📝 `feedback-analyzer`
**When to use:** Have playtest feedback, need to prioritize fixes
**Input:** Playtest notes, player feedback
**Output:** Issue categorization, priority ranking, action items
**Invoke with:** "Analyze playtest feedback"

#### 📝 `balance-tuner` (from Phase 5)
**When to use:** Feedback reveals balance issues
**Invoke with:** "Balance [system] based on playtest data"

#### 📝 `bug-triager`
**When to use:** Multiple bugs reported, need prioritization
**Input:** Bug reports
**Output:** Priority ranking (critical/major/minor), fix recommendations
**Invoke with:** "Prioritize bugs: [bug list]"

### Outputs from Phase 8
- [ ] Playtest plan created
- [ ] Multiple playtest sessions conducted
- [ ] Feedback collected and analyzed
- [ ] Critical bugs fixed
- [ ] Balance adjusted based on data
- [ ] Second playtest validates improvements

### Decision Point
**Proceed to Phase 9 if:** Playtesters can complete the game, understand mechanics, and report positive experience.

---

## Phase 9: Release Preparation

**Goal:** Build, package, and prepare for distribution

### Skills for This Phase

#### 📝 `build-configurator`
**When to use:** Setting up export for target platforms
**Input:** Target platforms (PC/Web/Mobile)
**Output:** Export preset configuration, build script, optimization settings
**Invoke with:** "Configure build for [platform]"

#### 📝 `optimization-final-pass`
**When to use:** Final performance optimization before release
**Input:** Profiling data
**Output:** Optimization checklist, asset compression, code optimization
**Invoke with:** "Final optimization pass"

#### 📝 `release-checklist-generator`
**When to use:** Preparing for release, don't want to forget steps
**Input:** Target platform, distribution method
**Output:** Pre-release checklist, QA pass, marketing assets needed
**Invoke with:** "Generate release checklist for [platform]"

#### 📝 `patch-notes-writer`
**When to use:** Writing update notes for release
**Input:** Git commits or feature list since last version
**Output:** Formatted patch notes, feature highlights, bug fixes
**Invoke with:** "Generate patch notes since [version/date]"

### Outputs from Phase 9
- [ ] Export presets configured
- [ ] Builds tested on target platforms
- [ ] Performance optimized for release
- [ ] Release checklist completed
- [ ] Marketing assets prepared (screenshots, trailer, description)
- [ ] Patch notes written
- [ ] Game released!

---

## Phase 10: Post-Release & Iteration

**Goal:** Support released game, plan updates

### Skills for This Phase

#### 📝 `feedback-analyzer` (from Phase 8)
**When to use:** Analyzing player reviews and feedback
**Invoke with:** "Analyze post-release feedback"

#### 📝 `update-planner`
**When to use:** Planning post-release content updates
**Input:** Player requests, your vision, technical constraints
**Output:** Update roadmap, feature prioritization, timeline
**Invoke with:** "Plan update roadmap for [game]"

#### 📝 `hotfix-prioritizer`
**When to use:** Critical bugs in released game
**Input:** Bug reports from players
**Output:** Hotfix priority, minimal change recommendations
**Invoke with:** "Prioritize hotfix for [bugs]"

### Outputs from Phase 10
- [ ] Player feedback collected
- [ ] Hotfixes deployed for critical issues
- [ ] Update roadmap planned
- [ ] Community engaged
- [ ] Post-mortem written

---

## Cross-Cutting Skills (Use Anytime)

These skills can be used in any phase:

#### ✅ `godot-project-setup`
Set up standard Godot folder structure for new projects
**Invoke with:** "Set up Godot project structure"

#### ✅ `gdscript-quality-checker`
Regular code quality checks throughout development

#### ✅ `scene-optimizer`
Scene optimization whenever scenes get complex

#### ✅ `changelog-updater`
Track development progress, features, fixes, and changes in CHANGELOG.md
**Invoke with:** "Update changelog" or "Add [feature] to changelog"

#### ✅ `version-control-helper`
Git workflows, commit messages, branching strategies, resolving conflicts
**Invoke with:** "Help with git" or "How do I [git operation]?"

#### ✅ `design-bible-updater`
Create and maintain design vision, update as creative decisions evolve
**Invoke with:** "Update design bible with [decision]"

#### ✅ `systems-bible-updater`
Document system architecture as you build, update when refactoring
**Invoke with:** "Document [system] in systems bible"

#### 📝 `ai-playtester`
Automated playtesting to catch obvious issues (like the AI controller you built for Mech Survivors)

#### 📝 `godot-upgrader`
Upgrading projects between Godot versions, deprecation fixes

#### 📝 `documentation-generator`
Generate code documentation, API references, wiki pages

---

## Quick Reference: When to Use Each Skill

### "I have no idea what to build"
→ ✅ `game-concept-generator`

### "I have an idea, need to plan it"
→ ✅ `prototype-gdd-generator`

### "I need detailed specs for a feature"
→ ✅ `feature-spec-generator`

### "I have a spec, ready to implement it"
→ ✅ `feature-implementer`

### "Starting new Godot project, need folders"
→ ✅ `godot-project-setup`

### "Starting to code, need project structure"
→ 📝 `prototype-scaffolder`

### "Prototype done, code is messy"
→ ✅ `gdscript-quality-checker`

### "Have code review, want to fix issues"
→ ✅ `gdscript-refactor-executor`

### "Too many hardcoded numbers"
→ ✅ `data-driven-refactor`

### "Scene files getting complex"
→ ✅ `scene-optimizer`

### "Prototype validated, planning vertical slice"
→ ✅ `vertical-slice-gdd-generator`

### "Need implementation plan for vertical slice"
→ ✅ `vertical-slice-roadmap-planner`

### "Need to add game feel"
→ 📝 `juice-guide`

### "Preparing for release"
→ 📝 `release-checklist-generator`

### "Need to track development progress"
→ ✅ `changelog-updater`

### "How do I use git for game dev?"
→ ✅ `version-control-helper`

### "Document our design vision"
→ ✅ `design-bible-updater`

### "Document system architecture"
→ ✅ `systems-bible-updater`

### "Planning full production"
→ ✅ `production-gdd-generator`

---

## Skill Development Priority

Based on Mech Survivors project needs, prioritize creating:

**Tier 1 (Critical - Recently Created):**
1. ✅ `vertical-slice-gdd-generator` - Created! Expands prototype to polished slice plan
2. ✅ `vertical-slice-roadmap-planner` - Created! Implementation roadmap for vertical slice
3. 📝 `balance-tuner` - Essential for weapon/enemy tuning
4. 📝 `juice-guide` - Polish is critical for prototype feel

**Tier 2 (High Value):**
4. 📝 `playtest-planner` - Systematic playtesting needed
5. 📝 `mechanic-implementation-guide` - Technical guidance for complex systems
6. 📝 `performance-profiler-helper` - May need this for wave spawning

**Tier 3 (Nice to Have):**
7. 📝 `prototype-scaffolder` - Useful for future projects
8. 📝 `ai-playtester` - You already have AI controller, could formalize
9. 📝 `build-configurator` - Needed before release

---

## Notes

- **Checkpoint often**: Save reports, specs, and analyses to `docs/` for reference
- **Iterate phases**: You may return to earlier phases (e.g., Phase 4 → Phase 3 if major changes needed)
- **Skip when appropriate**: If working on existing project, start at relevant phase
- **Combine skills**: Multiple skills can be used together (e.g., `feature-spec-generator` + `mechanic-implementation-guide`)

**Last Updated:** 2026-01-05
**Skills Created:** 17/40+ planned
**Current Project Phase:** Phase 5 (Vertical Slice Development) for Salvage Warfare

---

## Recently Added Skills

### 2026-01-05 - Implementation Skills
- ✅ `feature-implementer` - Implement features from specs with full documentation (v2.0 - enhanced with game design alignment, detailed player-visible changes, comprehensive testing)

### 2025-12-21 - Project Setup & Organization
- ✅ `godot-project-setup` - Create standard Godot folder structure for new projects

### 2025-12-21 - Vertical Slice Planning Skills
- ✅ `vertical-slice-gdd-generator` - Expand prototype GDD to polished vertical slice plan
- ✅ `vertical-slice-roadmap-planner` - Create implementation roadmap with production phases

### 2025-12-21 - Documentation & Planning Skills
- ✅ `production-gdd-generator` - Comprehensive GDD for full production
- ✅ `changelog-updater` - Track development progress and changes
- ✅ `version-control-helper` - Git workflows and best practices
- ✅ `design-bible-updater` - Document design vision and creative pillars
- ✅ `systems-bible-updater` - Technical system documentation
