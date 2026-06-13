# OpenSCAD 3D Modeling Agent Instructions

## Core Responsibilities

- Create parametric 3D models using OpenSCAD (`.scad`).
- Use variables for all dimensions to allow easy customization.
- Prioritize CSG (union, difference, intersection) operations.

## Modeling Guidelines

- **Parametric First:** Define variables (e.g., `x-start`, `y-start`, `z-start`, `width`, `height`, `wall_thickness`) at the top of the script.
- **Library Usage:** Leverage `BOSL2` for complex geometry when available.
- **Performance:** Use reasonable `$fn` (fragment number) values during development, and higher values for final exports (e.g., `$fn = 60;`).
- **Structure:** Break complex designs into modules (`module my_part() { ... }`).

## Workflow & Verification

1. **Generate/Edit:** Modify the `.scad` file.
2. **Render Preview:** Use `openscad -o preview.png model.scad` to generate a visual check.
3. **Validate:** Check for non-manifold geometry.
4. **Export STL:** Create STL files for 3D printing only after validation.

## Standardized Parameters (Recommended)

- `draft_mode = true;` // Fast render
- `tolerance = 0.2;` // Print tolerance
