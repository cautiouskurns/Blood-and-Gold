---
name: feature-idea-designer
description: Refine vague feature ideas into structured Feature Idea Briefs through interactive Q&A. Use this when the user has a rough idea that needs fleshing out before creating a full feature spec.
domain: project
type: generator
version: 1.0.0
allowed-tools:
  - Write
  - Read
  - Glob
---

# Feature Idea Designer Skill

This skill takes rough, vague feature ideas and refines them through **interactive Q&A** into a structured **Feature Idea Brief** that serves as input for the Feature Spec Generator.

---

## When to Use This Skill

Invoke this skill when the user:
- Has a vague idea: "I want some kind of progression system"
- Knows the problem but not the solution: "Combat feels flat"
- Wants to explore options before committing: "What could a shop system look like?"
- Needs help defining scope: "I'm not sure how big this should be"
- Says "flesh out this idea" or "help me design [feature]"
- Wants a brainstorming session for a feature area

**Do NOT use this skill when:**
- User already has a clear, well-defined feature concept (use Feature Spec Generator instead)
- User wants implementation details (use Feature Implementer instead)
- User is asking about game-wide concepts (use Game Concept Generator instead)

---

## Core Principle

**Interactive exploration** ensures the resulting Feature Idea Brief is:
- ✅ Aligned with the game's design pillars
- ✅ Solving the right problem
- ✅ Scoped appropriately for the project phase
- ✅ Ready for full specification
- ✅ Clearly bounded (what's IN vs OUT)

---

## Interactive Workflow

### Phase 1: Understand the Problem (Required)

**Always start by understanding what problem they're trying to solve:**

```
I'll help you flesh out this feature idea! Let me understand what you're working with:

**1. The Problem**
What issue or gap are you trying to address?
- [ ] Something feels missing from the game
- [ ] An existing system isn't satisfying
- [ ] Players need a new capability
- [ ] Technical/design debt needs addressing
- [ ] Just exploring ideas

**2. Player Experience Goal**
How should players FEEL or what should they be able to DO?
(Example: "Feel powerful", "Make strategic choices", "Have something to spend resources on")

**3. Initial Idea (if any)**
Do you have a rough direction in mind, or are you starting from scratch?
```

**Wait for user response before proceeding.**

---

### Phase 2: Gather Context (Research)

**After receiving Phase 1 answers, gather project context:**

1. **Read the GDD** - Search for `**/*gdd*.md`, `**/*design-bible*.md`
2. **Check the Roadmap** - Search for `**/*roadmap*.md`
3. **Review existing systems** - Understand what's already built

**Then ask:**

```
Thanks! I've reviewed your game design documents. Let me ask a few more questions:

**4. Design Pillar Alignment**
Which of your design pillars should this feature support?
[List pillars from GDD if found]

**5. Existing Systems**
How might this interact with systems you already have?
- Combat system
- Progression/XP
- Inventory
- Economy (scrap)
- [Other systems found in codebase]

**6. Reference Games**
Any games that do something similar to what you're imagining?
(This helps me understand the "feel" you're going for)
```

**Wait for user response before proceeding.**

---

### Phase 3: Explore Solutions (Brainstorming)

**After gathering context, present 2-3 possible approaches:**

```
Based on what you've shared, here are some approaches we could take:

## Approach A: [Name]
**Core idea:** [Brief description]
**Pros:** [Benefits]
**Cons:** [Drawbacks]
**Scope:** Small/Medium/Large

## Approach B: [Name]
**Core idea:** [Brief description]
**Pros:** [Benefits]
**Cons:** [Drawbacks]
**Scope:** Small/Medium/Large

## Approach C: [Name] (Hybrid/Alternative)
**Core idea:** [Brief description]
**Pros:** [Benefits]
**Cons:** [Drawbacks]
**Scope:** Small/Medium/Large

**Which direction appeals to you?** Or would you like to combine elements?
```

**Wait for user response before proceeding.**

---

### Phase 4: Define Scope & Boundaries

**After user picks a direction, clarify scope:**

```
Great choice! Let's nail down the boundaries:

**7. Must-Have Features**
What absolutely MUST be in the first version?
(List 3-5 core elements)

**8. Nice-to-Have Features**
What would be great to add if time permits?
(Polish, extra options, edge cases)

**9. Explicitly Out of Scope**
What should we consciously leave out?
(Prevents scope creep later)

**10. Open Questions**
What decisions can wait until the spec phase?
(Things that need more research or testing)
```

**Wait for user response before proceeding.**

---

### Phase 5: Generate Feature Idea Brief

**After all phases, generate the Feature Idea Brief document.**

---

## Output Format: Feature Idea Brief

Save to `docs/ideas/[feature-name]-idea.md`:

```markdown
# Feature Idea Brief: [Feature Name]

**Created:** [Date]
**Status:** Ready for Spec
**Author:** [User] + Claude (Feature Idea Designer)

---

## Problem Statement

**The Problem:**
[1-2 sentences describing what issue this addresses]

**Why It Matters:**
[Why this problem is worth solving for the game]

**Current State:**
[How things work now / what's missing]

---

## Player Experience Goal

**Players should feel:**
[Emotional/experiential goals]

**Players should be able to:**
[Concrete capabilities they gain]

**Success looks like:**
[Observable outcomes when feature works well]

---

## Design Pillar Alignment

| Pillar | How This Feature Supports It |
|--------|------------------------------|
| [Pillar 1] | [Explanation] |
| [Pillar 2] | [Explanation] |

---

## Proposed Approach

**Direction:** [Chosen approach name]

**Core Concept:**
[2-3 paragraph description of how this feature works at a high level]

**Key Elements:**
1. [Element 1] - [Brief description]
2. [Element 2] - [Brief description]
3. [Element 3] - [Brief description]

**Player Flow:**
1. [Step 1 - What triggers/enters the feature]
2. [Step 2 - What the player does]
3. [Step 3 - What happens as a result]
4. [Step 4 - How they exit/continue]

---

## Scope Definition

### In Scope (Must-Have)
- [ ] [Core feature 1]
- [ ] [Core feature 2]
- [ ] [Core feature 3]
- [ ] [Core feature 4]

### Nice-to-Have (Stretch)
- [ ] [Polish item 1]
- [ ] [Extra feature 1]
- [ ] [Edge case handling]

### Explicitly Out of Scope
- ❌ [Thing we're NOT doing 1]
- ❌ [Thing we're NOT doing 2]
- ❌ [Future consideration]

**Rationale for scope:** [Why these boundaries make sense]

---

## Integration Points

**Connects to:**
- [System 1] - [How it connects]
- [System 2] - [How it connects]

**Data it needs:**
- [Data from existing system]

**Data it provides:**
- [Data for other systems to use]

---

## Reference Games

| Game | What to Study |
|------|---------------|
| [Game 1] | [Specific mechanic or feel] |
| [Game 2] | [Specific mechanic or feel] |

---

## Open Questions

These need resolution during spec/implementation:

1. **[Question 1]** - [Context]
2. **[Question 2]** - [Context]
3. **[Question 3]** - [Context]

---

## Alternatives Considered

### [Alternative A]
- **Idea:** [Brief description]
- **Why not:** [Reason for not choosing]

### [Alternative B]
- **Idea:** [Brief description]
- **Why not:** [Reason for not choosing]

---

## Next Steps

1. [ ] Review this brief with [stakeholders if any]
2. [ ] Run `/feature-spec-generator` with this brief as input
3. [ ] Create implementation plan
4. [ ] Build it!

---

## Ready for Spec: ✅

This feature idea is ready to be turned into a full specification.

**Recommended spec ID:** [Phase.Number]-[feature-name]
**Estimated complexity:** Low / Medium / High
```

---

## Questioning Guidelines

### Good Questions to Ask

**For vague problems:**
- "What feels wrong or missing right now?"
- "When do players get stuck or frustrated?"
- "What would make [activity] more satisfying?"

**For unclear scope:**
- "If you could only have ONE thing, what would it be?"
- "What's the simplest version that would still be valuable?"
- "What would you add in version 2?"

**For design alignment:**
- "How does this support [design pillar]?"
- "Does this fit the player fantasy of [fantasy from GDD]?"
- "Is this in the vertical slice scope or future scope?"

**For technical clarity:**
- "How would this interact with [existing system]?"
- "Where does this data live?"
- "What triggers this feature?"

### Questions to Avoid

❌ Leading questions that assume a solution
❌ Yes/no questions that don't explore
❌ Technical implementation questions (save for spec)
❌ Questions already answered in GDD/roadmap

---

## Quality Criteria for Feature Idea Briefs

### Every Brief Must Have:

1. **Clear Problem** - What issue this solves
2. **Player Goal** - How players benefit
3. **Pillar Alignment** - Connection to design vision
4. **Defined Scope** - Clear IN/OUT boundaries
5. **Integration Points** - How it connects to existing systems
6. **Open Questions** - What still needs deciding

### Red Flags to Avoid:

❌ **Vague problems:** "Make the game better"
❌ **No player benefit:** Pure technical feature with no experience goal
❌ **Unbounded scope:** "Everything players could want"
❌ **Disconnected:** Doesn't relate to existing systems
❌ **Solution without problem:** Jumped to "what" without "why"

---

## Workflow Summary

1. **Ask Phase 1 questions** (problem, goal, initial idea)
2. **Wait for user response**
3. **Gather context** (read GDD, roadmap, existing systems)
4. **Ask Phase 2 questions** (pillars, systems, references)
5. **Wait for user response**
6. **Present 2-3 approaches** (brainstorm solutions)
7. **Wait for user to choose direction**
8. **Ask Phase 4 questions** (scope boundaries)
9. **Wait for user response**
10. **Generate Feature Idea Brief** to `docs/ideas/[name]-idea.md`
11. **Offer next steps** (ready for spec generator)

---

## Example Interaction

**User:** "I want some kind of shop system"

**Skill:**
```
I'll help you flesh out this shop idea! Let me understand what you're working with:

1. **The Problem** - What gap is this filling? Do players have too much scrap? Need gear variety?
2. **Player Experience Goal** - How should interacting with a shop feel?
3. **Initial Direction** - Any rough ideas on what kind of shop?
```

**User:** "Players have scrap but nothing to spend it on. Should feel like a reward for doing well."

**Skill:** [Reads GDD, checks existing economy]
```
Makes sense! Your economy gives scrap from salvage and combat. Questions:

4. Which design pillars should this support? (Tactical depth? Customization?)
5. How might this interact with your inventory and part systems?
6. Any games with shop systems you like? (FTL? Slay the Spire?)
```

**User:** "Tactical depth for sure. Should use existing parts. Love Slay the Spire's shop."

**Skill:** [Presents approaches]
```
Here are three approaches:

## Approach A: Map Node Shop (like Slay the Spire)
Fixed shop nodes on star map, visit between missions...

## Approach B: Persistent Trader
Always-available shop from bridge, refreshes after missions...

## Approach C: Event-Based Merchants
Random trader encounters during events...

Which direction appeals?
```

**User:** "Approach A - the map node shop"

**Skill:**
```
Great! Let's define scope:

7. Must-haves for v1?
8. Nice-to-haves if time permits?
9. What's explicitly NOT in this version?
10. Any open questions for later?
```

**User:** [Provides scope answers]

**Skill:** [Generates Feature Idea Brief, saves to docs/ideas/shop-system-idea.md]

---

## Example Invocations

User: "Flesh out this idea: [vague concept]"
User: "Help me design a [feature area]"
User: "I have an idea but it's not clear yet"
User: "What could a [system] look like for my game?"
User: "Brainstorm [feature type] with me"
User: "I need to think through [concept] before speccing it"

---

## Integration with Other Skills

**Inputs from:**
- User's vague idea or problem statement
- GDD (design pillars, player fantasy)
- Roadmap (where feature fits)

**Outputs to:**
- **Feature Spec Generator** - Feature Idea Brief becomes input
- **Feature Implementer** - Eventually, after spec is created

**Workflow chain:**
```
[Vague Idea] → Feature Idea Designer → [Feature Idea Brief]
                                              ↓
[Feature Idea Brief] → Feature Spec Generator → [Full Spec]
                                                      ↓
[Full Spec] → Feature Implementer → [Working Code]
```
