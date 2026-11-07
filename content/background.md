---
title: "Why special themes exist"
lane: "01a"
laneName: "Background"
slug: "background"
weight: 1
---

## What color blindness actually is

Color vision deficiency (CVD) is not grayscale vision. Almost no one with "color blindness" sees in
black and white. What actually happens: the eye has three types of cone cell, each tuned to a band of
the spectrum (long = red, medium = green, short = blue). In CVD, one cone type is either missing
entirely or its sensitivity is shifted toward a neighbor. The result is not "no color" — it is that
certain pairs of hues that look obviously different to most people collapse into the same perceived
color for a CVD viewer.

Which pairs collapse depends on which cone is affected:

| Type | Mechanism | What collapses | Prevalence |
|---|---|---|---|
| Deuteranomaly / deuteranopia | M ("green") cone shifted / absent | red ↔ green, brown ↔ olive | most common; part of ~8% of men |
| Protanomaly / protanopia | L ("red") cone shifted / absent; red appears **darker** (dark red ≈ black) | red ↔ green, and red looks dim | ~1–2% of men |
| Tritanopia | S ("blue") cone absent | blue ↔ green, yellow ↔ pink, purple ↔ red | ~0.001–0.01%, both sexes equally |
| Monochromacy | no working color vision at all | everything | very rare |

Red–green CVD is carried on the X chromosome, which is why it concentrates in men: roughly
**1 in 12 men and 1 in 200 women**
([Colour Blind Awareness UK](https://www.colourblindawareness.org/colour-blindness/);
[NEI type taxonomy](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/color-blindness/types-color-vision-deficiency)).
Scale that to real audiences (per [Okabe & Ito](https://jfly.uni-koeln.de/color/)): a 250-person
audience contains at least 10 CVD viewers; a product with 10,000 users reaches about 400; three
random white male reviewers carry a 22% chance that at least one is colorblind.

## Why ordinary themes fail

Most color themes pick colors for how they look to full color vision. Red means error, green means
success, a diff's additions are green and deletions red. For a deuteranope those two colors sit on
the collapsed axis and become nearly the same muddy tone — so the one signal the UI most needs to
communicate is the one that disappears. This is not a contrast problem (the colors can be equally
bright and still indistinguishable), so "high contrast" themes do not fix it.

## Why the standard doesn't fix it either

**WCAG does not require CVD-safe palettes.** SC 1.4.1 (Use of Color) only bans color as the *sole*
information carrier, and a ≥3:1 luminance difference counts as a non-color distinction — a page can
pass AA while pairing red with green everywhere
([Understanding SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)).
The themes below exist to fill exactly that gap.
