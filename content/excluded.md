---
title: "Not included, and why"
lane: "09"
laneName: "Excluded"
slug: "excluded"
weight: 9
---

| Excluded | Reason |
|---|---|
| VS Code built-in High Contrast, GitHub High Contrast | marketed for **low vision**; red/green hues remain red/green — no CVD hue remapping |
| Windows Terminal built-ins | verified `defaults.json`: no CVD scheme ships by default (but a Microsoft-authored `deuteranopia.itermcolors` sample exists in the repo — see Terminal section) |
| Trello "color blind mode" | label *patterns*, not a published color theme |
| Slack "accessible theme" | no official palette hexes published |
| macOS/iOS/Windows color filters | CVD *correction* filters, not themes |
| Terracotta, Gotthard (VS Code) | "WCAG"/"colorblind" marketing without explicit CVD design or testing evidence |
| Vishwakarma Theme | advertises colorblind variants; source palette unverifiable |
| Notepad++ | verified across community repos + forum: no CVD-designed theme exists |
| Emacs beyond modus & ef | MELPA/ELPA sweep: only modus-themes and ef-themes are CVD-named/optimized; Doric etc. are contrast-led |
| Teams | no user theme format with published palettes; only an unpublished high-contrast mode |
| Oxocarbon | CVD-*motivated* but verified by WCAG contrast only, not CVD simulation — border case, excluded under the strict rule |

---
