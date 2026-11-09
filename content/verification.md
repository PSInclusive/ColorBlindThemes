---
title: "Verification"
lane: "09"
laneName: "Verification"
slug: "verification"
weight: 9
---

Each theme's signal colors (success, error, warning, diff add/delete, syntax roles) are simulated
under deuteranopia, protanopia and tritanopia (Machado, Oliveira & Fernandes 2009, 100% severity).
The score is the smallest CIEDE2000 (ΔE00) distance between any two simulated colors, taken from
the worst of the three deficiencies. Higher is better.

| Verdict | Score |
|---|---|
| **STRONG** | 8 or more |
| **OK** | 3 or more |
| **WEAK** | under 3 |

Per-theme scores are in the type pages and [All themes](../all-themes/). Reproduce them with
`pwsh scripts/Test-ColorblindThemes.ps1`.

The score measures hue and lightness collapse only. It does not model icons, font weight or other
non-color cues.
