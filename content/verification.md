---
title: "Verification"
lane: "10"
laneName: "Verification"
slug: "verification"
weight: 10
---

Every score on this site is computed, not vibes.

Each theme's signal colors (success, error, warning, diff add/delete, syntax roles) get simulated under deuteranopia, protanopia, and tritanopia (Machado, Oliveira & Fernandes 2009, 100% severity).

The score for each deficiency is the smallest CIEDE2000 (ΔE00) distance between any two simulated colors, aka the standard math for "how different do these two colors look?" The tables show them as the **Deut**, **Prot**, and **Trit** columns. **Score** is the lowest of the three. Higher is better. [What is CVD?](../what-is-cvd/) explains the three types.

| Verdict | Score |
|---|---|
| **STRONG** | 8 or more |
| **OK** | 3 or more |
| **WEAK** | under 3 |

Per-theme scores are in the type pages and [All themes](../all-themes/). Want to check my math? Run `pwsh scripts/Test-ColorblindThemes.ps1`.

## What the score can't see

Heads up: the score measures hue and lightness collapse only. It does not model icons, font weight, or other non-color cues. A low score doesn't mean a theme is unusable, and a high score doesn't make a bad UI good. ¯\_(ツ)_/¯
