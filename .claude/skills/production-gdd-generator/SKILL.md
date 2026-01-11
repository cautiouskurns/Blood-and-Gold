---
name: production-gdd-generator
description: Generate comprehensive Game Design Documents for full production games. Use this when transitioning from prototype to full game, or when planning a complete game from scratch.
domain: design
type: generator
version: 1.0.0
allowed-tools:
  - Read
  - Write
---

# Production GDD Generator Skill

This skill generates comprehensive Game Design Documents for full production games, covering all systems, content, progression, monetization, and long-term design vision.

---

## When to Use This Skill

Invoke this skill when the user:
- Says "create a full GDD" or "write a production game design document"
- Asks "how do I document the full game?"
- Transitioning from validated prototype to full production
- Planning a complete game from scratch (not just a prototype)
- Needs documentation for a team or publisher
- Says "expand prototype GDD to full game design"

---

## Core Principle

**Production GDDs are comprehensive blueprints**:
- ✅ Cover ALL game systems in detail
- ✅ Define complete content scope (not just MVP)
- ✅ Include progression, economy, monetization
- ✅ Document design vision and pillars
- ✅ Serve as reference for entire team
- ✅ Living document updated throughout production

---

## Difference from Prototype GDD

| Aspect | Prototype GDD | Production GDD |
|--------|---------------|----------------|
| **Purpose** | Test core questions | Document complete game |
| **Scope** | Minimum viable features | All planned features |
| **Timeline** | Days to weeks | Months to years |
| **Detail Level** | High-level mechanics | Detailed specifications |
| **Audience** | Solo dev or small team | Full team + stakeholders |
| **Systems** | 1-3 core systems | All game systems |
| **Content** | Placeholder/minimal | Complete content plan |
| **Polish** | Not required | Quality bar defined |
| **Monetization** | Not covered | Fully documented |
| **Meta-progression** | Often excluded | Fully designed |

---

## Production GDD Structure

```markdown
# [GAME TITLE] - Game Design Document

**Version:** [X.Y.Z]
**Status:** [In Production / Pre-Production / Planning]
**Lead Designer:** [Name]
**Team Size:** [Number]
**Target Platforms:** [Platforms]
**Target Release:** [Quarter Year]
**Last Updated:** [Date]

---

## EXECUTIVE SUMMARY

### Vision Statement
[1 paragraph: What is this game and why does it exist?]

### Elevator Pitch
[2-3 sentences: Genre + core mechanic + unique hook]

### Target Audience
[Who is this for? Demographics, psychographics, player motivations]

### Unique Selling Points (USPs)
1. [USP 1]: [Why this matters to players]
2. [USP 2]: [Why this matters to players]
3. [USP 3]: [Why this matters to players]

### Core Pillars
**[Pillar 1 Name]**
[3-5 sentences explaining pillar and how it manifests in game]

**[Pillar 2 Name]**
[Same format]

**[Pillar 3 Name]**
[Same format]

---

## 1. CORE GAMEPLAY

### Core Loop
[Detailed breakdown of minute-to-minute, session-to-session, and long-term loops]

**Minute-to-Minute Loop:**
```
1. [Player action]
2. [System response]
3. [Feedback]
4. [Decision point]
→ Repeat
```

**Session-to-Session Loop:**
```
1. [Start session with goal]
2. [Make progress on goal]
3. [Unlock/earn something]
4. [Plan next session]
→ Return tomorrow
```

**Long-Term Loop:**
```
1. [Weeks 1-2: Early game experience]
2. [Weeks 3-4: Mid-game experience]
3. [Months 2+: End-game experience]
→ Mastery and retention
```

### Primary Mechanics
[Detailed documentation of each core mechanic]

#### [Mechanic 1 Name]
**Description:** [What is it?]
**Player Input:** [How player interacts]
**System Response:** [What game does]
**Feedback:** [Visual/audio/haptic feedback]
**Depth:** [How mechanic creates mastery]
**Example:** [Concrete example of mechanic in action]

#### [Mechanic 2 Name]
[Same format]

### Secondary Mechanics
[Brief documentation of supporting mechanics]

---

## 2. GAME SYSTEMS

[Document each major system in detail]

### [System 1 Name] (e.g., Combat System)

**Purpose:** [Why this system exists, what player fantasy it fulfills]

**Core Components:**
- [Component 1]: [Description]
- [Component 2]: [Description]

**Player Interactions:**
- [How player uses this system]

**Progression:**
- [How this system evolves over game]

**Balance Levers:**
- [Variable 1]: [How it affects balance]
- [Variable 2]: [How it affects balance]

**Edge Cases:**
- [Edge case 1]: [How system handles it]

**Visual Design:**
- [UI mockups, screen layouts, feedback design]

**Technical Requirements:**
- [Special tech needed, performance considerations]

### [System 2 Name] (e.g., Progression System)
[Same format for all major systems]

---

## 3. PROGRESSION & ECONOMY

### Player Progression

**Level Curve:**
- Total levels: [Number]
- XP curve: [Formula or table]
- Level-up rewards: [What players get each level]

**Skill Tree / Upgrade Paths:**
[Detailed breakdown of upgrade trees, branching paths, synergies]

**Unlock Sequence:**
[Order in which content/features unlock, with justification]

### Economy Design

**Currencies:**
1. **[Currency 1 Name]** (e.g., Gold)
   - Earn rate: [Amount per hour at different progression points]
   - Sinks: [What players spend on]
   - Sources: [How players earn]
   - Soft cap: [Maximum useful amount]

2. **[Currency 2 Name]** (e.g., Premium Gems)
   - [Same format]

**Resource Flow:**
[Diagram or description of how resources flow through economy]

**Monetization Integration:**
[How F2P/premium currency connects to progression]

---

## 4. CONTENT SCOPE

### Content Breakdown

**Total Content Volume:**
- Levels/Maps: [Number]
- Enemy Types: [Number]
- Player Abilities/Weapons: [Number]
- Boss Fights: [Number]
- Narrative Beats: [Number]
- Cinematics: [Number]

### Content Production Plan

#### [Content Type 1] (e.g., Levels)
**Total:** [Number]
**Themes:** [List themes/biomes]
**Production Time:** [Hours per asset]
**Dependencies:** [What's needed before starting]
**Quality Bar:** [Example reference or description]

#### [Content Type 2] (e.g., Enemies)
[Same format]

### Content Roadmap
- **Months 1-3:** [What content is created]
- **Months 4-6:** [What content is created]
- **Months 7-9:** [What content is created]
- **Launch Content:** [What ships at 1.0]
- **Post-Launch Content:** [What comes in updates]

---

## 5. PLAYER EXPERIENCE

### First-Time User Experience (FTUE)

**Onboarding Goals:**
1. [Goal 1]: [Teach X in Y time]
2. [Goal 2]: [Teach X in Y time]

**Tutorial Flow:**
- **Step 1:** [What player does, what they learn]
- **Step 2:** [Same]
- **Step 3:** [Same]

**Pacing:**
- First 5 minutes: [Experience]
- First 30 minutes: [Experience]
- First 2 hours: [Experience]

### Difficulty Curve

**Difficulty Philosophy:** [How game challenges players]

**Progression:**
- Early Game (Hours 0-2): [Difficulty level, teaching vs challenging]
- Mid Game (Hours 2-10): [Difficulty level]
- End Game (Hours 10+): [Difficulty level]

**Difficulty Options:**
- [Mode 1]: [Description, target audience]
- [Mode 2]: [Description]

### Session Design

**Session Length:** [Target minutes per session]
**Session Goals:** [What player should accomplish per session]
**Stopping Points:** [Natural places to pause]
**Return Hooks:** [Why player comes back tomorrow]

---

## 6. NARRATIVE & WORLD

### Story Overview
[High-level narrative arc]

### World Design
**Setting:** [Where/when game takes place]
**Factions:** [Major groups, conflicts]
**Lore:** [Background worldbuilding]

### Characters
[Key characters, motivations, arcs]

### Narrative Integration
[How story integrates with gameplay, not just cutscenes]

---

## 7. ART & AUDIO DIRECTION

### Visual Style
**Art Direction:** [Description, reference images]
**Color Palette:** [Primary colors, mood]
**UI/UX Style:** [Interface design philosophy]

### Audio Direction
**Music Style:** [Genre, mood, reference tracks]
**SFX Approach:** [Realistic vs stylized, reference games]
**Voice Acting:** [Scope, style, languages]

---

## 8. TECHNICAL DESIGN

### Technical Requirements
**Engine:** [Engine and version]
**Target Platforms:** [Platforms with technical constraints]
**Performance Targets:** [FPS, load times, memory]

### Architecture
**Core Systems:** [High-level technical architecture]
**Networking:** [If multiplayer, network architecture]
**Save System:** [What's saved, how, cloud sync?]

### Tools & Pipeline
**Required Tools:** [What team needs to build/edit content]
**Asset Pipeline:** [How assets go from creation to game]

---

## 9. MONETIZATION & LIVE OPS

### Monetization Model
**Primary Model:** [Premium / F2P / Subscription / Ads]
**Revenue Streams:** [How game makes money]

**IAP Structure** (if applicable):
- [IAP 1]: [Price, contents, value proposition]
- [IAP 2]: [Same]

**Battle Pass** (if applicable):
[Structure, seasons, rewards]

### Live Operations
**Update Cadence:** [Frequency of updates]
**Content Drops:** [What new content, how often]
**Events:** [Seasonal events, limited-time modes]
**Community Management:** [How you engage players]

---

## 10. PRODUCTION PLAN

### Development Phases

**Pre-Production** (Months 1-2):
- [Milestone 1]
- [Milestone 2]

**Vertical Slice** (Months 3-4):
- [Features included in vertical slice]

**Production** (Months 5-12):
- [Major milestones with dates]

**Alpha** (Month X):
- [Feature complete, internal testing]

**Beta** (Month Y):
- [Content complete, external testing]

**Release** (Month Z):
- [Launch]

### Team Structure
**Required Roles:**
- [Role 1]: [Responsibilities, headcount]
- [Role 2]: [Responsibilities, headcount]

### Risk Assessment
**Major Risks:**
1. [Risk]: [Likelihood, impact, mitigation]
2. [Risk]: [Same]

---

## 11. SUCCESS METRICS

### Key Performance Indicators (KPIs)

**Engagement Metrics:**
- DAU/MAU target: [Number]
- Session length target: [Minutes]
- Retention D1/D7/D30: [Percentages]

**Monetization Metrics:**
- ARPU target: [Amount]
- Conversion rate: [Percentage]
- LTV target: [Amount]

**Quality Metrics:**
- Metacritic target: [Score]
- Player satisfaction: [Survey score]
- Bug rate: [Bugs per 1000 players]

### Post-Launch Support Plan
**Year 1 Roadmap:** [Major updates planned]
**Long-Term Vision:** [Where game goes in years 2-3]

---

## APPENDICES

### Appendix A: Detailed Feature Specifications
[Link to individual feature spec documents]

### Appendix B: Balance Spreadsheets
[Link to external balance documents]

### Appendix C: Narrative Bible
[Link to narrative documentation]

### Appendix D: Art Bible
[Link to art style guide]

### Appendix E: Technical Design Documents
[Link to technical specs]

---

**END OF GAME DESIGN DOCUMENT**

This document is a living reference. Update regularly as design evolves.
```

---

## Interactive Questioning Workflow

### Phase 1: Vision & Scope
Ask about:
- Game vision and design pillars
- Target audience and platforms
- Production timeline and team size
- Monetization model
- Competitive landscape

### Phase 2: Core Systems
Ask about:
- All major game systems (combat, progression, economy)
- How systems interact
- Depth and mastery elements
- Balance philosophy

### Phase 3: Content & Progression
Ask about:
- Total content scope (levels, enemies, abilities)
- Progression curve (hours to complete)
- Difficulty curve
- Content production plan

### Phase 4: Production & Business
Ask about:
- Development phases and milestones
- Team structure and roles
- Monetization integration
- Live ops plans (if applicable)
- Success metrics

---

## Output File Naming

Save to: `docs/[game-name]-production-gdd.md`

**Versioning:**
- Use semantic versioning (e.g., v1.0.0, v1.1.0)
- Update version in document header
- Keep changelog of major revisions

---

## Important Guidelines

### Comprehensive but Focused
- Cover all systems, but prioritize detail on core systems
- Link to external docs for deep dives (balance sheets, narrative bible)
- Keep main GDD readable (not a 200-page document)

### Living Document
- Update as design evolves
- Version control for major changes
- Track decisions and rationale

### Team Communication
- Write for the whole team (designers, programmers, artists)
- Use clear language, avoid ambiguity
- Include visual mockups where helpful

### Production-Ready
- Include enough detail for implementation
- Define success metrics and KPIs
- Document risks and mitigation

---

## Example Invocations

User: "Create a full production GDD for my roguelike"
User: "Expand prototype GDD to production GDD"
User: "Write a complete game design document"
User: "I need a GDD for the full game, not just prototype"

---

## Workflow Summary

1. Determine if user has prototype GDD (if yes, read it)
2. Ask Phase 1 questions (vision, scope, audience)
3. Ask Phase 2 questions (core systems in detail)
4. Ask Phase 3 questions (content scope and progression)
5. Ask Phase 4 questions (production plan and business)
6. Generate comprehensive production GDD
7. Save to `docs/[game-name]-production-gdd.md`
8. Remind user this is a living document to update regularly

---

This skill creates the blueprint for full game production, going far beyond prototype testing to document every aspect of the complete game vision.
