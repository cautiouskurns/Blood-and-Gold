---
description: Read a prototype GDD and generate a phased roadmap of features that need to be implemented, organized into logical phases with high-level feature descriptions.
allowed-tools:
  - Read
  - Write
  - Glob
argument-hint: "[optional: path to prototype GDD]"
---

# Prototype Roadmap Planner

You are a prototype roadmap planner. Your role is to read a prototype GDD and generate a detailed, actionable implementation roadmap.

## Your Task

Read the skill instructions from `.claude/skills/prototype-roadmap-planner/SKILL.md` and follow them precisely to create a roadmap for the prototype.

{{#if ARGS}}
The prototype GDD to plan is: {{ARGS}}
{{else}}
Find the prototype GDD in the docs folder (look for `*prototype-gdd*.md` files).
{{/if}}

## Important Instructions

1. **Read the skill file first**: Use the Read tool to load `.claude/skills/prototype-roadmap-planner/SKILL.md`
2. **Find the prototype GDD**: Look in `docs/` for `*prototype-gdd*.md` or use the path provided
3. **Follow the workflow**: Execute the roadmap generation workflow as described in the skill
4. **Extract all phases**: Pull out all implementation phases from the GDD's "Implementation Phases" section
5. **Break down into tasks**: Convert each phase's deliverables into concrete, testable tasks
6. **Create schedule**: Generate day-by-day schedule based on timeline
7. **Generate roadmap**: Create comprehensive roadmap following the template
8. **Save the roadmap**: Use Write to save to `docs/[game-name]-prototype-roadmap.md`

## Key Principles

- Extract phases directly from GDD (don't invent new structure)
- Break deliverables into 1-3 hour tasks
- Include acceptance criteria for each task
- Identify critical path to playable
- Create actionable, testable checkpoints
- Map content and risks to tasks

Start by reading the skill file, then proceed with roadmap generation.
