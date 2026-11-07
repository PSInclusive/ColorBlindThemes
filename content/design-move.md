---
title: "The one design move"
lane: "01b"
laneName: "Background"
slug: "design-move"
weight: 2
---

Every explicitly CVD-designed UI theme found in this research uses one of two strategies:

1. **Collapse the red↔green axis onto orange↔blue** (GitHub colorblind themes, hakarune terminal
   collection, Pierre, Gentle). "Success" green becomes blue; "danger" red becomes orange.
2. **Anchor hues on a scientifically validated colorblind-safe palette** (datum → Okabe–Ito;
   vim-dichromatic and Blinds → Paul Tol SRON; givensuman → Tol discrete rainbow).

Both often combine with a **luminance backup channel**: confused hues are also separated by
lightness, so the distinction survives even when hue perception collapses.

---
