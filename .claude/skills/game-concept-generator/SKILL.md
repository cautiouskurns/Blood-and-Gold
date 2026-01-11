---
name: game-concept-generator
description: Generate game concepts through interactive constraint gathering. Use this when the user wants game ideas, needs inspiration, or wants to explore different game concepts based on their constraints.
domain: design
type: generator
version: 1.0.0
allowed-tools:
  - Write
---

# Game Concept Generator Skill

This skill generates game concepts through an **interactive questioning process** to understand user constraints, then produces 3-5 viable game ideas with detailed core loop descriptions.

---

## When to Use This Skill

Invoke this skill when the user:
- Asks for "game ideas" or "game concepts"
- Says "I want to make a game but don't know what"
- Requests inspiration for a game jam or prototype
- Wants to explore what's possible within constraints
- Says "generate a [genre] game concept"
- Asks "what game should I build?"

---

## Core Principle

**Interactive constraint gathering** ensures generated concepts are:
- ✅ Realistic for the user's constraints
- ✅ Aligned with their interests and skills
- ✅ Technically feasible with their tools
- ✅ Scoped appropriately for their timeline
- ✅ Unique and interesting to build

---

## Interactive Questioning Workflow

### Phase 1: Initial Context (Required)

**Always start by asking these core questions:**

```
I'll help you generate game concepts! Let me understand your constraints:

**1. Development Timeline**
How much time do you have?
- [ ] Weekend (2-3 days)
- [ ] Week (5-7 days)
- [ ] Month (4 weeks)
- [ ] Longer-term project
- [ ] Flexible / exploring ideas

**2. Target Platform**
Where will this game run?
- [ ] PC (Windows/Mac/Linux)
- [ ] Web (HTML5/WebGL)
- [ ] Mobile (iOS/Android)
- [ ] Console
- [ ] Multiple platforms

**3. Team Size**
Who's working on this?
- [ ] Solo developer
- [ ] 2-3 people
- [ ] Small team (4-6)
- [ ] Larger team

**4. Engine/Tools**
What are you building with?
- [ ] Godot
- [ ] Unity
- [ ] Unreal
- [ ] Custom engine
- [ ] Other: _______
```

**Wait for user response before proceeding.**

---

### Phase 2: Genre & Mechanics (Clarification)

**After receiving Phase 1 answers, ask:**

```
Great! Now let's narrow down the type of game:

**5. Genre Preference**
Any genres you're excited about? (Select all that apply)
- [ ] Action (combat, reflexes, timing)
- [ ] Puzzle (logic, problem-solving)
- [ ] Strategy (planning, resource management)
- [ ] RPG (progression, stats, narrative)
- [ ] Roguelike (permadeath, procedural, runs)
- [ ] Platformer (jumping, movement)
- [ ] Simulation (systems, sandbox)
- [ ] Rhythm (music, timing)
- [ ] Tower Defense
- [ ] Auto-battler
- [ ] Narrative/Story
- [ ] Hybrid (mix of above)
- [ ] Open to anything

**6. Core Mechanic Interest**
What sounds fun to implement?
- [ ] Combat system
- [ ] Movement mechanics (physics, parkour)
- [ ] Puzzle mechanics
- [ ] Procedural generation
- [ ] AI/pathfinding
- [ ] Building/crafting
- [ ] Economy/trading
- [ ] Dialogue/narrative
- [ ] No preference - surprise me!

**7. Visual Complexity**
What art style are you comfortable with?
- [ ] Minimal (shapes, colors, no art needed)
- [ ] Pixel art (sprites, tiles)
- [ ] 3D simple (basic models)
- [ ] Hand-drawn 2D
- [ ] Vector graphics
- [ ] Text-based
```

**Wait for user response before proceeding.**

---

### Phase 3: Scope & Experience (Refinement)

**After receiving Phase 2 answers, ask:**

```
Almost there! A few more questions to refine the concepts:

**8. Experience Level**
How comfortable are you with game dev?
- [ ] Beginner (first few games)
- [ ] Intermediate (made 2-5 games)
- [ ] Advanced (experienced developer)
- [ ] Expert (shipped multiple games)

**9. Scope Preference**
What kind of scope appeals to you?
- [ ] Tiny (one core mechanic, super focused)
- [ ] Small (2-3 mechanics, clear goal)
- [ ] Medium (multiple systems, 30-60 min gameplay)
- [ ] Ambitious (full game, hours of content)

**10. Inspiration or Constraints**
Anything else I should know?
- Favorite games to reference?
- Specific theme or setting?
- Technical limitations?
- Game jam theme?
- Must-have features?

(This is optional - just share anything relevant)
```

**Wait for user response before proceeding.**

---

### Phase 4: Generate Concepts

**After gathering all constraints, generate 3-5 game concepts.**

Each concept must include:
1. **Concept Name** (catchy, memorable)
2. **One-Line Pitch** (elevator pitch)
3. **Core Loop** (what the player does minute-to-minute)
4. **Key Mechanics** (2-4 primary mechanics)
5. **Unique Hook** (what makes this interesting)
6. **Scope Assessment** (realistic timeline estimate)
7. **Technical Complexity** (Low/Medium/High)
8. **Why This Works** (how it fits their constraints)

---

## Output Format

```markdown
# Game Concepts for [User]

**Your Constraints:**
- Timeline: [X days/weeks]
- Platform: [Platform]
- Team: [Team size]
- Engine: [Engine]
- Genre interests: [Genres]
- Experience: [Level]
- Scope: [Preference]

---

## Concept 1: [Concept Name]

**One-Line Pitch:**
[Compelling elevator pitch in one sentence]

**Core Loop:**
```
1. [Player action 1]
2. [System response]
3. [Player decision]
4. [Outcome/reward]
→ Repeat with escalation
```

**Key Mechanics:**
- **[Mechanic 1]**: [Brief description]
- **[Mechanic 2]**: [Brief description]
- **[Mechanic 3]**: [Brief description]

**Unique Hook:**
[What makes this concept stand out? Why is it interesting?]

**Scope Assessment:**
- **Timeline:** [X days/weeks] - [Realistic/Ambitious/Tight]
- **MVP Features:** [List 3-4 must-have features for minimum viable version]
- **Stretch Goals:** [Optional features if time permits]

**Technical Complexity:** 🟢 Low | 🟡 Medium | 🔴 High

**Why This Works for You:**
[Explain how this concept aligns with their constraints, interests, and experience level]

**Similar Games for Reference:**
- [Game 1] (for mechanic X)
- [Game 2] (for feel/aesthetic)

---

## Concept 2: [Concept Name]

[Same structure as above]

---

## Concept 3: [Concept Name]

[Same structure as above]

---

## Concept 4: [Concept Name] (Wildcard)

[Same structure - this should be a more experimental/unique idea]

---

## Concept 5: [Concept Name] (Ambitious)

[Same structure - this should be a more ambitious take if they want a challenge]

---

## Recommendation

**Best fit for your constraints:**
[Concept #X] - [Name]

**Why:** [Explain why this concept is the best match for their specific situation]

**Next Steps:**
1. Pick a concept (or hybrid ideas)
2. Create a prototype roadmap
3. Start with core loop implementation
4. Iterate based on feel

**Questions to Ask Yourself:**
- Does this concept excite you enough to finish it?
- Can you describe the core loop in one sentence?
- What's the "aha!" moment for players?
- Is the scope realistic for your timeline?

---

Would you like me to:
- [ ] Elaborate on any concept
- [ ] Generate variations of a concept
- [ ] Create a prototype roadmap for a concept
- [ ] Combine ideas into a hybrid concept
```

---

## Concept Generation Guidelines

### Match Constraints Precisely

**Timeline-Based Scoping:**
- **Weekend (2-3 days):**
  - ONE core mechanic only
  - Minimal art (shapes, colors)
  - No complex systems
  - Clear win/lose condition
  - Example: "Dodge falling objects while collecting gems"

- **Week (5-7 days):**
  - 2-3 mechanics
  - Simple pixel art or basic 3D
  - One progression system
  - 10-15 minutes of gameplay
  - Example: "Roguelike with 3 weapons and 5 enemy types"

- **Month (4 weeks):**
  - 4-6 mechanics
  - Multiple systems integration
  - Progression and unlocks
  - 30-60 minutes of content
  - Example: "Tower defense with building + resource management"

### Genre-Specific Patterns

**Action Games:**
- Core loop: Move → Shoot → Dodge → Survive
- Key: Responsive controls, satisfying feedback
- Prototyping focus: Feel and game juice

**Puzzle Games:**
- Core loop: Analyze → Plan → Execute → Solve
- Key: Clear rules, escalating complexity
- Prototyping focus: Puzzle generator and validation

**Roguelikes:**
- Core loop: Fight → Collect → Upgrade → Die → Retry
- Key: Run variety, meta-progression
- Prototyping focus: Procedural generation and balance

**Strategy Games:**
- Core loop: Gather → Build → Plan → Execute
- Key: Meaningful choices, visible consequences
- Prototyping focus: AI and resource balance

**Auto-battlers:**
- Core loop: Position → Watch → Adjust → Repeat
- Key: Strategic depth in preparation
- Prototyping focus: Combat simulation and balance

### Platform-Specific Considerations

**PC:**
- Can use keyboard/mouse for complex controls
- Players expect depth and precision
- Long play sessions acceptable

**Web:**
- Must load quickly (<5MB)
- Simple controls (mouse or arrow keys)
- Short play sessions (5-10 min)
- Shareability is a feature

**Mobile:**
- Touch controls only (swipes, taps)
- Portrait or landscape (choose one)
- Short play sessions (1-3 min)
- Minimize text (visual communication)

### Technical Complexity Ratings

**🟢 Low Complexity:**
- Built-in Godot nodes (CharacterBody2D, Area2D)
- Basic movement and collision
- Simple state machines
- No networking, no saving

**🟡 Medium Complexity:**
- Custom physics or pathfinding
- Procedural generation
- Save/load systems
- Multiple interconnected systems

**🔴 High Complexity:**
- Multiplayer/networking
- Advanced AI (behavior trees)
- Complex procedural generation
- 3D with custom shaders

---

## Concept Quality Criteria

### Every Concept Must Be:

1. **Achievable** - Realistic within stated timeline
2. **Focused** - Clear core loop, not trying to do everything
3. **Interesting** - Has a unique hook or twist
4. **Testable** - Can prototype core loop in 20% of timeline
5. **Expandable** - Can add features incrementally

### Red Flags to Avoid:

❌ **Feature Creep Concepts**
- "Open world RPG with crafting, building, and multiplayer"
- Too many systems for timeline

❌ **Vague Core Loops**
- "Explore and discover things"
- No clear minute-to-minute gameplay

❌ **Technical Overreach**
- "MMO" for a weekend project
- Requires tech beyond user's experience

❌ **Derivative Without Twist**
- "It's just like [popular game]"
- No unique selling point

❌ **Scope Mismatch**
- Tiny concept for month-long timeline
- Massive concept for weekend jam

---

## Example Interaction

**User:** "I want to make a game but don't know what"

**Skill:**
```
I'll help you generate game concepts! Let me understand your constraints:

1. **Development Timeline** - How much time do you have?
2. **Target Platform** - Where will this game run?
3. **Team Size** - Who's working on this?
4. **Engine/Tools** - What are you building with?
```

**User:** "Weekend jam, web platform, solo, Godot"

**Skill:**
```
Great! A weekend web game in Godot - super achievable. Now:

5. **Genre Preference** - Action? Puzzle? Roguelike? (Pick favorites)
6. **Core Mechanic Interest** - What sounds fun to implement?
7. **Visual Complexity** - Minimal shapes? Pixel art? Text?
```

**User:** "Action or roguelike, love movement mechanics, minimal art is fine"

**Skill:**
```
Perfect! Almost there:

8. **Experience Level** - How comfortable are you with game dev?
9. **Scope Preference** - Tiny and focused? Or pack in features?
10. **Inspiration** - Any favorite games or themes?
```

**User:** "Intermediate, prefer focused, love Vampire Survivors"

**Skill:** [Generates 5 concepts, all fitting constraints]

---

## Follow-Up Actions

After generating concepts, offer:

### Elaboration
If user says "tell me more about Concept 2":
- Expand on implementation details
- Suggest art/audio references
- Break down development phases
- Estimate feature complexity

### Variation
If user says "I like Concept 1 but [change]":
- Generate 3 variations with their modification
- Explain trade-offs of each variation
- Suggest hybrid approaches

### Prototype Roadmap
If user says "I want to build Concept 3":
- Invoke `vertical-slice-planner` skill
- Create day-by-day implementation plan
- Identify critical path features
- Suggest testing milestones

### Hybrid Concepts
If user says "combine Concept 1 and 4":
- Analyze which mechanics blend well
- Create unified core loop
- Assess combined scope
- Suggest integration approach

---

## Important Notes

- **Interactive is key**: ALWAYS ask questions before generating
- **Constraints matter**: A weekend concept ≠ month concept
- **Realistic scoping**: Better to under-promise and over-deliver
- **Unique hooks**: Every concept needs something interesting
- **Reference games**: Help user visualize with familiar examples
- **Prototype-first**: Concepts should be testable quickly

---

## Example Invocations

User: "Generate a game idea for me"
User: "I want to make a roguelike for a weekend"
User: "Game jam tomorrow, need concepts"
User: "Help me brainstorm game ideas"
User: "What game should I build in Godot?"

---

## Workflow Summary

1. **Ask Phase 1 questions** (timeline, platform, team, tools)
2. **Wait for user response**
3. **Ask Phase 2 questions** (genre, mechanics, art)
4. **Wait for user response**
5. **Ask Phase 3 questions** (experience, scope, inspiration)
6. **Wait for user response**
7. **Generate 3-5 concepts** matching all constraints
8. **Offer follow-up actions** (elaborate, vary, roadmap, hybrid)
9. **Create a markdown document capturing the game ideas**

**This iterative approach ensures concepts are tailored to the user's actual situation, not generic ideas.**
