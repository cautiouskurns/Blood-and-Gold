---
name: prototype-gdd-generator
description: Generate structured Game Design Documents for prototypes through interactive Q&A. Use this when the user wants to document a game concept, create a prototype GDD, or formalize their design ideas.
domain: design
type: generator
version: 1.0.0
allowed-tools:
  - Write
---

# Prototype GDD Generator Skill

This skill generates comprehensive Game Design Documents for prototype games through an **interactive questioning process**, then outputs a structured markdown document following industry-standard prototype GDD format.

---

## When to Use This Skill

Invoke this skill when the user:
- Asks to "create a GDD" or "write a design doc"
- Says "help me document my game idea"
- Wants to formalize a game concept into structured format
- Asks "how do I write a design document?"
- Says "generate a GDD for [game concept]"
- Needs to communicate game design to a team
- Wants to plan a prototype systematically

---

## Core Principle

**Structured documentation enables focused prototyping**:
- ✅ Forces designer to articulate what they're testing
- ✅ Separates core mechanics from scope creep
- ✅ Defines success criteria before building
- ✅ Creates shared understanding for team
- ✅ Provides decision framework during development
- ✅ Documents design intent for future reference

---

## Interactive Questioning Workflow

### Phase 1: Core Concept (Required)

**Always start with these questions:**

```
I'll help you create a Prototype Game Design Document! Let's start with the core concept:

**1. Game Concept**
In 1-2 sentences, what is your game?
(Example: "A tactical auto-battler where you program weapon AI before battle, then survive waves while controlling movement")

**2. Elevator Pitch**
If you had 30 seconds to pitch this, what would you say?
(Combine genre, core mechanic, and hook)

**3. Design Pillars**
What are the 2-4 core principles that define this game?
(Example: "Tactical Programming Over Reflexes", "Emergent Complexity from Simple Rules")

**4. Primary Influences**
Which 2-5 games inspire this concept?
For each, explain WHAT you're taking from it.
(Example: "Vampire Survivors - 15-min runs with level-up choices, but NOT the direct aiming")
```

**Wait for user response before proceeding.**

---

### Phase 2: Prototype Questions (Critical Testing Focus)

**After receiving Phase 1 answers, ask:**

```
Great! Now let's define what this prototype needs to TEST:

**5. Critical Questions**
What are the 3-5 core questions this prototype must answer?
Format: "Does [mechanic] feel [quality]?"

Examples:
- "Does pre-battle programming feel strategic (not arbitrary)?"
- "Is the execution phase satisfying to watch?"
- "Can players understand why they won/lost?"

**6. Success vs Failure**
For each critical question, what does SUCCESS look like? What does FAILURE look like?

Example:
Q: "Does programming feel strategic?"
Success = Players discuss rule choices, experiment with setups
Failure = Players ignore rules, pick randomly

**7. Timeline**
How long do you have for this prototype?
- [ ] Weekend (2-3 days)
- [ ] Week (5-7 days)
- [ ] Two weeks
- [ ] Month
- [ ] Other: _______
```

**Wait for user response before proceeding.**

---

### Phase 3: Core Mechanics (Deep Dive)

**After receiving Phase 2 answers, ask:**

```
Perfect! Now let's break down the mechanics:

**8. Core Mechanic #1**
What is the PRIMARY mechanic players interact with?
(Example: "Weapon Rule System - assign targeting rules to weapons")

Describe:
- How it works (step-by-step)
- Player inputs required
- System outputs/feedback
- Why it's interesting

**9. Supporting Mechanics**
What are the 2-4 supporting mechanics?
(Example: "WASD movement", "Wave-based enemy spawning", "Level-up system")

For each:
- Brief description
- How it interacts with core mechanic

**10. Content Scope**
How many of each content type?
- Player abilities/weapons/actions: X
- Enemy types: X
- Levels/arenas: X
- Win condition: (describe)
- Lose condition: (describe)
```

**Wait for user response before proceeding.**

---

### Phase 4: Scope Definition (What's In/Out)

**After receiving Phase 3 answers, ask:**

```
Almost there! Let's define the scope boundaries:

**11. What's IN the Prototype** (Minimum Viable)
What MUST be in the prototype to test your critical questions?
List features/systems required for meaningful playtest.

**12. What's OUT of the Prototype** (Explicitly Excluded)
What are you intentionally NOT building?
These are features that would be nice but distract from testing core questions.

For each OUT item, explain WHY it's excluded.
(Example: "❌ Multiple arenas - Reason: Testing gameplay, not variety")

**13. Target Playtime**
How long should a single playthrough take?
(Example: "15 minutes per run" or "5-minute rounds")
```

**Wait for user response before proceeding.**

---

### Phase 5: Implementation & Success Metrics

**After receiving Phase 4 answers, ask:**

```
Final questions!

**14. Implementation Phases**
Break your timeline into phases. For each phase:
- Goal (what you're building)
- Deliverables (specific features)
- Test criteria (how you know it works)

Example:
Phase 1 (Day 1 Morning - 4h): Movement & Basic Combat
- Goal: Player moves, weapon auto-fires
- Deliverables: WASD movement, one weapon, enemy spawning
- Test: Can kill enemies with basic weapon

**15. Success Metrics**
How will you MEASURE if the prototype succeeded?

Qualitative (playtester observations):
- What should playtesters SAY? (quotes)
- What should playtesters DO? (behaviors)

Quantitative (numbers):
- Session length target
- Completion rate target
- "One more run" rate

**16. Known Risks**
What could go wrong? For each risk:
- Risk: [What might fail]
- Mitigation: [How to prevent it]
- Fallback: [What to do if it happens anyway]

Example:
Risk: Rules feel arbitrary, don't affect outcome
Mitigation: Make enemies explicitly weak to certain rules
Fallback: Add "Effective" tag when rule matches enemy
```

**Wait for user response before proceeding.**

---

### Phase 6: Generate GDD

**After gathering all answers, generate the full GDD.**

Use this structure:

```markdown
# [GAME TITLE] - Prototype Design Document

**Version:** [Version] - [Prototype Type]
**Goal:** [One-sentence goal from critical questions]
**Timeline:** [Timeline from answers]
**Date:** [Current date]

---

## 1. CONCEPT

### Elevator Pitch
[From Phase 1, Q2]

### Design Pillars
[From Phase 1, Q3 - expand each pillar with 2-3 sentences]

**[Pillar 1 Name]**
[Description and why it matters]

**[Pillar 2 Name]**
[Description and why it matters]

### Primary Influences
[From Phase 1, Q4]

**[Game 1]**
- What we're taking: [Specific mechanic/feel]
- Applies: [How it applies to our game]

**[Game 2]**
[Same format]

---

## 2. WHAT WE'RE TESTING

### Critical Questions
[From Phase 2, Q5 - numbered list]

**Q1: [Question]**
- Success = [Success criteria]
- Failure = [Failure criteria]

**Q2: [Question]**
[Same format]

### Success Criteria
[From Phase 5, Q15]

After [timeline] playtest, score each question 1-5:
- 1 = Doesn't work at all
- 3 = Works but needs improvement
- 5 = Works great, build full game

**Decision Threshold:**
- [X-Y] points: Build full game
- [X-Y] points: Iterate and retest
- <[X] points: Pivot or kill

---

## 3. CORE MECHANICS

### [Core Mechanic Name]
[From Phase 3, Q8 - detailed description]

**How It Works:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Player Inputs:**
[What player does]

**System Response:**
[What game does in response]

**Interactions:**
[How this connects to other mechanics]

### [Supporting Mechanic 1]
[From Phase 3, Q9]

**Specifics:**
[Detailed breakdown]

**Interactions:**
[How it connects to core mechanic]

### [Supporting Mechanic 2]
[Same format for each supporting mechanic]

---

## 4. CONTENT SCOPE

### [Content Type 1] ([Number] types)
[From Phase 3, Q10]

**[Item 1]:**
- [Stats/attributes]
- [Behavior]
- [Purpose/role]

**[Item 2]:**
[Same format]

### [Content Type 2]
[Same format for enemies/levels/etc.]

---

## 5. PROTOTYPE SCOPE

### What's IN (Minimum Viable)
[From Phase 4, Q11]

**[System Category 1]:**
- [Feature 1]
- [Feature 2]

**[System Category 2]:**
[Same format]

### What's OUT (Not for Prototype)
[From Phase 4, Q12]

**❌ [Feature Name]**
- Reason: [Why excluded]
- Prototype: [What you're doing instead]

**❌ [Feature Name]**
[Same format]

---

## 6. IMPLEMENTATION PHASES

### [Phase 1 Name] ([Timeline] - [Hours])
[From Phase 5, Q14]

**Goal:** [What you're building]

**Deliverables:**
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Test:** [How you know it works]

---

### [Phase 2 Name]
[Same format for each phase]

---

## 7. SUCCESS METRICS

### Playtester Observations ([When])
[From Phase 5, Q15 - qualitative]

**During [Phase/Screen]:**
- Do they [behavior]? (Good: [example] Bad: [example])
- Do they [behavior]? (Good: [example] Bad: [example])

**After Run:**
- Ask: "[Question]" (Want: [desired answer])
- Ask: "[Question]" (Want: [desired answer])

### Quantitative Targets
[From Phase 5, Q15 - quantitative]

- [Metric]: [Target] ([context])
- [Metric]: [Target] ([context])

---

## 8. RISK MITIGATION
[From Phase 5, Q16]

**Risk: [Risk description]**
- Mitigation: [How to prevent]
- Fallback: [What to do if happens]

**Risk: [Risk description]**
[Same format]

---

## 9. POST-PROTOTYPE DECISION TREE

### If Score [High Range] (Build Full Game)

**Immediate Next Steps:**
- [Feature to add]
- [System to expand]
- [Content to create]

**Timeline:** [Estimated timeline to v1.0]

### If Score [Medium Range] (Iterate)

**Identified Issues → Solutions:**
- [Issue] → [Solution]
- [Issue] → [Solution]

**Timeline:** [Iteration timeline], retest, reassess

### If Score [Low Range] (Pivot/Kill)

**Exit Criteria:**
- [Fundamental flaw 1]
- [Fundamental flaw 2]

**Pivot Options:**
- [Alternative approach 1]
- [Alternative approach 2]

---

**END OF DESIGN DOCUMENT**

This prototype tests: [Restate core question from Section 2]. By [end date], you'll know.
```

---

## Output File Naming

**Save GDD to:**
```
docs/[game-name-kebab-case]-prototype-gdd.md
```

**Examples:**
- `docs/mech-survivors-prototype-gdd.md`
- `docs/tower-defense-prototype-gdd.md`
- `docs/deck-builder-prototype-gdd.md`

---

## Section Guidelines

### Concept Section
- **Elevator Pitch**: 1-2 sentences max, focus on hook
- **Design Pillars**: 2-4 pillars, each gets 3-5 sentence explanation
- **Influences**: Be specific about WHAT you're taking (not just "inspired by X")

### What We're Testing Section
- **Critical Questions**: Format as "Does X feel Y?" or "Can players do Z?"
- **Success Criteria**: Concrete observable behaviors, not vague feelings
- **Decision Threshold**: Numerical scoring system (forces honesty)

### Core Mechanics Section
- **One primary mechanic**: The thing the prototype tests
- **2-4 supporting mechanics**: What makes primary mechanic work
- **Detailed breakdown**: How it works step-by-step, not just description

### Prototype Scope Section
- **What's IN**: Only what's needed to answer critical questions
- **What's OUT**: Explicitly name excluded features to prevent scope creep
- **Justify exclusions**: Every OUT item needs a reason

### Implementation Phases Section
- **Break timeline into phases**: 2-6 phases depending on total timeline
- **Each phase has goal + deliverables + test**: Concrete milestones
- **Time estimates**: Hour estimates for accountability

### Success Metrics Section
- **Qualitative observations**: What to watch for during playtests
- **Quantitative targets**: Numbers to hit (completion rate, session length)
- **Post-playtest questions**: Specific questions to ask playtesters

### Risk Mitigation Section
- **Identify risks early**: What could make prototype fail to answer questions
- **Mitigation first**: How to prevent the risk
- **Fallback second**: What to do if mitigation doesn't work

### Decision Tree Section
- **Three outcomes**: Build full game, iterate, pivot/kill
- **Concrete score ranges**: Based on success criteria scoring
- **Next steps for each**: What to do in each scenario

---

## Important Guidelines

### Keep It Prototype-Focused
- ❌ Don't plan full game features
- ✅ Focus on testing core questions
- ❌ Don't include monetization, meta-progression, etc.
- ✅ Include only what's needed for meaningful playtest

### Be Ruthlessly Specific
- ❌ Vague: "Good controls"
- ✅ Specific: "WASD movement at 200 px/s"
- ❌ Vague: "Fun weapons"
- ✅ Specific: "5 weapons: Machine Gun (5 dmg, 5/s, 300px range)..."

### Define Success Measurably
- ❌ "Players like it"
- ✅ "Players play 3+ runs in first session"
- ❌ "Combat feels good"
- ✅ "Players can explain why they won/lost after run"

### Scope Ruthlessly
- Default to LESS for prototype
- Every feature should answer a critical question
- If it doesn't test core loop, it's OUT
- You can add it to the full game later

---

## Example Invocations

User: "Help me write a GDD for my tower defense game"
User: "Create a design document for my roguelike prototype"
User: "I need to document my game idea"
User: "Generate a GDD based on this concept: [describes game]"
User: "How do I write a design doc for a weekend prototype?"

---

## Workflow Summary

1. **Ask Phase 1 questions** (concept, pitch, pillars, influences)
2. **Wait for user response**
3. **Ask Phase 2 questions** (critical questions, success criteria, timeline)
4. **Wait for user response**
5. **Ask Phase 3 questions** (core mechanics, supporting mechanics, content)
6. **Wait for user response**
7. **Ask Phase 4 questions** (scope: what's in/out, target playtime)
8. **Wait for user response**
9. **Ask Phase 5 questions** (implementation phases, metrics, risks)
10. **Wait for user response**
11. **Generate complete GDD** following template structure
12. **Save to `docs/[game-name]-prototype-gdd.md`**
13. **Confirm file location to user**

---

## Tips for Quality GDDs

### For the User
- **Be honest about timeline**: Don't plan 2 weeks of work for a weekend
- **Answer "why"**: Every mechanic should have a purpose
- **Think about testing**: How will you know if it works?
- **Cut ruthlessly**: Prototype scope should feel uncomfortably small

### For Claude
- **Ask follow-up questions**: If answer is vague, ask for specifics
- **Push back on scope creep**: If user includes too much, ask which features test critical questions
- **Suggest improvements**: If critical questions are vague, help sharpen them
- **Use examples**: Reference similar games to clarify unclear concepts

---

## Quality Checklist

Before finalizing GDD, verify:
- ✅ Every mechanic maps to a critical question
- ✅ Success criteria are observable behaviors (not feelings)
- ✅ Timeline is realistic (not aspirational)
- ✅ Scope has clear IN/OUT boundaries with justifications
- ✅ Implementation phases have concrete deliverables
- ✅ Risks have both mitigation AND fallback plans
- ✅ Decision tree has numerical thresholds
- ✅ All sections use specific numbers/details (not vague descriptions)

---

This skill transforms vague game ideas into structured, testable prototype plans. The interactive workflow ensures the designer thinks critically about what they're building and why.
