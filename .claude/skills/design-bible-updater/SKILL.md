---
name: design-bible-updater
description: Create and maintain a Game Design Bible documenting design vision, pillars, mechanics philosophy, and creative direction. Use this when establishing design principles or documenting high-level creative decisions.
domain: design
type: updater
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
---

# Design Bible Updater Skill

This skill creates and maintains a comprehensive Game Design Bible that captures the creative vision, design philosophy, and guiding principles for the entire project.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "create a design bible" or "write design principles"
- Asks "how do I document our design vision?"
- Wants to establish design pillars and philosophy
- Says "update design bible with [new principle/decision]"
- Needs to onboard new team members to design vision
- Makes a major creative direction decision
- Wants to resolve design disagreements with documented principles

---

## Core Principle

**Design Bibles are north stars for creativity**:
- ✅ Capture WHY design decisions are made
- ✅ Define what makes this game unique
- ✅ Guide all future design decisions
- ✅ Prevent feature creep and scope drift
- ✅ Align team on creative vision
- ✅ Living document updated as vision evolves

---

## Design Bible vs GDD

| Aspect | Design Bible | GDD (Game Design Doc) |
|--------|--------------|----------------------|
| **Purpose** | WHY and creative vision | WHAT and HOW of implementation |
| **Content** | Philosophy, pillars, tone | Mechanics, systems, specs |
| **Audience** | Designers, artists, writers | Entire dev team |
| **Scope** | High-level creative direction | Detailed feature specifications |
| **Changes** | Rarely (foundational) | Frequently (iterative) |
| **Length** | 5-20 pages | 50-200+ pages |

**Relationship:** Design Bible informs GDD. GDD implements Design Bible vision.

---

## Design Bible Structure

```markdown
# [GAME TITLE] - Game Design Bible

**Version:** [X.Y]
**Status:** [Living Document]
**Created:** [Date]
**Last Updated:** [Date]
**Lead Designer:** [Name]

---

## VISION STATEMENT

[1-2 paragraphs: What is this game at its core? What player experience are we creating? Why does this game need to exist?]

**Example:**
"Mech Survivors is about the satisfaction of watching a perfectly programmed machine execute your tactical vision. We're creating the feeling of being a brilliant tactician who designed an unbeatable combat AI. Players should feel smart when they win, and understand exactly what to adjust when they lose. This is Into the Breach's perfect information tactics meets Vampire Survivors' escalating power fantasy."

---

## DESIGN PILLARS

[3-5 core principles that define ALL design decisions]

### Pillar 1: [Name]

**Principle:**
[2-3 sentence explanation]

**What This Means:**
- [Specific implication 1]
- [Specific implication 2]
- [Specific implication 3]

**In Practice:**
[Concrete example of how this pillar manifests in game]

**What We DON'T Do:**
[Anti-examples - what this pillar prevents]

**Metrics:**
[How we measure if we're achieving this]

---

**Example Pillar:**

### Pillar 1: Tactical Programming Over Reflexes

**Principle:**
Players succeed through smart pre-battle preparation and weapon rule design, not through execution skill or twitch reactions. Victory should feel earned through clever strategy, not lucky dodging.

**What This Means:**
- All weapon targeting is automatic based on programmed rules
- Combat is deterministic given the same setup
- Player only controls movement (positioning, not aiming)
- "Skill" = understanding enemy patterns and programming counters
- No random critical hits or luck-based mechanics

**In Practice:**
- Weapon Rule System: Players assign Target Priority (Closest/Weakest/Strongest) and Firing Conditions (Always/Optimal Range/Save for Elite)
- Setup Phase: 30-60 seconds to program weapons before each run
- Execution Phase: Watch strategy unfold, only dodge enemy fire
- Iteration: Losses teach "my railgun targeted swarms instead of elites - adjust rules"

**What We DON'T Do:**
- ❌ No manual aiming or firing
- ❌ No "skill shot" mechanics
- ❌ No speed-running based on execution skill
- ❌ No hidden information that prevents planning

**Metrics:**
- Can players explain why they lost? (Post-playtest question)
- Do 80%+ of players watch their weapons during combat? (Observation)
- Are different rule setups discussed/shared? (Community engagement)

---

### Pillar 2: [Name]
[Same structure]

### Pillar 3: [Name]
[Same structure]

---

## PLAYER FANTASY

**Who is the player in this game?**
[Describe the role/fantasy]

**What do they do?**
[Core player actions]

**How should they feel?**
[Target emotions]

**Aspirational Experience:**
[The "perfect session" description]

---

**Example:**

**Who is the player in this game?**
A brilliant mech engineer and tactician who programs combat AI for autonomous war machines. You're the commander who designs the strategy before battle, not the pilot in the cockpit.

**What do they do?**
Analyze enemy compositions, design weapon targeting rules, optimize combat algorithms, and iterate on failed strategies. You're solving tactical puzzles through programming logic.

**How should they feel?**
- **Smart** when your programmed strategy perfectly counters the enemy wave
- **Scientific** when testing "what if I prioritize elites over swarms?"
- **Powerful** when your perfectly-tuned mech annihilates waves on autopilot
- **Reflective** when analyzing why your setup failed and planning improvements

**Aspirational Experience:**
"I programmed my machine gun to target closest enemies to handle swarms, my railgun to save ammo for elites, and missiles to fire at grouped targets. I watched the first wave - my machine gun cleared the scouts perfectly, but I realized I needed more anti-armor when tanks overwhelmed me. Next run, I swapped laser for railgun #2 targeting strongest enemies. Now I'm unstoppable up to wave 10. I wonder what happens if I try triple missiles with group targeting..."

---

## TONE & SETTING

### Visual Tone
[Art direction, color palette, visual style]

### Narrative Tone
[Story/writing voice, humor level, seriousness]

### Audio Tone
[Music style, SFX approach]

### Overall Feeling
[The mood/atmosphere]

---

## DESIGN PHILOSOPHY

### Mechanics Philosophy

**Depth Through Simplicity:**
[How you create depth - through combinations, emergence, mastery]

**Player Agency:**
[What players control, what they don't, why]

**Feedback & Communication:**
[How game teaches and informs players]

**Difficulty Philosophy:**
[How you challenge players, what "hard" means]

---

### Content Philosophy

**Quality vs Quantity:**
[Approach to content volume]

**Variety vs Depth:**
[Do you create many options or deep systems?]

**Replayability Source:**
[What makes players return? Randomness? Skill ceiling? Unlocks?]

---

### Progression Philosophy

**Power Fantasy:**
[How players become more powerful]

**Skill Growth:**
[How players become more skilled (vs just more powerful)]

**Reward Pacing:**
[Frequency and type of rewards]

---

## WHAT THIS GAME IS / IS NOT

### This Game IS:
- [Core identity statement 1]
- [Core identity statement 2]
- [Core identity statement 3]

### This Game IS NOT:
- [Anti-pattern 1 - what we explicitly avoid]
- [Anti-pattern 2]
- [Anti-pattern 3]

---

**Example:**

### This Game IS:
- A tactical puzzle game with action game presentation
- About understanding systems and optimizing strategies
- Deterministic and analyzable (same setup = same result)
- Satisfying to watch when your strategy works
- Accessible through simple rules, deep through combinations

### This Game IS NOT:
- A twitch shooter or bullet hell (no manual aiming)
- A pure idle game (player actively manages positioning)
- Random or luck-based (no crit RNG)
- A long-term progression grind (prototype = 15min runs)
- About mechanical execution skill (about tactical planning)

---

## REFERENCE GAMES

[Games that inspire this project - be specific about WHAT you take from each]

### [Reference Game 1]
**What We Take:**
- [Specific mechanic or feeling]

**What We DON'T Take:**
- [What we explicitly avoid from this game]

**Why It Matters:**
- [What this reference teaches us]

---

**Example:**

### Into the Breach
**What We Take:**
- Perfect information tactics (you see enemy attacks before they happen)
- Turn-based puzzle-combat feel (even though we're real-time)
- Deterministic outcomes (same setup = same result)
- "I understand why I failed" clarity

**What We DON'T Take:**
- Turn-based structure (we're real-time)
- Grid-based movement (we're free movement)
- Civilian protection objectives (we're pure survival)

**Why It Matters:**
Into the Breach proves players love tactical puzzles where they can PLAN and SEE their strategy work. We want that "aha!" moment when the perfect setup clicks.

---

### Vampire Survivors
**What We Take:**
- 15-20 minute escalating power fantasy runs
- Level-up choice moments (build customization)
- Wave-based survival structure
- Satisfying screen-filling destruction

**What We DON'T Take:**
- Manual aiming (we're rule-based)
- Hundreds of unlock meta-progression (prototype = all available)
- Screen-filling chaos (we want tactical clarity)

**Why It Matters:**
VS proves short runs with escalating power are addictive. We want the "one more run" feeling, but driven by tactical iteration, not grind unlocks.

---

## DESIGN DECISION FRAMEWORK

**When evaluating new features or changes, ask:**

1. **Does it support our pillars?**
   - If it violates a pillar → reject or redesign
   - If neutral → question if needed
   - If reinforces pillar → strong candidate

2. **Does it serve the player fantasy?**
   - Does it make player feel like [fantasy role]?
   - Does it distract from core fantasy?

3. **Is it true to "What This Game IS"?**
   - Check against IS/IS NOT list

4. **Does it create depth or just complexity?**
   - Depth = mastery, emergence, meaningful choices
   - Complexity = confusion, busywork, cognitive load

5. **Can we communicate it clearly?**
   - If players won't understand it, redesign or cut

---

## SACRED COWS & NEGOTIABLES

### Sacred Cows (Never Change)
[Features/principles that define this game - remove them and it's not the same game]

- [Sacred element 1]
- [Sacred element 2]

### Negotiables (Can Change)
[Features that support the vision but aren't core identity]

- [Negotiable element 1]
- [Negotiable element 2]

---

**Example:**

### Sacred Cows
- **Weapon Rule System** - This IS the game. Remove rule programming → not Mech Survivors
- **Auto-firing based on rules** - Players never manually aim. This defines the tactical focus
- **Deterministic outcomes** - Same setup = same result. No RNG on core mechanics
- **15-minute runs** - The time constraint creates meaningful iteration loops

### Negotiables
- **Exact enemy types** - Could be 5 types or 10, mechs or aliens, doesn't change core
- **Visual style** - Could be pixel art, 3D, minimalist - doesn't affect gameplay identity
- **Number of weapons** - Could be 3 or 8, as long as rules system works
- **Wave structure** - Continuous spawning vs rounds - affects feel but not identity

---

## OPEN QUESTIONS & DESIGN TENSIONS

[Unresolved design debates, competing priorities, things to playtest]

### Question 1: [Design question]
**Tension:** [What's in conflict]
**Options:**
- Option A: [Approach 1 and trade-offs]
- Option B: [Approach 2 and trade-offs]
**Resolution Needed:** [When/how we'll decide]

---

## CHANGELOG

[Track major design direction changes]

### [Date] - [Change Description]
**What Changed:** [Design principle/pillar update]
**Why:** [Rationale based on playtest/iteration]
**Impact:** [How this affects existing design]

---

**Example:**

### 2025-12-21 - Clarified "Tactical Programming" Pillar
**What Changed:** Added explicit statement "no manual aiming" to Pillar 1
**Why:** Playtester suggested adding WASD+mouse aiming - violated core pillar
**Impact:** Reinforces that ALL targeting is rule-based; player only controls positioning

---

## APPENDICES

### Appendix A: Glossary
[Define game-specific terms]

### Appendix B: Inspirational Media
[Art, music, games, movies that capture the vibe]

### Appendix C: Rejected Ideas Log
[Ideas considered and rejected, with reasons - prevents re-litigating]

---

**END OF DESIGN BIBLE**

This document defines WHO WE ARE. The GDD defines WHAT WE BUILD.
```

---

## Workflow

### Creating New Design Bible

1. **Ask foundational questions:**
   - What's the core player fantasy?
   - What makes this game unique?
   - What are the 3-5 design pillars?
   - Who are reference games and why?

2. **Generate initial bible:**
   - Vision statement
   - Design pillars with examples
   - Player fantasy description
   - IS/IS NOT lists

3. **Save to `docs/design-bible.md`**

---

### Updating Existing Bible

1. **Read current design bible**

2. **Ask what changed:**
   - New design principle discovered?
   - Pillar needs clarification?
   - Made important creative decision?
   - Resolved design tension?

3. **Update appropriate section:**
   - Add to changelog with rationale
   - Update relevant pillar/philosophy
   - Add to rejected ideas if applicable

4. **Verify consistency:**
   - Does new change align with existing pillars?
   - Update IS/IS NOT if needed

---

## Example Interactions

**User:** "Create a design bible for Mech Survivors"

**Skill:** Asks questions about:
- Core player fantasy (tactician vs pilot)
- Design pillars (programming over reflexes, etc.)
- Reference games (Into the Breach, VS)
- What makes it unique (weapon rule system)

Generates comprehensive design bible with vision, pillars, philosophy.

---

**User:** "Add to design bible: We decided movement speed should be fast, not slow tactical"

**Skill:**
```
I'll add this to the Design Philosophy section under "Mechanics Philosophy".

Which pillar does this support?
- This seems related to the balance between tactical planning and action feel
- Should I clarify in Pillar 2 that movement is arcade-style for screen presence?

I'll also add a changelog entry documenting this decision.
```

---

## Integration with Other Skills

### With `prototype-gdd-generator`
- Design Bible informs GDD's design pillars
- GDD references Bible for design decisions
- Bible explains WHY, GDD explains WHAT

### With `feature-spec-generator`
- Feature specs should align with design pillars
- Reference Bible when evaluating feature fit

### With `changelog-updater`
- Design Bible has its own changelog
- Major design direction changes documented

---

## Quality Checklist

Before finalizing design bible:
- ✅ Vision statement is clear and inspiring
- ✅ Each pillar has concrete examples and anti-examples
- ✅ IS/IS NOT list prevents common scope creep
- ✅ Sacred Cows vs Negotiables clearly separated
- ✅ Reference games explain WHAT we take (not just listed)
- ✅ Design decision framework is actionable
- ✅ Writing is clear and avoids jargon

---

## Example Invocations

User: "Create a design bible"
User: "Write design pillars for my game"
User: "Update design bible - we're changing combat pacing"
User: "Document our creative vision"
User: "What should go in a design bible?"

---

## Workflow Summary

1. Check if `docs/design-bible.md` exists
2. If new: Ask foundational questions about vision, pillars, fantasy
3. If exists: Read current bible
4. Ask what needs updating/adding
5. Update appropriate section(s)
6. Add changelog entry for major changes
7. Verify consistency with existing principles
8. Save updated design bible
9. Confirm changes to user

---

This skill ensures creative vision is documented, communicated, and guides all design decisions throughout development.
