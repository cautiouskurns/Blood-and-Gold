---
name: feature-spec-generator
description: Generate detailed feature specifications based on the project's feature spec template, using the prototype GDD and roadmap for context. Use this when the user wants to create a feature spec, document a new feature idea, or plan implementation for a game feature.
domain: project
type: generator
version: 1.3.0
allowed-tools:
  - Write
  - Read
  - Glob
---

# Feature Spec Generator Skill

This skill generates comprehensive feature specifications using the project's standardized template, with context from the prototype GDD and development roadmap to ensure alignment with game vision, design pillars, and project priorities.

## When to Use This Skill

Invoke this skill when the user:
- Asks to "create a feature spec" or "generate a feature spec"
- Wants to document a new feature idea
- Says "write up [feature name]"
- Needs planning documentation for a game feature
- Asks to formalize a feature idea

## How to Use This Skill

**IMPORTANT: Always announce at the start that you are using the Feature Spec Generator skill.**

Example: "I'm using the **Feature Spec Generator** skill to create a comprehensive feature specification for [feature-name]."

### Workflow

1. **Announce skill invocation**: Explicitly state that you are using the Feature Spec Generator skill
2. **Understand the feature idea**: Ask clarifying questions if the feature idea is vague
3. **Gather context documents**: Search for and read the following for context:
   - **Prototype GDD**: Look for GDD files (e.g., `*-prototype-gdd.md`, `game-design-document.md`) to understand overall game vision, core mechanics, and design pillars
   - **Roadmap**: Look for roadmap files (e.g., `*-roadmap.md`, `development-roadmap.md`) to understand feature priorities, phases, and dependencies
   - **Game Design Bible**: Look for design bible files if they exist for high-level design principles
   - Use Glob to search: `**/*gdd*.md`, `**/*roadmap*.md`, `**/*design-bible*.md`
4. **Read the template**: Load the template from `docs/design templates/feature-spec-template.md`
5. **Generate the spec**: Fill out ALL sections of the template with thoughtful, specific content informed by the context documents
6. **Save the file**: Write to `docs/features/[feature-name].md` using kebab-case naming
7. **Confirm completion**: Announce that the feature spec has been generated and saved, providing the file location

## Template Sections to Complete

You must fill out every section comprehensively:

### Header
- **Feature Name**: Clear, descriptive name
- **Status**: 🔴 Planned (default for new specs)
- **Priority**: Based on project context (🔥 Critical | ⬆️ High | ➡️ Medium | ⬇️ Low)
- **Estimated Time**: Realistic estimate in hours/days
- **Dependencies**: List other features needed first, or "None"
- **Assigned To**: Usually "AI assistant" or leave as template

### Purpose
- **Why does this feature exist?**: 1-2 sentences on the problem it solves
- **What does it enable?**: What players can do that they couldn't before
- **Success criteria**: Observable, testable success measures

### How It Works
- **Overview**: 2-3 paragraphs explaining the feature behavior in detail
- **User Flow**: Step-by-step interaction flow
- **Rules & Constraints**: Specific rules governing the feature
- **Edge Cases**: Unusual scenarios and error conditions

### User Interaction
- **Controls**: Specific input methods (keyboard, mouse, etc.)
- **Visual Feedback**: What the player sees during interaction
- **Audio Feedback**: Sound effects or music (if applicable)

### Visual Design
- **Layout**: Description of UI layout
- **Components**: UI elements and their purposes
- **Visual Style**: Colors, fonts, animations
- **States**: Appearance in different states (Default, Hover, Active, Disabled, Error)

### Technical Implementation
- **Scene Structure**: Godot scene node hierarchy
- **Script Responsibilities**: Which scripts do what
- **Integration Points**: How it connects to other systems, signals, state modifications
- **Configuration**: JSON files, tunable constants

### Acceptance Criteria
- 5+ specific, testable criteria for feature completion

### Testing Checklist
- **Functional Tests**: Core functionality tests
- **Edge Case Tests**: Boundary condition tests
- **Integration Tests**: Compatibility with other features
- **Polish Tests**: Animation, sound, visual feedback, performance

### Implementation Notes
- Important details about approach
- Gotchas to watch out for
- Alternative approaches considered

## Important Guidelines

1. **Use Context Documents**: Always read the prototype GDD and roadmap first to ensure the feature spec aligns with the overall game vision, design pillars, and project roadmap
2. **Be Specific**: Replace ALL placeholder text with concrete details
3. **Match Project Context**: Reference existing systems in the codebase and ensure feature fits within the game's scope and architecture
4. **Align with Design Pillars**: Ensure the feature supports the game's core design pillars and mechanics as defined in the GDD
5. **Check Roadmap Dependencies**: Reference the roadmap to understand where this feature fits in the development timeline and what dependencies exist
6. **GDScript/Godot Focus**: Use Godot-specific terminology (nodes, scenes, signals, etc.)
7. **Prototyping Scope**: Keep estimates realistic for the project timeline (weekend prototype, vertical slice, etc.)
8. **Test-Driven**: Ensure acceptance criteria are clear and testable

## Example Feature Ideas

- Weapon rule programming interface
- Wave spawning system
- Level-up upgrade screen
- Damage number feedback system
- Enemy AI behavior patterns
- Screen shake and visual effects
- Tutorial tooltips
- Death screen with statistics

## Output

Always save the generated feature spec to:
```
docs/features/[ID]-[feature-name].md
```

Use kebab-case for the filename (e.g., `1.1-weapon-rule-system.md`, `1.2-level-up-screen.md`).

After generating, confirm the file location and ask if the user wants any sections expanded or modified.