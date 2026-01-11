---
name: scene-optimizer
description: Analyze Godot scene files (.tscn) for structural issues, performance problems, and optimization opportunities. Use this when the user wants to optimize a scene, check scene structure, or troubleshoot scene-related issues.
domain: godot
type: optimizer
version: 1.1.0
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Scene Optimizer Skill

This skill analyzes Godot scene files (.tscn) to identify structural issues, performance bottlenecks, and optimization opportunities specific to Godot 4.x projects.

## When to Use This Skill

Invoke this skill when the user:
- Asks to "optimize scene" or "check scene structure"
- Says "analyze [scene_name].tscn"
- Wants to troubleshoot performance issues
- Asks "why is my scene slow?" or "is my scene structure good?"
- Requests scene quality review
- Says "check my scenes"

## Analysis Categories

### 1. Node Hierarchy Issues

**Check for:**
- **Excessive depth**: More than 5-6 levels deep (hard to maintain)
- **Flat hierarchies**: Too many siblings at root level (poor organization)
- **Singleton children**: Nodes with only one child (unnecessary nesting)
- **Naming conventions**: Unclear or generic names ("Node2D", "Control", etc.)

**Best Practices:**
- Keep hierarchies 3-5 levels deep when possible
- Group related nodes under organizational parents
- Use descriptive, PascalCase names for custom nodes
- Remove unnecessary wrapper nodes

### 2. Performance Red Flags

**Check for:**
- **Too many nodes**: More than 100-150 nodes in a single scene (consider splitting)
- **Heavy processing nodes**: Multiple AnimatedSprite2D, Particle2D, or Light2D nodes
- **Inefficient collision**: Too many CollisionShape2D nodes or complex polygon shapes
- **Duplicate resources**: Same texture/material loaded multiple times
- **Missing optimization flags**: CanvasItems without proper visibility settings

**Best Practices:**
- Split large scenes into subscenes
- Use object pooling for repeated nodes (bullets, enemies)
- Simplify collision shapes (use rectangles/circles over polygons)
- Share resources via preloading
- Use visibility notifiers for off-screen culling

### 3. Signal and Connection Issues

**Check for:**
- **Broken connections**: Signals connected to non-existent nodes
- **Missing critical signals**: Input nodes without connected signals
- **Callback typos**: Method names that don't follow `_on_NodeName_signal_name` convention
- **Cross-scene coupling**: Connections to nodes outside the scene tree

**Best Practices:**
- Verify all signal connections are valid
- Use descriptive callback names
- Connect signals in code for dynamic nodes
- Avoid hard-coded node paths in connections

### 4. Resource Management

**Check for:**
- **External resources**: Missing or broken external references
- **Embedded resources**: Large resources embedded directly (should be external)
- **Duplicate materials/textures**: Same resource defined multiple times
- **Missing compression**: Textures not using appropriate compression

**Best Practices:**
- Extract shared resources to separate .tres files
- Use resource preloading for common assets
- Compress textures appropriately (VRAM vs. Lossless)
- Remove unused resources

### 5. Script Attachment Issues

**Check for:**
- **Missing scripts**: Nodes with broken script references
- **Duplicate logic**: Multiple nodes with identical scripts (consider inheritance)
- **Script on wrong node type**: Scripts attached to inappropriate node types
- **Export variables**: Nodes missing exported variables that should be configured

**Best Practices:**
- Verify all script paths are valid
- Use script inheritance for shared behavior
- Attach scripts to semantically appropriate nodes
- Use `@export` for scene-configurable properties

### 6. UI-Specific Checks (for Control nodes)

**Check for:**
- **Layout containers**: Using Control instead of appropriate containers (VBoxContainer, etc.)
- **Anchors not set**: Controls with default anchors that should be responsive
- **Missing themes**: Inconsistent styling across UI elements
- **Z-index conflicts**: Overlapping controls with unintended draw order

**Best Practices:**
- Use layout containers over manual positioning
- Set anchors for responsive layouts
- Apply consistent themes
- Organize UI layers properly

### 7. Physics-Specific Checks

**Check for:**
- **Physics in wrong process**: Physics code in `_process` instead of `_physics_process`
- **Missing collision layers/masks**: Default layers/masks (should be explicit)
- **Overlapping collision shapes**: Multiple shapes when one would suffice
- **Incorrect node types**: Using RigidBody2D when CharacterBody2D is appropriate

**Best Practices:**
- Use `_physics_process` for all physics operations
- Set explicit collision layers and masks
- Use appropriate physics body types
- Simplify collision shapes

## How to Perform Analysis

1. **Identify target scenes**: Ask user which scene(s) to analyze, or scan project for .tscn files
2. **Read scene files**: Use Read tool to load .tscn content (they're text-based)
3. **Parse structure**: Analyze node hierarchy, connections, resources
4. **Check against criteria**: Run through all 7 analysis categories
5. **Generate report**: Provide prioritized findings with specific line references
6. **Suggest improvements**: Offer concrete refactoring steps

## Output Format

Provide analysis in this structure:

```markdown
# Scene Optimization Report: [scene_name].tscn

## Summary
- Total nodes: X
- Max depth: X levels
- Issues found: X
- Severity: 🔴 Critical | 🟡 Warning | 🟢 Good

---

## Critical Issues (Must Fix)
1. **[Issue name]** - [Location]
   - Problem: [Description]
   - Impact: [Performance/maintainability impact]
   - Fix: [Specific steps to resolve]

## Warnings (Should Fix)
[Same format]

## Suggestions (Nice to Have)
[Same format]

---

## Scene Statistics
- Node count: X
- Max hierarchy depth: X
- Signal connections: X
- External resources: X
- Script attachments: X

## Overall Assessment
[1-2 paragraph summary of scene quality and recommended next steps]
```

## Scene File Format Reference

Godot .tscn files are text-based with this structure:
```
[gd_scene load_steps=X format=3]
[ext_resource ...]
[sub_resource ...]

[node name="Root" type="NodeType"]
[node name="Child" type="NodeType" parent="Root"]
[connection signal="signal_name" from="NodeA" to="NodeB" method="callback"]
```

Key sections to parse:
- `[ext_resource]`: External dependencies
- `[sub_resource]`: Embedded resources
- `[node ...]`: Node definitions with hierarchy
- `[connection ...]`: Signal connections

## Important Notes

- **Be specific**: Reference exact node names and line numbers
- **Context-aware**: Consider the project type (prototype vs. production)
- **Prioritize**: Critical issues before nice-to-haves
- **Actionable**: Every suggestion should have clear steps
- **Godot 4.x**: Use Godot 4.x terminology and best practices

## Example Invocations

User: "Check my Main.tscn scene"
User: "Optimize all enemy scenes"
User: "Why is my UI scene performing poorly?"
User: "Analyze scenes for performance issues"
