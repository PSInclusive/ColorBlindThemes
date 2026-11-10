---
title: "What is CVD?"
lane: "01"
laneName: "Background"
slug: "what-is-cvd"
weight: 1
---

Let's get one myth out of the way first: color blindness is not grayscale vision.

Almost no one with "color blindness" sees in black and white. What actually happens is weirder, and it matters a lot for how we design themes.

## So what is color blindness, actually?

Color vision deficiency (CVD) is the real name for it. Your eye has three types of cone cell, each tuned to a band of the spectrum: long (red), medium (green), and short (blue).

In CVD, one cone type is either missing entirely or its sensitivity has shifted toward a neighbor. The result is not "no color". Instead, certain pairs of hues that look obviously different to most people collapse into the same perceived color.

Which pairs collapse depends on which cone is affected:

| Type | Mechanism | What collapses | Prevalence |
|---|---|---|---|
| Deuteranomaly / deuteranopia | M ("green") cone shifted / absent | red ↔ green, brown ↔ olive | most common; part of ~8% of men |
| Protanomaly / protanopia | L ("red") cone shifted / absent; red appears **darker** (dark red ≈ black) | red ↔ green, and red looks dim | ~1–2% of men |
| Tritanopia | S ("blue") cone absent | blue ↔ green, yellow ↔ pink, purple ↔ red | ~0.001–0.01%, both sexes equally |
| Monochromacy | no working color vision at all | everything | very rare |

"-anomaly" means the cone is shifted. "-anopia" means it's absent. The scores on this site simulate the "-anopia" case, which is the worst case for each type.

## It's more people than you think

Red–green CVD is carried on the X chromosome, which is why it concentrates in men: roughly **1 in 12 men and 1 in 200 women** ([Colour Blind Awareness UK](https://www.colourblindawareness.org/colour-blindness/); [NEI type taxonomy](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/color-blindness/types-color-vision-deficiency)).

Scale that to real audiences (per [Okabe & Ito](https://jfly.uni-koeln.de/color/)). A 250-person audience contains at least 10 CVD viewers. A product with 10,000 users reaches about 400. And three random white male reviewers carry a 22% chance that at least one is colorblind.

Look around your next meeting. Statistically, someone is squinting at your pie chart. 😅

## How this site measures it

Each theme's signal colors get simulated under deuteranopia, protanopia, and tritanopia. The **Deut**, **Prot**, and **Trit** columns in the tables show the result for each type. The **Score** column is the lowest of the three. Higher is better. [Verification](../verification/) has the method and the STRONG / OK / WEAK cutoffs.

Use the type that matches you. A theme built for deuteranopia can score great in Deut and poorly in Trit. The "by" buttons above each table filter and sort by one type, so you can ignore the other two.

## Why your favorite theme probably fails

Most color themes pick colors for how they look to full color vision. Red means error. Green means success. A diff's additions are green and its deletions are red.

For a deuteranope, those two colors sit on the collapsed axis and turn into nearly the same muddy tone. The one signal the UI most needs to communicate is the one that disappears.

And no, this is not a contrast problem. The colors can be equally bright and still indistinguishable, so "high contrast" themes do not fix it.

## WCAG says you're fine. You're not fine.

**WCAG does not require CVD-safe palettes.** SC 1.4.1 (Use of Color) says:

> Color is not used as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element.

Translation: don't use color *alone*. But a ≥3:1 luminance difference counts as a non-color distinction, so a page can pass AA while pairing red with green everywhere ([Understanding SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)).

The themes in the tables exist to fill exactly that gap.

## How CVD-safe themes fix it

Every explicitly CVD-designed UI theme I found uses one of two strategies:

1. **Collapse the red↔green axis onto orange↔blue** (GitHub colorblind themes, hakarune terminal collection, Pierre, Gentle). "Success" green becomes blue. "Danger" red becomes orange.
2. **Anchor hues on a scientifically validated colorblind-safe palette** (datum → Okabe–Ito; vim-dichromatic and Blinds → Paul Tol SRON; givensuman → Tol discrete rainbow).

Both often come with a **luminance backup channel**: confused hues also get separated by lightness, so the distinction survives even when hue perception collapses. Belt and suspenders. 😎
