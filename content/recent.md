---
title: "Recent themes"
lane: "02c"
laneName: "Editors"
slug: "recent"
weight: 5
---

Recent engineering-heavy themes. All verified against primary sources.

## Opo — the most engineered entry in this report

IschaGast, 2026 ([repo](https://github.com/IschaGast/opo-theme), MIT). "Colorblind-safe, OKLCH-based
accessible color theme for editors, terminals, and web." **363 contrast checks enforced at build
time** (121 per variant) plus a trichromacy CVD-distance gate — color pairs are checked for
perceptual distance under simulated deuteranopia, protanopia, *and* tritanopia, and the build fails
on collision. Uses the Okabe–Ito blue+orange move by name. Ships to **21 export targets** (VS Code,
Zed, JetBrains `.icls`, Neovim, Ghostty, Alacritty, iTerm2, Warp, Windows Terminal, Firefox, Slack,
Raycast, Figma tokens, Adobe ASE, CSS, and more) — the widest platform spread of any CVD theme found.
Light (primary), Dark, and a WCAG-AAA High Contrast variant. Notably it remaps ANSI green to **teal**
(`#33a397`) rather than pure blue.

![Opo dark editor mock](colorblind-themes/opo-dark-editor.png)

![Opo dark CVD strip](colorblind-themes/opo-dark-strip.png)

![Opo light editor mock](colorblind-themes/opo-light-editor.png)

![Opo light CVD strip](colorblind-themes/opo-light-strip.png)

## Shroom Space — three dichromacy variants, CI-enforced

WyattAu, 2025 ([marketplace](https://marketplace.visualstudio.com/items?itemName=wyattau.shroom-space-theme),
[repo](https://github.com/WyattAu/shroom-theme)). Seven variants including dedicated **deuteranopia,
protanopia, and tritanopia** themes. Unusually honest engineering: `ACCESSIBILITY.md` enforces WCAG
2.1 AA on alpha-composited pairs, WCAG 2.2 SC 1.4.11 non-text, **APCA |Lc| ≥ 2 separation between
competing token categories**, and linear-RGB CVD simulation — all in CI (`npm run audit:palette`),
with an explicit note that simulation is "a worst-case collision detector, not a picture of what
anyone sees," plus a user-testing protocol.

![Shroom Space deuteranopia editor mock](colorblind-themes/shroom-dark-editor.png)

![Shroom Space CVD strip](colorblind-themes/shroom-dark-strip.png)

## ColorSafe Themes (JetBrains) — measured axes

Clément Séhan, 2026 ([plugin](https://plugins.jetbrains.com/plugin/31376-colorsafe-themes),
[repo](https://github.com/clementsehan/color-safe-themes-jetbrains)). Two dark schemes — **Pro-Deutan
Dark** (blue `#5BB8F5` / amber `#E6A020` axis, errors in hot pink `#FF5F87` **triple-encoded** as
color + squiggly + bold) and **Tritan Dark** (hot pink `#FF216A` / cyan `#01D4F9`, chosen because
under tritanopia they sit at opposite ends of the preserved L–M axis). Rare rigor: the `.icls`
source headers contain per-color WCAG contrast tables computed against the editor background.

![ColorSafe Pro-Deutan editor mock](colorblind-themes/colorsafe-dark-editor.png)

![ColorSafe CVD strip](colorblind-themes/colorsafe-dark-strip.png)

## Cindervale Accessible — CVD-measured dark + light pair

erenthedeveloper0, 2026 ([marketplace](https://marketplace.visualstudio.com/items?itemName=erenthedeveloper0.cindervale-theme),
[repo](https://github.com/erenthedeveloper0/cindervale), MIT). Original warm pair plus **Accessible
Dark / Accessible Light** measured under all three dichromacies. The method is published and honest
about its failures (`docs/accessibility.md` records where the accessible palette ended up *closer*
than the original). Design rule: "pairs that share a hue family under a color vision deficiency are
kept a full lightness tier apart"; red never needs to be told from green.

![Cindervale Accessible dark editor mock](colorblind-themes/cindervale-dark-editor.png)

![Cindervale CVD strip](colorblind-themes/cindervale-dark-strip.png)

## More recent entries

| Theme | Platform | Why it matters | Link |
|---|---|---|---|
| **Slatis Nyx** (utreras) | VS Code + Zed | build refuses to finish when two syntax roles collide under CVD; GitHub-CB syntax on true black | [repo](https://github.com/utreras/slatis-nyx) |
| **modus-theme-suite** (lovesqualor) | Ghostty/kitty/iTerm2/Neovim/Claude Code | modus deuteranopia ported across terminals + agents | [repo](https://github.com/lovesqualor/modus-theme-suite) |
| **gitlab-colorblind** (bassepeder) | GitLab web UI | **first GitLab CVD skin** — browser extension remapping every `--gl-color-green-*`→blue, `--gl-color-red-*`→orange | [repo](https://github.com/bassepeder/gitlab-colorblind) |
| **claude-code-contrast** (samgutentag) | Claude Code | documents that the stock `dark-daltonized` theme leaves `userMessageBackground` at **1.18:1** contrast — "a luminance problem wearing a color problem's clothes" | [repo](https://github.com/samgutentag/claude-code-contrast) |
| **colbrush** (2025-OSDC) | React/PostCSS | CVD-variant **generator**: derives protan/deutan/tritan themes from any base CSS palette | [repo](https://github.com/2025-OSDC/colbrush) |
| **Locus** (Jeff1995) | Obsidian | Okabe-Ito variables verbatim in CSS (`--oi-blue: #0072b2`…), built for computational biology | [repo](https://github.com/Jeff1995/Locus) |

**Cautionary tale worth citing:** `claude-code-contrast` shows that Claude Code's shipped
"daltonized" theme fixes every hue token but leaves the worst offender — a 1.18:1 message
background — untouched. CVD safety is a luminance problem as much as a hue problem.

---
