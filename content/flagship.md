---
title: "Flagship themes"
lane: "02a"
laneName: "Editors"
slug: "flagship"
weight: 3
---

## GitHub Colorblind (Primer) — protanopia & deuteranopia

The most widely deployed CVD themes in existence: shipped to every github.com user
([beta announcement, 2021-09-29](https://github.blog/changelog/2021-09-29-colorblind-themes-beta),
[renamed "Protanopia & Deuteranopia", 2022-04-19](https://github.blog/changelog/2022-04-19-protanopia-deuteranopia-colorblind-themes-beta)),
generated from design tokens in [primer/primitives](https://github.com/primer/primitives) (MIT) and
consumed downstream by the [GitHub VS Code theme](https://github.com/primer/github-vscode-theme),
the Neovim port [projekt0n/github-nvim-theme](https://github.com/projekt0n/github-nvim-theme),
iTerm2 ports, and [base16/tinted-theming](https://github.com/tinted-theming/schemes) schemes.
Separate **Tritanopia** variants exist
([changelog](https://github.blog/changelog/2022-04-19-tritanopia-colorblind-theme-beta)).

The signature move: dark-mode `fgColor-success` `#3fb950` (green) → `#58a6ff` (blue);
`fgColor-danger` `#f85149` (red) → `#f0883e` (orange).

| | bg | fg | keyword | func | string | number | type | comment |
|---|---|---|---|---|---|---|---|---|
| **Dark** | `#0d1117` | `#e6edf3` | `#ec8e2c` | `#d2a8ff` | `#a5d6ff` | `#79c0ff` | `#ffa657` | `#8b949e` |
| **Light** | `#ffffff` | `#1f2328` | `#b35900` | `#6639ba` | `#0a3069` | `#0550ae` | `#953800` | `#57606a` |

![GitHub Dark Colorblind editor mock](colorblind-themes/github-dark-editor.png)

![GitHub Dark Colorblind CVD simulation strip](colorblind-themes/github-dark-strip.png)

![GitHub Light Colorblind editor mock](colorblind-themes/github-light-editor.png)

![GitHub Light Colorblind CVD simulation strip](colorblind-themes/github-light-strip.png)

Note the tritanopia row: it is the only simulation where these hues visibly shift — this theme
pair targets red-green CVD; GitHub ships separate tritanopia themes for that axis.

## Modus themes (Emacs) — deuteranopia & tritanopia

By Protesilaos Stavrou. Canonical in Emacs (built-in since Emacs 28;
[protesilaos.com/emacs/modus-themes](https://protesilaos.com/emacs/modus-themes),
[repo](https://github.com/protesilaos/modus-themes), GPL-3.0). Four dedicated CVD variants:
`modus-operandi-deuteranopia` / `-tritanopia` (light), `modus-vivendi-deuteranopia` / `-tritanopia`
(dark). The whole family is **WCAG AAA (≥7:1 contrast)**; CVD variants additionally re-route
semantic colors off the confused axis. Ported to
[Neovim](https://github.com/miikanissi/modus-themes.nvim) and
[Zed](https://github.com/vitallium/zed-modus-themes) (all 8 variants), plus iTerm2.

| | bg | fg | red | green | yellow | blue | magenta | cyan |
|---|---|---|---|---|---|---|---|---|
| **Operandi (light)** | `#ffffff` | `#000000` | `#a60000` | `#006800` | `#695500` | `#0031a9` | `#721045` | `#005e8b` |
| **Vivendi (dark)** | `#000000` | `#ffffff` | `#ff5f59` | `#44bc44` | `#cabf00` | `#2fafff` | `#feacd0` | `#00d3d0` |

![Modus vivendi deuteranopia editor mock](colorblind-themes/modus-dark-editor.png)

![Modus vivendi deuteranopia CVD strip](colorblind-themes/modus-dark-strip.png)

![Modus operandi deuteranopia editor mock](colorblind-themes/modus-light-editor.png)

![Modus operandi deuteranopia CVD strip](colorblind-themes/modus-light-strip.png)

## ef-themes (Emacs) — the second CVD Emacs family, errors remapped to yellow

Also by Protesilaos Stavrou ([repo](https://github.com/protesilaos/ef-themes), GPL-3.0; GNU ELPA +
MELPA as `ef-themes`). Alongside modus, this is the second CVD-specific Emacs family — the **ef CVD quartet**: `ef-deuteranopia-dark`, `ef-deuteranopia-light`,
`ef-tritanopia-dark`, `ef-tritanopia-light`. The signature design move is different from modus:
**semantic mappings route `err → yellow-warmer` and `warning → yellow-cooler`, so errors are
yellow, not red.** Source comment: *"Most of the colors here, like the red and green hues, are
defined simply to preserve compatibility… We don't actually rely on them for anything critical."*

| | bg | fg | red | green | yellow | blue | magenta |
|---|---|---|---|---|---|---|---|
| **ef-deuteranopia-dark** | `#000a1f` | `#ddddee` | `#cf8560` | `#3faa26` | `#aa9f32` | `#3f90f0` | `#b379bf` |
| **ef-deuteranopia-light** | `#f5f5ff` | `#1a1a2f` | `#d3303a` | `#217a3c` | `#805d00` | `#375cd8` | `#ba35af` |

![ef-deuteranopia-dark editor mock](colorblind-themes/ef-deuteranopia-dark-editor.png)

![ef-deuteranopia-dark CVD strip](colorblind-themes/ef-deuteranopia-dark-strip.png)

![ef-deuteranopia-light editor mock](colorblind-themes/ef-deuteranopia-light-editor.png)

![ef-deuteranopia-light CVD strip](colorblind-themes/ef-deuteranopia-light-strip.png)

The four Ef variants ship in **WezTerm's built-in scheme index** (`Ef-Deuteranopia-Dark/Light`,
`Ef-Tritanopia-Dark/Light`) alongside three Modus ports — making WezTerm one of the few terminals
with first-party CVD schemes.

## Pierre — four CVD themes with a build-time simulation gate

From Pierre Computer Company: `pierre-{light,dark}-{protanopia-deuteranopia,tritanopia}`
([repo](https://github.com/pierrecomputer/pierre), npm
[`@pierre/theme`](https://www.npmjs.com/package/@pierre/theme), Apache-2.0; also generates Zed and
VS Code themes). The most rigorously engineered entry in this report: `packages/theme/ACCESSIBILITY.md`
documents a **hard build gate** that simulates every chromatic role under Machado (2009) in both
linear-RGB and gamma-sRGB and fails the build if CIEDE2000 ΔE < 11 (diffs, merges, terminal
red/green) or < 8 (diagnostics, core syntax). Signals remap to the preserved axis: blue↔orange for
red-green CVD, red↔teal/cyan for tritanopia.

![Pierre dark protan/deutan editor mock](colorblind-themes/pierre-dark-editor.png)

![Pierre dark protan/deutan CVD strip](colorblind-themes/pierre-dark-strip.png)

![Pierre light protan/deutan editor mock](colorblind-themes/pierre-light-editor.png)

![Pierre light protan/deutan CVD strip](colorblind-themes/pierre-light-strip.png)

## datum — Okabe–Ito hues, rebuilt in OKLCH

By w0zro ([repo](https://github.com/w0zro/datum), [site](https://datum.w0zro.com), MIT, 2026) —
the newest entry. Hue angles anchored on the Okabe–Ito set, placed in OKLCH, "verified against
WCAG 2.2 and APCA" and simulated against all three dichromacies. Ships for Neovim/Vim, VS Code,
Ghostty, Kitty, Alacritty, WezTerm, tmux, fzf, bat, delta, and in iTerm2-Color-Schemes. Dark + light.

| | bg | fg | blue | green | cyan | yellow | orange | pink |
|---|---|---|---|---|---|---|---|---|
| **Dark** | `#0f1318` | `#ced3d9` | `#69b9f7` | `#54dcaa` | `#6ae5ec` | `#e8df69` | `#f8bd5f` | `#fa94cd` |
| **Light** | `#f1f6fd` | `#242a30` | `#0176b8` | `#007553` | `#0d7a7f` | `#976700` | `#a24500` | `#973070` |

![datum dark editor mock](colorblind-themes/datum-dark-editor.png)

![datum dark CVD strip](colorblind-themes/datum-dark-strip.png)

![datum light editor mock](colorblind-themes/datum-light-editor.png)

![datum light CVD strip](colorblind-themes/datum-light-strip.png)

---
