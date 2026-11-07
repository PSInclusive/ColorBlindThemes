# Color Themes Designed for Colorblind Users

A catalog of published color themes and palettes built for color-vision-deficient (CVD) users —
with links to primary sources, real hex values, rendered examples in dark and light modes, and a
computed test of which palettes actually survive CVD simulation.

Every example SVG on this site is generated from hexes extracted from the theme's own source files,
and each swatch plate includes rows simulating how the palette looks under each type of color
blindness (using the Machado et al. 2009 model, the same one behind
[Coblis](https://www.color-blindness.com/coblis/coblis.html) and most modern simulators).

---

## Contents

- [Background: why special themes exist](#background-why-special-themes-exist)
- [The one design move everyone converged on](#the-one-design-move-everyone-converged-on)
- [Flagship themes](#flagship-themes) — GitHub, Modus, ef-themes, Pierre, datum (editor mock + CVD strip each)
- [Editor & IDE themes](#editor--ide-themes) — VS Code, Vim, Neovim, Zed, Emacs, Helix, JetBrains, Atom, Xcode, Sublime
- [Terminal themes](#terminal-themes) — Dalton, hakarune collection, iTerm2 ports, orca
- [Recent themes](#recent-themes) — Opo, Shroom Space, ColorSafe, Cindervale, Slatis Nyx, and more
- [App & OS-UI themes](#app--os-ui-themes) — Grafana, coder, Jupyter Pitaya, KDE Lx Deep Sea, Slack/Discord, OS filter reality
- [Data-visualization & scientific palettes](#data-visualization--scientific-palettes) — Okabe–Ito, Tol, Wong, IBM, Petroff, Qualpal, cividis, viridis, Crameri, and more
- [Timeline 1997–2026](#timeline-19972026)
- [Simulation & validation tools](#simulation--validation-tools)
- [Standards & guidance](#standards--guidance)
- [Not included, and why](#not-included-and-why)
- [Independent verification](#independent-verification-which-palettes-actually-survive-cvd-simulation) — which palettes survive simulation, computed

---

## Background: why special themes exist

### What color blindness actually is

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

### Why ordinary themes fail

Most color themes pick colors for how they look to full color vision. Red means error, green means
success, a diff's additions are green and deletions red. For a deuteranope those two colors sit on
the collapsed axis and become nearly the same muddy tone — so the one signal the UI most needs to
communicate is the one that disappears. This is not a contrast problem (the colors can be equally
bright and still indistinguishable), so "high contrast" themes do not fix it.

### Why the standard doesn't fix it either

**WCAG does not require CVD-safe palettes.** SC 1.4.1 (Use of Color) only bans color as the *sole*
information carrier, and a ≥3:1 luminance difference counts as a non-color distinction — a page can
pass AA while pairing red with green everywhere
([Understanding SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)).
The themes below exist to fill exactly that gap.

## The one design move everyone converged on

Every explicitly CVD-designed UI theme found in this research uses one of two strategies:

1. **Collapse the red↔green axis onto orange↔blue** (GitHub colorblind themes, hakarune terminal
   collection, Pierre, Gentle). "Success" green becomes blue; "danger" red becomes orange.
2. **Anchor hues on a scientifically validated colorblind-safe palette** (datum → Okabe–Ito;
   vim-dichromatic and Blinds → Paul Tol SRON; givensuman → Tol discrete rainbow).

Both often combine with a **luminance backup channel**: confused hues are also separated by
lightness, so the distinction survives even when hue perception collapses.

---

## Flagship themes

### GitHub Colorblind (Primer) — protanopia & deuteranopia

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

![GitHub Dark Colorblind editor mock](assets/colorblind-themes/github-dark-editor.png)

![GitHub Dark Colorblind CVD simulation strip](assets/colorblind-themes/github-dark-strip.png)

![GitHub Light Colorblind editor mock](assets/colorblind-themes/github-light-editor.png)

![GitHub Light Colorblind CVD simulation strip](assets/colorblind-themes/github-light-strip.png)

Note the tritanopia row: it is the only simulation where these hues visibly shift — this theme
pair targets red-green CVD; GitHub ships separate tritanopia themes for that axis.

### Modus themes (Emacs) — deuteranopia & tritanopia

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

![Modus vivendi deuteranopia editor mock](assets/colorblind-themes/modus-dark-editor.png)

![Modus vivendi deuteranopia CVD strip](assets/colorblind-themes/modus-dark-strip.png)

![Modus operandi deuteranopia editor mock](assets/colorblind-themes/modus-light-editor.png)

![Modus operandi deuteranopia CVD strip](assets/colorblind-themes/modus-light-strip.png)

### ef-themes (Emacs) — the second CVD Emacs family, errors remapped to yellow

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

![ef-deuteranopia-dark editor mock](assets/colorblind-themes/ef-deuteranopia-dark-editor.png)

![ef-deuteranopia-dark CVD strip](assets/colorblind-themes/ef-deuteranopia-dark-strip.png)

![ef-deuteranopia-light editor mock](assets/colorblind-themes/ef-deuteranopia-light-editor.png)

![ef-deuteranopia-light CVD strip](assets/colorblind-themes/ef-deuteranopia-light-strip.png)

The four Ef variants ship in **WezTerm's built-in scheme index** (`Ef-Deuteranopia-Dark/Light`,
`Ef-Tritanopia-Dark/Light`) alongside three Modus ports — making WezTerm one of the few terminals
with first-party CVD schemes.

### Pierre — four CVD themes with a build-time simulation gate

From Pierre Computer Company: `pierre-{light,dark}-{protanopia-deuteranopia,tritanopia}`
([repo](https://github.com/pierrecomputer/pierre), npm
[`@pierre/theme`](https://www.npmjs.com/package/@pierre/theme), Apache-2.0; also generates Zed and
VS Code themes). The most rigorously engineered entry in this report: `packages/theme/ACCESSIBILITY.md`
documents a **hard build gate** that simulates every chromatic role under Machado (2009) in both
linear-RGB and gamma-sRGB and fails the build if CIEDE2000 ΔE < 11 (diffs, merges, terminal
red/green) or < 8 (diagnostics, core syntax). Signals remap to the preserved axis: blue↔orange for
red-green CVD, red↔teal/cyan for tritanopia.

![Pierre dark protan/deutan editor mock](assets/colorblind-themes/pierre-dark-editor.png)

![Pierre dark protan/deutan CVD strip](assets/colorblind-themes/pierre-dark-strip.png)

![Pierre light protan/deutan editor mock](assets/colorblind-themes/pierre-light-editor.png)

![Pierre light protan/deutan CVD strip](assets/colorblind-themes/pierre-light-strip.png)

### datum — Okabe–Ito hues, rebuilt in OKLCH

By w0zro ([repo](https://github.com/w0zro/datum), [site](https://datum.w0zro.com), MIT, 2026) —
the newest entry. Hue angles anchored on the Okabe–Ito set, placed in OKLCH, "verified against
WCAG 2.2 and APCA" and simulated against all three dichromacies. Ships for Neovim/Vim, VS Code,
Ghostty, Kitty, Alacritty, WezTerm, tmux, fzf, bat, delta, and in iTerm2-Color-Schemes. Dark + light.

| | bg | fg | blue | green | cyan | yellow | orange | pink |
|---|---|---|---|---|---|---|---|---|
| **Dark** | `#0f1318` | `#ced3d9` | `#69b9f7` | `#54dcaa` | `#6ae5ec` | `#e8df69` | `#f8bd5f` | `#fa94cd` |
| **Light** | `#f1f6fd` | `#242a30` | `#0176b8` | `#007553` | `#0d7a7f` | `#976700` | `#a24500` | `#973070` |

![datum dark editor mock](assets/colorblind-themes/datum-dark-editor.png)

![datum dark CVD strip](assets/colorblind-themes/datum-dark-strip.png)

![datum light editor mock](assets/colorblind-themes/datum-light-editor.png)

![datum light CVD strip](assets/colorblind-themes/datum-light-strip.png)

---

## Editor & IDE themes

### vim-dichromatic (Vim/Neovim)

Romain Lafourcade, 2016 — "A dark Vim colorscheme for color blind vimmers. But not only."
([repo](https://github.com/romainl/vim-dichromatic), MIT). Built directly on **Paul Tol's SRON
colorblind-safe palette**, adapted to xterm-256. Dark only. bg `#080808`, fg `#D0D0D0`;
Number `#D75F87`, Statement `#AF5FAF`, String `#AFAF00`, Type `#87D7D7`, Title `#5FAF87`.

![Dichromatic editor mock](assets/colorblind-themes/dichromatic-dark-editor.png)

![Dichromatic CVD strip](assets/colorblind-themes/dichromatic-dark-strip.png)

### Blinds (VS Code) — deuteranopia

Tan Ka-Shing ([marketplace](https://marketplace.visualstudio.com/items?itemName=tankashing.blinds-theme),
[repo](https://github.com/orbulant/blinds-theme), GPL-3.0). "A colorblind (deuteranopia) friendly,
dark, material designed theme." Syntax roles come from **Paul Tol's "bright" scheme**
(`#4477AA #EE6677 #228833 #CCBB44 #66CCEE #AA3377`). **Dark and light.**

![Blinds dark editor mock](assets/colorblind-themes/blinds-dark-editor.png)

![Blinds dark CVD strip](assets/colorblind-themes/blinds-dark-strip.png)

![Blinds light editor mock](assets/colorblind-themes/blinds-light-editor.png)

![Blinds light CVD strip](assets/colorblind-themes/blinds-light-strip.png)

### Gentle Theme (VS Code) — teal + orange, WCAG AA

carlossalguero ([marketplace](https://marketplace.visualstudio.com/items?itemName=carlossalguero.gentle-theme), MIT).
Six variants (Light/Dark/Midnight × neutral/Warm). The source repo (`salgue441/gentle-theme`) is no
longer public (404 as of 2026-11-05); the palette below was extracted from the packaged VSIX.
Explicit rationale: "Red/green confusion → Teal + Orange palette (distinguishable by everyone)."

![Gentle dark editor mock](assets/colorblind-themes/gentle-dark-editor.png)

![Gentle dark CVD strip](assets/colorblind-themes/gentle-dark-strip.png)

![Gentle light editor mock](assets/colorblind-themes/gentle-light-editor.png)

![Gentle light CVD strip](assets/colorblind-themes/gentle-light-strip.png)

### Hakimi Deuteranopia Safe (Zed / VS Code / Obsidian)

hakimi ([Zed extension](https://zed.dev/extensions/hakimi-deuteranopia-theme),
[repo](https://github.com/zogwosh/hakimi-theme), MIT, 2026). Every color drawn from
deuteranopia-safe sets. **Dark and light.**

![Hakimi dark editor mock](assets/colorblind-themes/hakimi-dark-editor.png)

![Hakimi dark CVD strip](assets/colorblind-themes/hakimi-dark-strip.png)

![Hakimi light editor mock](assets/colorblind-themes/hakimi-light-editor.png)

![Hakimi light CVD strip](assets/colorblind-themes/hakimi-light-strip.png)

### Monokai Deuteranopia Colorblind (VS Code)

Felipe Zarco ([marketplace](https://marketplace.visualstudio.com/items?itemName=felipezarco.monokai-deuteranopia-colorblind),
[repo](https://github.com/felipezarco/monokai-deuteranopia-colorblind), MIT). Monokai retuned onto
the blue–yellow axis; reuses Okabe–Ito sky blue `#56B4E9` (caret) and reddish purple `#CC79A7` (types).
Dark only: bg `#0B1026`, fg `#D4E4FF`.

![Monokai Deuteranopia editor mock](assets/colorblind-themes/monokai-deuteranopia-dark-editor.png)

![Monokai Deuteranopia CVD strip](assets/colorblind-themes/monokai-deuteranopia-dark-strip.png)

### More verified editor themes

| Theme | Platform | CVD target | Dark/Light | Link |
|---|---|---|---|---|
| **Color Blind Themes** (Goofygoobers) | VS Code | protanopia + deuteranopia (author has CVD) | dark | [repo](https://github.com/goofygoobers/color-blind-vscode-theme) · [marketplace](https://marketplace.visualstudio.com/items?itemName=Goofygoobers.color-blind-themes) |
| **Colorblind Theme** (Given Suman) | VS Code | all CVD types; generated from Tol's 23-color discrete rainbow | dark | [repo](https://github.com/givensuman/colorblind-theme) · [marketplace](https://marketplace.visualstudio.com/items?itemName=GivenSuman.colorblind-theme) |
| **One Dark Pro Colorblind** (Suhaybu) | VS Code | deuteranopia | dark (5 variants) | [repo](https://github.com/suhaybu/OneDarkPro-Colorblind) |
| **Github Dark Tritanopia** (zanaty) | VS Code | tritanopia | dark | [repo](https://github.com/moelzanaty3/github-dark-tritanopia) |
| **morimo** (ttak0422) | Neovim | general CVD; muted lightness-separated ramps | dark | [repo](https://github.com/ttak0422/morimo) |
| **vision.nvim** (shrik3, archived) | Neovim + Kitty/Alacritty | general CVD (author has CVD; tokyonight hues retuned) | dark | [repo](https://github.com/shrik3/vision.nvim) |
| **github-nvim-theme** (projekt0n) | Neovim | protan/deutan + tritanopia variants of GitHub themes | both | [repo](https://github.com/projekt0n/github-nvim-theme) |

### Helix — ships 8 CVD themes in its official runtime

[Helix](https://github.com/helix-editor/helix) (MPL-2.0) ships **eight
CVD themes out of the box** in `runtime/themes/` — four GitHub Primer ports (dark/light colorblind +
dark/light tritanopia, by OwOSwordsman) and four modus ports (operandi/vivendi ×
deuteranopia/tritanopia, by Matous Dzivjak from modus v4.6.0). The Primer token swap is faithful:
`scale.green.*` is aliased to the blue scale and red to orange. Listed on the official
[themes page](https://docs.helix-editor.com/themes.html). Along with Emacs and Neovim, Helix is one
of three editors shipping first-party CVD themes.

### JetBrains — three CVD plugins on the marketplace

Exactly three CVD plugins exist on the JetBrains marketplace
(`site:plugins.jetbrains.com colorblind` → 19011, 32346, 31376):

| Plugin | Author | CVD target | Notes | Link |
|---|---|---|---|---|
| **Colorblind Theme** | Captain Gopher / 4meepo | general (light only) | explicit intent, personal one-author theme, weak verification | [plugin](https://plugins.jetbrains.com/plugin/19011-colorblind-theme) · [repo](https://github.com/4meepo/jetbrain-colorblind-theme) |
| **GitHub Dark/Light Colorblind Islands** | 4iwen | protan/deutan | ports Primer colorblind tokens verbatim into the Islands UI; danger fg `#D47616` orange | [plugin](https://plugins.jetbrains.com/plugin/32346-github-dark-colorblind-islands) · [repo](https://github.com/4iwen/github-dark-colorblind-islands-theme) |
| **ColorSafe Themes** | Clément Séhan | protan+deutan and tritan (dark) | blue `#5BB8F5`/amber `#E6A020` and hot-pink `#FF216A`/cyan `#01D4F9` axes; per-color WCAG tables documented in the `.icls` source | [plugin](https://plugins.jetbrains.com/plugin/31376-colorsafe-themes) · [repo](https://github.com/clementsehan/color-safe-themes-jetbrains) |

### Atom, Xcode, Sublime — one entry each

- **Atom (archived):** thierryc's [dark-side-of-the-moon](https://github.com/thierryc/dark-side-of-the-moon-syntax)
  (dark, 2016) and [far-side-of-the-moon](https://github.com/thierryc/far-side-of-the-moon-syntax)
  (light, 2017) — MIT, Krzywinski-inspired palettes designed "to be accessible to as many people as
  possible… experiencing any kind of colorblindness." Design intent, not simulation-verified.
- **Xcode:** lebojo's [Vision (colorblind)](https://github.com/lebojo/colorblind-xcode-theme)
  (2026) — the first CVD Xcode theme family; dark (`#FC4D1F` vermilion keywords, `#21C0FC` cyan
  strings) + light + 16pt XL variants, both old `.xccolortheme` and new Xcode 16+ formats.
- **Sublime Text:** [InuProt](https://github.com/CudtMFrag/InuProt) (2026, MIT) — the only CVD
  Sublime theme (packagecontrol.io has zero CVD-labelled packages); dark + light, protan/deutan,
  keyword-green separated from orange control-flow by hue *and* bold weight, with checked-in
  VS Code ↔ Sublime converters.

![Goofygoobers editor mock](assets/colorblind-themes/goofygoobers-dark-editor.png)

![Goofygoobers CVD strip](assets/colorblind-themes/goofygoobers-dark-strip.png)

![One Dark Pro Colorblind editor mock](assets/colorblind-themes/onedarkpro-cb-dark-editor.png)

![One Dark Pro Colorblind CVD strip](assets/colorblind-themes/onedarkpro-cb-dark-strip.png)

![morimo editor mock](assets/colorblind-themes/morimo-dark-editor.png)

![morimo CVD strip](assets/colorblind-themes/morimo-dark-strip.png)

![vision.nvim editor mock](assets/colorblind-themes/vision-dark-editor.png)

![vision.nvim CVD strip](assets/colorblind-themes/vision-dark-strip.png)

---

## Terminal themes

### Dalton Dark / Dalton Bright (gerchowl)

[repo](https://github.com/gerchowl/dalton-colorscheme), MIT. "A colorblind-friendly terminal color
scheme for deuteranopia and protanopia." Ghostty, iTerm2, lazygit, CSS. 16-color ANSI palettes where
red/green/blue slots are luminance- and hue-separated under both dichromacies. **Dark and light.**

![Dalton dark editor mock](assets/colorblind-themes/dalton-dark-editor.png)

![Dalton dark CVD strip](assets/colorblind-themes/dalton-dark-strip.png)

![Dalton bright editor mock](assets/colorblind-themes/dalton-light-editor.png)

![Dalton bright CVD strip](assets/colorblind-themes/dalton-light-strip.png)

### hakarune/colorblind-terminal-themes

[repo](https://github.com/hakarune/colorblind-terminal-themes), GPL-3.0. A **verified** (not just
designed) collection: ships its own Machado-2009 simulation script (`scripts/cvd_sim.py`) and checks
every theme against protanopia, deuteranopia, and tritanopia. Strategy: replace only the red/green
ANSI slots (red→orange, green→blue), keeping the rest of each upstream palette intact. Covers the
five major terminal stock palettes (GNOME, Konsole, iTerm2 Basic, Windows Terminal Campbell,
Alacritty) plus CVD remixes of Dracula, Nord, Solarized, Tokyo Night, Catppuccin, Gruvbox, and a
repaired dichromatic port (`dichromatic-fixed` fixes a real deuteranopia collision between the
original's color9/color10).

![dracula-colorblind editor mock](assets/colorblind-themes/hakarune-dracula-dark-editor.png)

![dracula-colorblind CVD strip](assets/colorblind-themes/hakarune-dracula-dark-strip.png)

### iTerm2-Color-Schemes CVD entries

[repo](https://github.com/mbadolato/iTerm2-Color-Schemes) (gallery
[iterm2colorschemes.com](https://iterm2colorschemes.com)): ships **GitHub Dark/Light Colorblind**
(converted from Primer), **Modus Operandi/Vivendi Deuteranopia & Tritanopia** ports, and **datum**.
Hexes verified against the `.itermcolors` plists; they match the Primer/Modus sources in the
sections above.

### WezTerm ships 7 CVD schemes built in

WezTerm's [built-in scheme index](https://wezterm.org/colorschemes/data.json)
(1001 schemes synced from iTerm2-Color-Schemes/base16/Gogh) contains exactly **7 CVD-named schemes**,
all from the two Protesilaos Emacs families: `Ef-Deuteranopia-Dark/Light`, `Ef-Tritanopia-Dark/Light`,
and `Modus-Operandi/Vivendi-Deuteranopia`, `Modus-Vivendi-Tritanopia`. WezTerm is therefore one of
the only terminals with first-party CVD schemes out of the box. (`Ef-Deuteranopia-Dark`: bg `#000a1f`,
fg `#ddddee`, red→orange-brown `#cf8560`, cursor `#ffff00`.)

### Microsoft's own deuteranopia scheme

Windows Terminal ships no built-in CVD scheme. But Microsoft's own Windows Terminal **repo** ships
[`deuteranopia.itermcolors`](https://github.com/microsoft/terminal/blob/main/src/tools/ColorTool/schemes/deuteranopia.itermcolors)
in its ColorTool samples (MIT) — an aggressive remap (red→yellow `#999900`, green→blue `#000099`,
bright red→`#ffff00`, bright green→`#0000ff`). Functional, not refined; the blue channel is heavily
reused. It's a sample, not a shipping default — hence the "no built-in" finding stands, but a
Microsoft-authored CVD palette does exist.

### Konsole / Yakuake — no dedicated project, but an import path

No Konsole- or Yakuake-specific CVD theme project exists (store.kde.org is bot-walled). The import
path that works: iTerm2-Color-Schemes' `konsole/` directory ships 7 CVD `.colorscheme` files
(Dalton Dark, GitHub Dark/Light Colorblind, and four Modus variants), which import into Konsole and
Yakuake. And projekt0n's [github-theme-contrib](https://github.com/projekt0n/github-theme-contrib)
publishes four GitHub Colorblind/Tritanopia Konsole schemes (MIT) on the KDE store.

### orca-themes — deuteranopia, quantified

[repo](https://github.com/Sandstorm831/orca-themes) (2026) for the [Orca terminal](https://onorca.dev).
The most measurement-driven terminal entry: every theme is run through full-strength Machado 2009
simulation and scored by **CIEDE2000 red/green gap**, with the numbers published (their GitHub Dark
Colorblind Fixed scores 58; Orca's stock Tango Light scores only 8; "above 20 reads as clearly
different"). Ships `github-dark-colorblind-fixed.yaml` which repairs real defects in GitHub's own
colorblind terminal port (duplicated ANSI blue, red/yellow clash). Dark + light.

---

## Recent themes

Recent engineering-heavy themes. All verified against primary sources.

### Opo — the most engineered entry in this report

IschaGast, 2026 ([repo](https://github.com/IschaGast/opo-theme), MIT). "Colorblind-safe, OKLCH-based
accessible color theme for editors, terminals, and web." **363 contrast checks enforced at build
time** (121 per variant) plus a trichromacy CVD-distance gate — color pairs are checked for
perceptual distance under simulated deuteranopia, protanopia, *and* tritanopia, and the build fails
on collision. Uses the Okabe–Ito blue+orange move by name. Ships to **21 export targets** (VS Code,
Zed, JetBrains `.icls`, Neovim, Ghostty, Alacritty, iTerm2, Warp, Windows Terminal, Firefox, Slack,
Raycast, Figma tokens, Adobe ASE, CSS, and more) — the widest platform spread of any CVD theme found.
Light (primary), Dark, and a WCAG-AAA High Contrast variant. Notably it remaps ANSI green to **teal**
(`#33a397`) rather than pure blue.

![Opo dark editor mock](assets/colorblind-themes/opo-dark-editor.png)

![Opo dark CVD strip](assets/colorblind-themes/opo-dark-strip.png)

![Opo light editor mock](assets/colorblind-themes/opo-light-editor.png)

![Opo light CVD strip](assets/colorblind-themes/opo-light-strip.png)

### Shroom Space — three dichromacy variants, CI-enforced

WyattAu, 2025 ([marketplace](https://marketplace.visualstudio.com/items?itemName=wyattau.shroom-space-theme),
[repo](https://github.com/WyattAu/shroom-theme)). Seven variants including dedicated **deuteranopia,
protanopia, and tritanopia** themes. Unusually honest engineering: `ACCESSIBILITY.md` enforces WCAG
2.1 AA on alpha-composited pairs, WCAG 2.2 SC 1.4.11 non-text, **APCA |Lc| ≥ 2 separation between
competing token categories**, and linear-RGB CVD simulation — all in CI (`npm run audit:palette`),
with an explicit note that simulation is "a worst-case collision detector, not a picture of what
anyone sees," plus a user-testing protocol.

![Shroom Space deuteranopia editor mock](assets/colorblind-themes/shroom-dark-editor.png)

![Shroom Space CVD strip](assets/colorblind-themes/shroom-dark-strip.png)

### ColorSafe Themes (JetBrains) — measured axes

Clément Séhan, 2026 ([plugin](https://plugins.jetbrains.com/plugin/31376-colorsafe-themes),
[repo](https://github.com/clementsehan/color-safe-themes-jetbrains)). Two dark schemes — **Pro-Deutan
Dark** (blue `#5BB8F5` / amber `#E6A020` axis, errors in hot pink `#FF5F87` **triple-encoded** as
color + squiggly + bold) and **Tritan Dark** (hot pink `#FF216A` / cyan `#01D4F9`, chosen because
under tritanopia they sit at opposite ends of the preserved L–M axis). Rare rigor: the `.icls`
source headers contain per-color WCAG contrast tables computed against the editor background.

![ColorSafe Pro-Deutan editor mock](assets/colorblind-themes/colorsafe-dark-editor.png)

![ColorSafe CVD strip](assets/colorblind-themes/colorsafe-dark-strip.png)

### Cindervale Accessible — CVD-measured dark + light pair

erenthedeveloper0, 2026 ([marketplace](https://marketplace.visualstudio.com/items?itemName=erenthedeveloper0.cindervale-theme),
[repo](https://github.com/erenthedeveloper0/cindervale), MIT). Original warm pair plus **Accessible
Dark / Accessible Light** measured under all three dichromacies. The method is published and honest
about its failures (`docs/accessibility.md` records where the accessible palette ended up *closer*
than the original). Design rule: "pairs that share a hue family under a color vision deficiency are
kept a full lightness tier apart"; red never needs to be told from green.

![Cindervale Accessible dark editor mock](assets/colorblind-themes/cindervale-dark-editor.png)

![Cindervale CVD strip](assets/colorblind-themes/cindervale-dark-strip.png)

### More recent entries

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

## App & OS-UI themes

### Application/platform-level CVD themes

Whole products shipping first-party colorblind themes (not editor plugins — the app itself).
Verified via merged PRs and source files:

| Product | What shipped | Merge | CVD types | Dark/Light | Source |
|---|---|---|---|---|---|
| **Grafana** | four UI themes (Deuteranopia/Protanopia + Tritanopia, dark+light) **and** a colorblind-safe viz palette option | [PR #116953](https://github.com/grafana/grafana/pull/116953) (2026-03), [PR #121385](https://github.com/grafana/grafana/pull/121385) (2026-04) | protan/deutan + tritan | both | [themeDefinitions](https://github.com/grafana/grafana/tree/main/packages/grafana-data/src/themes/themeDefinitions) |
| **coder/coder** | four sitewide colorblind theme palettes; source **cites Okabe-Ito** and maps destructive→vermilion/orange, success→sky-blue, warning→fuchsia | [PR #24672](https://github.com/coder/coder/pull/24672) (2026-05) | protan/deutan + tritan | both | [site/src/theme](https://github.com/coder/coder/tree/main/site/src/theme) |
| **Kilo Code CLI** | `/colorblind` toggle theme with high-contrast colors + patterns | [PR #4936](https://github.com/Kilo-Org/kilocode/pull/4936) (2026-01) | general | dark | repo |
| **Daintree IDE** | "Color vision" appearance mode overriding ~10 semantic tokens (status, github open/closed, terminal ANSI red/green) with live swatch preview | [PR #3042](https://github.com/daintreehq/daintree/pull/3042) (2026-03) | deuteran/protan + tritan | both | repo |

**Grafana** is the flagship here — the first major observability platform with built-in CVD themes.
The four theme files (`deuteranopia_protanopia_{dark,light}.json`, `tritanopia_{dark,light}.json`)
override the semantic signal colors: dark success `#2EC4B6` (teal) / error `#FF7A18` (orange) /
warning `#FFF899`; light success `#006F7A` / error `#FF9900` / warning `#FFEE52`. The viz palette
([`fieldColor.ts`](https://github.com/grafana/grafana/blob/main/packages/grafana-data/src/field/fieldColor.ts),
`PaletteColorblind` mode) is **Wong (2011) / Okabe–Ito verbatim** with black/white for
theme-adaptive contrast — the source comment cites Wong directly and states all 8 colors are
validated as mutually distinguishable under all three dichromacies.

![Grafana colorblind dark mock](assets/colorblind-themes/grafana-dark-editor.png)

![Grafana colorblind dark strip](assets/colorblind-themes/grafana-dark-strip.png)

![Grafana colorblind light mock](assets/colorblind-themes/grafana-light-editor.png)

![Grafana colorblind light strip](assets/colorblind-themes/grafana-light-strip.png)

**coder/coder**'s `darkProtanDeuter/roles.ts` is unusually well-documented: *"Protanopia and
deuteranopia compress the red/green channel, so semantic good/bad pairs that rely on green vs red
need a different axis. We shift destructive states onto a vermilion/orange hue (Tailwind orange
scale, inspired by the Okabe-Ito CVD-safe scheme), positive/active states onto sky-blue, and warning
onto fuchsia so it does not collide with destructive states on the orange axis."*

![coder colorblind mock](assets/colorblind-themes/coder-dark-editor.png)

![coder colorblind strip](assets/colorblind-themes/coder-dark-strip.png)

#### 20 more application-level CVD themes (merged, primary-source verified)

A GitHub merged-PR sweep across observability, code hosts, git GUIs, chat, note apps, CAD/3D
printing, game clients, and mobile surfaced these (full extraction notes in `.research/09-app-level.md`):

| Product | What shipped | Merge | Hexes / approach | Link |
|---|---|---|---|---|
| **Gitea** (→ Forgejo) | six first-party CSS variants: protan/deutan + tritan, dark/light/auto; diff red/green → blue/orange | 2024-04 [PR #30625](https://github.com/go-gitea/gitea/pull/30625) | dark add `#58a6ff`/del `#f0883e`, light add `#0860cc`/del `#a84400` | [themes](https://github.com/go-gitea/gitea/tree/main/web_src/css/themes) |
| **SimpleCov** | Colorblind toggle in the HTML coverage report (every Ruby project) | 2026-08 [PR #1257](https://github.com/simplecov-ruby/simplecov/pull/1257) | covered/missed: green/red → blue/orange, light+dark | repo |
| **plannotator** | full colorblind theme (dark+light), Machado-verified CIEDE2000 ≥ 8.9 | 2026-08 [PR #1192](https://github.com/backnotprop/plannotator/pull/1192) | add `#4f83d1`/del `#c96e12` (dark) | repo |
| **GitButler** | colorblind diff preview composing with 3 contrast levels × light/dark (12 palettes) | 2025-09 [PR #10146](https://github.com/gitbutlerapp/gitbutler/pull/10146) | blue/orange diff, full matrix | repo |
| **iamb** (Matrix TUI) | `okabe-ito-dark` theme; encrypted indicator deliberately **blue, not green** | 2026-10 [PR #822](https://github.com/ulyssa/iamb/pull/822) | full Okabe-Ito | repo |
| **tuicr** | `github-dark-colorblind` theme for the code-review TUI | 2026-08 [PR #523](https://github.com/agavra/tuicr/pull/523) | add `#58a6ff`/del `#f0883e` | repo |
| **Ultimaker Cura** | Colorblind Assist themes (dark+light) for layer-view line types — **oldest first-party entry (2019)** | 2019-07 [PR #5928](https://github.com/Ultimaker/Cura/pull/5928) | teal/yellow/cyan/blue layer colors | repo |
| **OpenFront.io** | Colorblind graphics preset; **largest published CVD hex pool (96)** | 2026-06 [PR #4150](https://github.com/openfrontio/OpenFrontIO/pull/4150) | Okabe-Ito team colors verbatim | repo |
| **RuneLite** | GPU-plugin colorblindness correction — **GLSL daltonization shader**, not a palette (unique mechanism) | 2020-11 [PR #12744](https://github.com/runelite/runelite/pull/12744) | per-deficiency LMS matrices (no hexes by design) | repo |
| **Talishar-FE** | **three distinct palettes, one per dichromacy** (rare) | live `colorblindPresets.ts` | deutan `#33aaee…`, protan `#11bbff…`, tritan `#22eeff…` | repo |
| **deepinv** (PyTorch imaging) | colorblind matplotlib cycle + marker cycler (redundant encoding) | 2026-09 [PR #1420](https://github.com/deepinv/deepinv/pull/1420) | Seaborn colorblind verbatim | repo |
| **gEAR** (genomics) | comprehensive colorblind mode across all plot types | 2026-10 [PR #1341](https://github.com/IGS/gEAR/pull/1341) | cividis + colorcet glasbey_cool | repo |
| **portico** (Filament admin) | per-user Okabe-Ito toggle (`colorblind_palette` column) | 2026-10 [PR #192](https://github.com/AsteriaCreations/portico/pull/192) | success `#0072B2`, danger `#D55E00`, warning `#E69F00` | repo |
| **steady** | five vision modes with measured ΔE00 floors | 2026-10 [PR #4](https://github.com/GabrielAboyDev/steady/pull/4) | quantified protan/deutan spacing | repo |
| **nammet-recipe-website** | "Blue & orange" + "Teal & crimson" themes; Machado test in CI (ΔE ≥ 40) | 2026-10 [PR #12](https://github.com/foshiee/nammet-recipe-website/pull/12) | simulation-gated | repo |
| **OSC_Workout_App** | light/dark/colorblind three-theme toggle | 2026-10 [PR #55](https://github.com/ufosc/OSC_Workout_App/pull/55) | Okabe-Ito `#56b4e9/#e69f00/#f0e442` | repo |
| **mai-tutor** | "Dark (colorblind-friendly)" mode | 2026-10 [PR #49](https://github.com/nguyen18/mai-tutor/pull/49) | Okabe-Ito-derived | repo |
| **cloudping.co** | latency colors recolored CVD-safe **by default for everyone** | 2026-10 [PR #100](https://github.com/mda590/cloudping.co/pull/100) | `#38bdf8/#facc15/#dc2626` | repo |
| **paseo** | colorblind mode: status green/red differ in **lightness** not just hue | 2026-09 [PR #5](https://github.com/ChrisjanWust/paseo/pull/5) | WCAG 1.4.1 luminance strategy | repo |
| **kitty** (`deuters_delight`) | curated first-party terminal theme replacing three older CVD attempts | 2022-04 [PR #44](https://github.com/kovidgoyal/kitty-themes/pull/44) | per-deficiency named | repo |

**Three patterns across all app-level CVD themes:**

1. **Okabe-Ito anchoring is dominant** — iamb, portico, OpenFront, OSC_Workout, deepinv, mai-tutor,
   RustySNES all cite or embed the eight canonical hexes. It is the de-facto standard.
2. **Blue/orange is the universal diff/status swap** — Gitea, SimpleCov, GitButler, plannotator,
   tuicr all converge on GitHub's `#58a6ff`/`#f0883e` (dark) or Okabe-Ito's `#0072B2`/`#D55E00`.
3. **Per-deficiency variants are emerging as the highest-fidelity approach** — Grafana (4 themes),
   Talishar (3 palettes), Gitea (2 CSS families), steady (5 modes) ship distinct palettes per CVD
   type rather than one "universal" palette, matching modus/ef-themes in editor space.

**Verified negatives** (no first-party CVD theme as of 2026-11-05): DataDog, Prometheus, Kibana,
GitLab (first-party — the third-party `gitlab-colorblind` extension covers it), Bitbucket, Linear,
Asana, Monday, Jira, Slack/Discord/Teams/Element/Zulip, Obsidian/Logseq/Joplin (first-party), Godot,
Unity, Bitwarden, Anki, Home Assistant, Jellyfin, FreeCAD, KiCad, ArgoCD, k9s, Swagger UI.

#### First-party product themes (Wireshark, Insomnia, and more)

Including the oldest app-level CVD theme found anywhere (Jenkins, 2012).

**Wireshark** ships **Protanopia & Deuteranopia** and **Tritan** themes (dark + light) — Okabe-Ito/Wong
verbatim, gated by `test/suite_theme.py` which checks every token stays distinguishable under each
listed deficiency. The first major network-analysis tool with first-party CVD themes.
([themes dir](https://github.com/wireshark/wireshark/tree/main/resources/themes), GPL-2.0)

![Wireshark colorblind dark](assets/colorblind-themes/wireshark-dark-editor.png)

![Wireshark colorblind dark strip](assets/colorblind-themes/wireshark-dark-strip.png)

![Wireshark colorblind light](assets/colorblind-themes/wireshark-light-editor.png)

![Wireshark colorblind light strip](assets/colorblind-themes/wireshark-light-strip.png)

**Insomnia** (Kong) shipped a **Dark Colorblind core theme** in 2021 ([PR #4081](https://github.com/Kong/insomnia/pull/4081)) —
days after GitHub's own colorblind beta, and the only API client with a first-party CVD theme.
HTTP-method colors swap to blue/orange: POST/200 `#0080FF`, DELETE `#CC5500` (burnt orange).

![Insomnia Dark Colorblind](assets/colorblind-themes/insomnia-dark-editor.png)

![Insomnia Dark Colorblind strip](assets/colorblind-themes/insomnia-dark-strip.png)

**Kiro** ships a built-in "Color-blind safe" theme pair (dark+light) with a simulation test that
measures every status pair under all three dichromacies; Okabe-Ito status hues.
([PR #24480](https://github.com/kirodotdev/KiroCrew/pull/24480))

![Kiro colorblind dark](assets/colorblind-themes/kiro-dark-editor.png)

![Kiro colorblind strip](assets/colorblind-themes/kiro-dark-strip.png)

![Kiro colorblind light](assets/colorblind-themes/kiro-light-editor.png)

![Kiro colorblind light strip](assets/colorblind-themes/kiro-light-strip.png)

**Google's gemini-cli** ships `github-dark-colorblind` / `github-light-colorblind` built-ins — Primer
colorblind tokens verbatim in a Google first-party CLI.
([PR #15504](https://github.com/google-gemini/gemini-cli/pull/15504), Apache-2.0)

![Gemini CLI colorblind dark](assets/colorblind-themes/gemini-cli-dark-editor.png)

![Gemini CLI colorblind strip](assets/colorblind-themes/gemini-cli-dark-strip.png)

![Gemini CLI colorblind light](assets/colorblind-themes/gemini-cli-light-editor.png)

![Gemini CLI colorblind light strip](assets/colorblind-themes/gemini-cli-light-strip.png)

More product themes:

| Product | What shipped | Merge | Notes | Link |
|---|---|---|---|---|
| **Combodo iTop** | Fullmoon Protanopia/Deuteranopia + Tritanopia backoffice themes (first ITSM/CMDB) | 2024-04 [PR #639](https://github.com/Combodo/iTop/pull/639) | danger→orange, success→blue semantic remap | [repo](https://github.com/Combodo/iTop) |
| **narmi/design_system** | `cvd-red-green` + `cvd-tritanopia` token modes — **first banking design system** | 2026-08 [PR #2246](https://github.com/narmi/design_system/pull/2246) | design-token-level CVD modes | [repo](https://github.com/narmi/design_system) |
| **AREDN** firmware | color-blind CSS theme for mesh-radio UI (first embedded/network) | 2024-08 [PR #1418](https://github.com/aredn/aredn/pull/1418) | positive/negative → blue `#3994fd`/amber `#bb8b00` | [repo](https://github.com/aredn/aredn) |
| **Moira** alerting | ColorBlind theme toggle + icon redundancy | 2026-06 [PR #668](https://github.com/moira-alert/web2.0/pull/668) | OK `#00771e`, ERROR `#ff5722`, hue+icon | [repo](https://github.com/moira-alert/web2.0) |
| **Jenkins Wall Display** | `.colorblind` theme — **oldest app-level CVD theme found (2012)** | 2012-02 [PR #3](https://github.com/jenkinsci/walldisplay-plugin/pull/3) | blue `#BFD4FF` / red `#FF9180` / yellow `#FFF780` on white | [repo](https://github.com/jenkinsci/walldisplay-plugin) |
| **Warp** | Zenburn Colorblind (+ High Contrast) — closes the Warp gap | 2026-05 [PR #151](https://github.com/warpdotdev/themes/pull/151) | red `#ff7070`, blue `#70b3ff` | [repo](https://github.com/warpdotdev/themes) |
| **novelWriter** | `today_deuteranopia` + `today_tritanopia` — **uses simulated hues as the theme** | 2026-03 [PR #2694](https://github.com/saga-soft/novelWriter/pull/2694) | red→`#757500` (its deutan-simulated value) | [repo](https://github.com/saga-soft/novelWriter) |
| **Blockly / code.org** | `theme-deuteranopia` + `theme-tritanopia` block themes (2019; code.org trio 2023) — education | 2019-10 [PR #3322](https://github.com/RaspberryPiFoundation/blockly/pull/3322) | world's most-deployed educational block editor | [repo](https://github.com/RaspberryPiFoundation/blockly) |
| **accessible-pygments** | `github_dark/light_colorblind` + `blinds_dark/light` Pygments styles — fills the **doc-site highlighting** layer (Sphinx/Jupyter/MkDocs) | active 2026 | Quansight, BSD-3 | [repo](https://github.com/Quansight-Labs/accessible-pygments) |
| **Actual Budget** | "Color-blind (Dark)" Okabe-Ito theme in the official catalog — **first personal-finance app** | 2026-01 [PR #6696](https://github.com/actualbudget/actual/pull/6696) | Okabe-Ito verbatim | [repo](https://github.com/actualbudget/actual) |
| **GitKraken (kepler)** | "Blue Is the New Green" first-party theme; success→blue, danger→vermilion | 2026-10 [PR #8](https://github.com/gitkraken/kepler-themes/pull/8) | OKLCH tokens, statuses differ in lightness too | [repo](https://github.com/gitkraken/kepler-themes) |
| **heatherfield.nvim** | lightness-separated Neovim theme, no red/green pair | 2025 | blue/pink-heavy | [repo](https://github.com/egerhether/heatherfield.nvim) |
| **Oritone** | Okabe-Ito-derived multi-target theme + 6 scientific colormaps (Helix/Ghostty/Claude Code/Codex) | 2026 | dark+light | [repo](https://github.com/schmaeke/oritone) |
| **icingaweb2-theme-colourblind** | Icinga Web 2 monitoring theme — oldest monitoring entry (2017) | 2017 | deuteran/protan/tritan | [repo](https://github.com/sol1/icingaweb2-theme-colourblind) |
| **github-colorblind-theme** | Stylus/userstyle for github.com (Tol/IBM palette) — **userstyles category filled** | 2020 | `#648FFF #785EF0 #DC267F…` | [repo](https://github.com/nataquinones/github-colorblind-theme) |
| **Blender (GitHub port)** | GitHub Dark Colorblind ported to Blender 4 — creative-app category's lone entry | 2025 | Primer tokens in Blender XML | [repo](https://github.com/treviasxk/BlenderThemeGithub) |
| **MeshMonitor** | Color-blind-friendly themes split **per red / green / blue color blindness** (protan/deutan/tritan) in the built-in gallery — a Meshtastic mesh-network monitor | active 2026 | themes are user/DB-defined (screenshots confirm); palette not in static source | [gallery](https://meshmonitor.org/THEME_GALLERY.html) · [repo](https://github.com/Yeraze/meshmonitor) |
| **godhuli-theme** (VS Code) | CVD-**tested** theme — changelog: functions/methods/built-ins separated by lightness because they were "indistinguishable under CVD simulation" | active 2026 | CVD-tested, not CVD-designed; lightness-channel approach | [marketplace](https://marketplace.visualstudio.com/items?itemName=NotifyX.godhuli-theme) |

**Verified empty surfaces** (checked and confirmed to have no CVD theme): spicetify/Spotify,
btop/htop/glances, waybar/polybar/i3/sway, database GUIs (pgAdmin/DBeaver/phpMyAdmin), Postman/
Hoppscotch/Bruno, e-readers (Zathura/KOReader/calibre/Sumatra), email clients (Thunderbird/Mutt),
TradingView/finance terminals, Android launchers, GIMP/Krita/darktable. The Wordle-clone long tail
(dozens of near-identical student clones) is excluded as noise.

### Pitaya Smoothie — the only CVD-designed JupyterLab theme

Tania Allard / Quansight Labs
([jupyterlab-accessible-themes](https://github.com/Quansight-Labs/jupyterlab-accessible-themes),
upstream [trallard/pitaya_smoothie](https://github.com/trallard/pitaya_smoothie), BSD-3). "The
colour choices… were made taking into consideration accessibility for those with colourblindness —
by default the theme is suitable for multiple types of colourblindness, no settings tweaking
required." The README embeds protanopia/deuteranopia/tritanopia simulations and a WCAG AAA contrast
grid. Teal/pink axis with yellow warnings: brand teal `#1abec2`, accent pink `#f25a92`, warn
yellow `#fad000`, periwinkle `#7998f2`, lilac `#a56cf5`, orange `#f38672`, bg indigo `#181036`.
Dark only; uses the Atkinson Hyperlegible font.

![Pitaya Smoothie editor mock](assets/colorblind-themes/pitaya-dark-editor.png)

![Pitaya Smoothie CVD strip](assets/colorblind-themes/pitaya-dark-strip.png)

(Also in the Jupyter ecosystem: [`jupyterlab_colorblind`](https://github.com/mattwigway/jupyterlab_colorblind)
is a Machado-2009 **simulator** extension for previewing your own plots under CVD — tooling, not a theme.)

### Lx Deep Sea — a KDE Plasma color scheme for red-green CVD

lx21, 2022 ([store.kde.org/p/1711107](https://store.kde.org/p/1711107), GPLv3). The only CVD-labelled
Plasma color scheme found; the store front is bot-walled but the raw `.colors` file was fetched via
the OCS API. Author's claim: "high contrasts and at the same time eyefriendly and suitable for
red-green colorblindness." Dark; blue-tinted neutrals, blue links `#508ED8`, neutral `#55AAFF`.

![Lx Deep Sea editor mock](assets/colorblind-themes/lxdeepsea-dark-editor.png)

![Lx Deep Sea CVD strip](assets/colorblind-themes/lxdeepsea-dark-strip.png)

Honest caveat: its Negative `#FF1B13` (pure red) vs Positive `#57CF1F` (green) still differ mainly
by hue — the simulation strip shows them collapsing toward each other under deuteranopia/protanopia.
It leans on brightness/saturation separation rather than the orange↔blue hue remap the stronger
entries use. Included as the sole KDE desktop entry, with that limitation noted.

### Slack, Discord, Teams

- **Slack:** Opo ships the only published Slack CVD palette — a custom-theme import string
  (`#fbf8f2, #005ccc, #002c85, #a75000…`) built from its build-time-CVD-checked blue/orange axis
  ([`dist/slack/opo-light.txt`](https://github.com/IschaGast/opo-theme)). Slack's own "accessible
  theme" still publishes no hexes.
- **Discord:** [dalton-discord](https://github.com/lissarubi/dalton-discord) (MIT) claims Deutan
  intent with a blue `#2b7df0` accent — but its presence dots keep hard `#00FF00`/`#FF0000`, the
  canonical deutan confusion pair. Medium evidence; self-defeating status colors.
- **Teams:** genuine negative — no user theme format with published palettes; only an unpublished
  "high contrast" mode.

### The OS-level reality: filters, not themes

**No operating system ships a built-in CVD color scheme.** KDE (Breeze ships Classic/Dark/Light
only), GNOME (Adwaita + high-contrast only), and Windows (four high-contrast presets) all rely on
screen-level **daltonization/color-correction filters** instead:

- **KDE Plasma 6** — KWin "Color Blindness Correction" compositor effect (protan/deutan/tritan +
  monochrome), a real-time LMS-space daltonization shader applied to *everything* on screen.
  [docs](https://docs.kde.org/stable_kf6/en/plasma-desktop/kcontrol/kcmaccess/index.html) ·
  [source](https://github.com/KDE/kwin/tree/master/src/plugins/colorblindnesscorrection)
- **GNOME** — third-party "Colorblind Filters" shell extension (screen shader).
- **Windows 10/11** — Color Filters (protanopia/deuteranopia/tritanopia correction).
- **macOS/iOS** — Color Filters in Accessibility settings.

These correct the whole display rather than re-theming any app, which is why per-app CVD themes
(everything above) remain necessary: a global filter can't fix a palette that was never designed
to survive it, and it shifts *all* colors including the ones already safe.

---

## Data-visualization & scientific palettes

This is where the science lives. Editor themes borrow from these.

### Okabe–Ito "Color Universal Design" (2008) — the canonical palette

Masataka Okabe & Kei Ito — **both strong protanopes themselves** — via the NPO
[CUDO](https://cudo.jp/?page_id=1936) they co-founded in 2004
([palette page](https://jfly.uni-koeln.de/color/), [colorset](https://jfly.uni-koeln.de/colorset/)).
Designed to be unambiguous under **all three** dichromacies: no yellow-green range, bluish-green for
"green", vermilion instead of pure red (dark red ≈ black for protanopes). Ships as base R ≥4.0's
`palette.colors("Okabe-Ito")`, underlies seaborn's default, and inspired datum, Blinds, and half the
editor themes above. Free with attribution.

![Okabe-Ito palette under CVD simulation](assets/colorblind-themes/dataviz-okabe-ito.png)

Designed for white backgrounds (print); the pure yellow `#F0E442` is nearly invisible on white —
base R substitutes amber `#F5C710` in its default variant. Not a dark-mode palette.

### Paul Tol's colour schemes (SRON) — the most complete family

[Paul Tol, SRON](https://sronpersonalpages.nl/~pault) — technical note SRON/EPS/TN/09-002 (issue
3.2, 2021). ~16 schemes (qualitative, diverging, sequential), each tested against protanopia and
deuteranopia simulations using CIEDE2000 differences, with the simulations published on the page.
Highlights:

![Tol bright](assets/colorblind-themes/dataviz-tol-bright.png)

![Tol vibrant](assets/colorblind-themes/dataviz-tol-vibrant.png)

![Tol muted](assets/colorblind-themes/dataviz-tol-muted.png)

![Tol high-contrast](assets/colorblind-themes/dataviz-tol-high-contrast.png)

Also: `medium-contrast` (pairs survive grayscale), `dark` (every color ≥4.5:1 on white — the one to
use when WCAG text contrast matters), `pale`/`light` (fills behind black text), diverging `sunset`,
`nightfall`, `BuRd`, `PRGn`, sequential `YlOrBr`, `iridescent`, `incandescent`, and discrete/smooth
rainbows ("reasonably colour-blind safe" — the author grades his own claims). Full hexes in
`.research/02-dataviz.md`.

### Wong 2011 (Nature Methods)

Bang Wong, ["Points of view: Color blindness"](https://www.nature.com/articles/nmeth.1618), Nat.
Methods 8:441 (DOI 10.1038/nmeth.1618). The figure-2 palette is numerically identical to
Okabe–Ito — this paper is why the life-sciences call it the "Wong palette". 360+ citations.

### IBM: v1 colorblind-safe palette & Carbon data-viz

- **IDL v1 5-color set** (`#648FFF #785EF0 #DC267F #FE6100 #FFB000`) — the widely-quoted IBM
  colorblind-safe palette; the original page is archived but the values are corroborated in Nichols'
  tool and Lospec's catalog of the v1 token names.
- **Carbon Design System** ([data-viz color palettes](https://www.carbondesignsystem.com/data-visualization/color-palettes),
  Apache-2.0) — current, actively maintained; 14-color categorical sequence curated to maximize
  neighbor contrast, monochromatic sequential ramps used inverted on dark themes, theme-agnostic
  diverging ramps. **Explicitly supports light and dark.**

![IBM v1 colorblind-safe](assets/colorblind-themes/dataviz-ibm-v1.png)

![IBM Carbon categorical](assets/colorblind-themes/dataviz-carbon-categorical.png)

### cividis (2018) — uniform *under CVD simulation itself*

[Nuñez, Anderton & Renslow, PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0199239)
(DOI 10.1371/journal.pone.0199239). Optimized in CAM02-UCS so the map is perceptually linear **for
normal and CVD-simulated vision alike** — a deuteranope reads the same data values as anyone else.
In matplotlib since 2.2.2; also R, Bokeh, Plotly.

![cividis endpoints under CVD simulation](assets/colorblind-themes/dataviz-cividis.png)

Note how little the five sampled stops move across the simulation rows. That invariance is the point.

### viridis family (2015) — perceptual uniformity + monotonic luminance

[van der Walt & Smith](https://bids.github.io/colormap) (SciPy 2015), matplotlib's default since 2.0;
[R viridisLite](https://sjmgarnier.github.io/viridis). Genuinely CVD-safe by design requirement
(monotonic luminance degrades gracefully), with the caveat that its uniformity is computed for normal
vision — cividis exists precisely to close that gap. viridis / magma / inferno / plasma all qualify.

![viridis endpoints under CVD simulation](assets/colorblind-themes/dataviz-viridis.png)

### seaborn "colorblind" & matplotlib "tableau-colorblind10"

- `sns.color_palette("colorblind")` (seaborn's **default**) is a lightened Okabe–Ito variant plus
  tan, pink, grey — [source](https://github.com/mwaskom/seaborn/blob/master/seaborn/palettes.py).
- `plt.style.use('tableau-colorblind10')` ships Tableau's color-blind 10 —
  [source](https://github.com/matplotlib/matplotlib/blob/main/lib/matplotlib/mpl-data/stylelib/tableau-colorblind10.mplstyle);
  blue/orange-led with graded lightness so the grey pairs stay separable.

![seaborn colorblind](assets/colorblind-themes/dataviz-seaborn-colorblind.png)

![tableau-colorblind10](assets/colorblind-themes/dataviz-tableau-colorblind10.png)

### Petroff accessible color cycles (2021) — in matplotlib as built-in styles

Matthew A. Petroff, ["Accessible Color Sequences for Data Visualization"](https://arxiv.org/abs/2107.02270)
(arXiv:2107.02270, v3 Feb 2024). Combines a crowdsourced aesthetic-preference survey with CAM02-UCS
and CVD simulation to generate 6/8/10-color cycles that are **both accessible and aesthetic** —
evaluated under all three dichromacies. Ships in matplotlib as the built-in styles `petroff6`,
`petroff8`, `petroff10`; code at [mpetroff/accessible-color-cycles](https://github.com/mpetroff/accessible-color-cycles) (MIT).

![Petroff 6 under CVD simulation](assets/colorblind-themes/dataviz-petroff6.png)

![Petroff 10 under CVD simulation](assets/colorblind-themes/dataviz-petroff10.png)

### Qualpal (2025) — the newest peer-reviewed CVD palette generator

Johan Larsson, ["Qualpal: Qualitative Color Palettes for Everyone"](https://joss.theoj.org/papers/10.21105/joss.08936),
*Journal of Open Source Software* (DOI 10.21105/joss.08936, Oct 2025). Where Okabe–Ito and Tol ship
fixed N-color sets, Qualpal **generates** palettes for arbitrary N by maximizing pairwise CIEDE2000
distance — with optional CVD simulation (deuteranopia/protanopia/tritanopia, severity-adjustable)
built into the objective, so palettes are distinct *for CVD viewers*, not merely checked afterward.
C++ library + CLI, R package [qualpalr](https://cran.r-project.org/package=qualpalr) (GPL-3), Python
`qualpal`, and a web app at [qualpal.cc](https://qualpal.cc). GPL-3.

### Plotly, Bokeh & CARTO — a verified CVD-safe qualitative palette

Both ship a verified CVD-safe palette:

- **Plotly `Safe`** — `px.colors.qualitative.Safe` is the **CARTOColors "Safe"** scheme, tagged
  `["qualitative","colorblind"]` in [CARTO's source](https://github.com/CartoDB/CartoColor/blob/master/src/carto.ts).
  It is essentially **Paul Tol's "muted" scheme reordered** (plus `#661100` at size 10–11). Verified
  in [`_plotly_utils/colors/carto.py`](https://raw.githubusercontent.com/plotly/plotly.py/main/_plotly_utils/colors/carto.py).
  The default `Plotly` 10-color cycle is **not** CVD-safe.
- **Bokeh `Colorblind`** — `Colorblind8` in [`bokeh/palettes.py`](https://github.com/bokeh/bokeh/blob/main/src/bokeh/palettes.py)
  is Okabe–Ito reordered (blue first), plus Tol's `Bright`/`HighContrast`/`Vibrant`/`Muted` groups.

![Plotly Safe (CARTO / Tol muted) under CVD simulation](assets/colorblind-themes/dataviz-plotly-safe.png)

![Bokeh Colorblind8 (Okabe–Ito) under CVD simulation](assets/colorblind-themes/dataviz-bokeh-colorblind.png)

### ggpubfigs / pypubfigs — journal-published, actively maintained

Steenwyk & Rokas, [*Microbiology Resource Announcements* 2021](https://journals.asm.org/doi/10.1128/MRA.00871-21)
(DOI 10.1128/MRA.00871-21); [R](https://github.com/JLSteenwyk/ggpubfigs) and
[Python](https://github.com/JLSteenwyk/pypubfigs) (MIT, updated through 2026-02). A curated,
publication-oriented bundle re-exporting the canonical CVD sets (Tol bright/muted/vibrant/high-contrast,
Okabe–Ito `ito_seven`, Wong `wong_eight`, IBM `ibm_five`) plus two claimed-CVD-safe originals,
`zesty_four` and `retro_four`:

![ggpubfigs zesty_four](assets/colorblind-themes/dataviz-zesty-four.png)

![ggpubfigs retro_four](assets/colorblind-themes/dataviz-retro-four.png)

**Correction:** their `tableau_ten` is the stock Tableau 10 (`#4E79A7 #F28E2B …`), which is **not**
the Tableau Color Blind 10 and is not CVD-verified — don't confuse the two.

### Palette generators and checkers (produce or verify CVD-safe palettes)

| Tool | What it does | CVD-aware? | Link |
|---|---|---|---|
| **Qualpal** | generates N-color qualitative palettes maximizing CIEDE2000 | yes — simulation in the objective | [qualpal.cc](https://qualpal.cc) |
| **distinctipy** | N maximally-distinct colors; `colorblind_type` simulates all CVD types and maximizes distance *in simulated space* | yes | [repo](https://github.com/alan-turing-institute/distinctipy) |
| **colorblindcheck** (R) | checks any palette against deutan/protan/tritan simulations, reports min pairwise distance | yes (checker) | [repo](https://github.com/Nowosad/colorblindcheck) |
| **iWantHue** | web palette generator with an explicit "Improve for the colorblind" refinement | yes | [medialab.github.io/iwanthue](https://medialab.github.io/iwanthue) |
| **tol-colors** (Python) | the de-facto Python port of all Paul Tol schemes | inherits Tol | [repo](https://github.com/Descanonge/tol_colors) |
| **cvdmaps** (2026) | one-call Okabe–Ito matplotlib cycle + `cvdsafe` checker (Machado + CIEDE2000) | yes | [opticquiz.com](https://opticquiz.com) |
| **LaTeX `colorblind` package** | Tol's schemes for LaTeX documents with CVD-safe defaults | inherits Tol | [CTAN](https://www.ctan.org/pkg/colorblind) |
| Glasbey / Colorgorical | distinctness-maximizing generators | no CVD simulation — flagged | — |

**R ecosystem wrappers** (Okabe–Ito made easy): base R ≥4.0 `palette.colors("Okabe-Ito")`,
[see](https://github.com/easystats/see/blob/main/R/scale_color_okabeito.R) `scale_color_okabeito()`,
[ggokabeito](https://cran.r-project.org/package=ggokabeito), [ggthemes](https://jrnold.github.io/ggthemes/reference/colorblind.html)
`scale_colour_colorblind()`, and [rcartocolor](https://jakubnowosad.com/rcartocolor) `scale_color_carto_d()`
for the CARTO `Safe` scheme. The canonical citation for base R's CVD story is Zeileis, Murrell et al.,
["Coloring in R's Blind Spot"](https://journal.r-project.org/articles/RJ-2023-071), *The R Journal* 15(1), 2023.

**2023–2026 institutional endorsements:** the Cherenkov Telescope Array Observatory's
[ColourBlind Friendly Practices v2](https://www.ctao.org/wp-content/uploads/ColourBlindFriendlyPractices_v2_032025.pdf)
(March 2025) recommends Okabe–Ito/Tol/viridis-class maps; Argonne National Lab published
[CVD-aware radar colormaps](https://www.anl.gov/evs/article/effective-visualization-of-radar-data-for-users-impacted-by-color-vision-deficiency)
(2024); Zhou et al., ["Navigating color integrity in data visualization"](https://www.sciencedirect.com/science/article/pii/S2666389924000801)
(*Patterns*, 2024) surveys accessible palettes.

### ColorBrewer's colorblind-safe flag (1999–2002) — the first mainstream tool

[colorbrewer2.org](https://colorbrewer2.org/) (Cynthia Brewer) was the first widely used tool to tag
schemes "colorblind safe". Verified flag list from RColorBrewer source: diverging **BrBG, PiYG, PRGn,
PuOr, RdBu, RdYlBu**; qualitative **Dark2, Paired, Set2**; **all 18 sequential** schemes. Not flagged:
RdGy, RdYlGn, Spectral, Accent, Pastel1/2, Set1, Set3.

![ColorBrewer Set2](assets/colorblind-themes/dataviz-colorbrewer-set2.png)

### Fabio Crameri's Scientific colour maps (2018–2023)

[fabiocrameri.ch/colourmaps](https://www.fabiocrameri.ch/colourmaps) — every map marked
"Colour-vision-deficiency friendly" and grayscale-readable (perceptually uniform, ordered lightness;
[Kovesi](https://arxiv.org/abs/1509.03700) diagnostics). **batlow** is the flagship "scientific
rainbow"; W/K variants (white-/black-ended) make the suite unusually good on both backgrounds.
Companion manifesto: [Crameri, Shephard & Heron 2020, *The misuse of colour in science
communication*](https://www.nature.com/articles/s41467-020-19160-7) (Nat. Comms, DOI
10.1038/s41467-020-19160-7). MIT; available via Zenodo, cmasher, GMT ≥6.0, R `scico`/`khroma`.

![batlow endpoints under CVD simulation](assets/colorblind-themes/dataviz-crameri-batlow.png)

### David Nichols — Coloring for Colorblindness

[davidmathlogic.com/colorblind](https://davidmathlogic.com/colorblind) — interactive checker that
renders any palette under protanopia, deuteranopia, tritanopia, and monochrome. His recommended
4-color default and 8 pre-verified safe **pairs** (e.g. `#1A85FF`/`#D41159`):

![Nichols default 4](assets/colorblind-themes/dataviz-nichols-default.png)

### Krzywinski's 15-color palette

Martin Krzywinski's [mkweb.bcgsc.ca/biovis2012](http://mkweb.bcgsc.ca/biovis2012/) 15-color set,
preserved in the CRAN [colorBlindness](https://cran.r-project.org/web/packages/colorBlindness/vignettes/colorBlindness.html)
package as `paletteMartin`:

![Krzywinski 15-color palette](assets/colorblind-themes/dataviz-krzywinski-15.png)

### R packages collecting the above

- [**khroma**](https://packages.tesselle.org/khroma) (Tesselle, GPL-3) — Okabe–Ito + Tol + Crameri
  implementations with built-in CVD-simulation diagnostics (`plot_scheme_colorblind()`).
- [**colorBlindness**](https://cran.r-project.org/web/packages/colorBlindness/vignettes/colorBlindness.html)
  (Jianhong Ou, GPL≥2) — Wong/Okabe–Ito `safeColors`, Krzywinski's 15, heatmap diverging ramps, and
  a Viénot–Brettel–Mollon simulator (`cvdPlot()`).

---

## Timeline

| Year | Milestone |
|---|---|
| 1997 | Brettel–Viénot–Mollon dichromat simulation model (basis of Vischeck) |
| 1999–2002 | ColorBrewer introduces "colorblind safe" flags — first mainstream CVD tagging |
| 2002 | Okabe & Ito publish the Color Universal Design page |
| 2004 | CUDO founded in Tokyo |
| 2006 | JIS X 8341-5 requires color-vision consideration on office equipment (→ ISO/IEC 10779, 2008) |
| 2008 | Okabe–Ito 8-color palette paper; Adobe CS4 ships CUD soft-proofing worldwide |
| 2009 | Machado et al. physiologically-based simulation (IEEE TVCG) — the standard model |
| 2009 | Paul Tol's SRON schemes, first issue (3.2 in 2021) |
| 2011 | Wong's Nature Methods column spreads Okabe–Ito through the life sciences |
| 2012 | **Jenkins Wall Display `.colorblind` theme — oldest app-level CVD theme found** |
| 2015 | viridis becomes matplotlib's default (2.0) |
| 2018 | cividis (PLOS ONE); Crameri's Scientific colour maps begin |
| 2019 | Ultimaker Cura Colorblind Assist themes; Blockly deuteranopia/tritanopia block themes (education) |
| 2020 | Crameri et al., *The misuse of colour in science communication* (Nat. Comms) |
| 2021 | GitHub ships colorblind themes beta to all users (Sep); DaltonLens reviews open-source sim models; **Petroff accessible cycles** (arXiv:2107.02270); **Insomnia ships Dark Colorblind (first API client)** |
| 2022 | GitHub splits Protanopia & Deuteranopia / Tritanopia theme variants (Apr) |
| 2023 | Helix ships GitHub-CB + modus CVD themes in its runtime; Zeileis et al., *"Coloring in R's Blind Spot"* (R Journal) documents base R's CVD redesign |
| 2024 | LaTeX `colorblind` package (Tol schemes for documents); Argonne CVD radar colormaps; matplotlib ships `petroff6/8/10` styles |
| 2025 | **Qualpal** (JOSS) — generative CVD palette optimization; CTAO institutional best-practices; Shroom Space's CI-enforced CVD variants |
| 2026 | datum, Opo (363 contrast checks), Slatis Nyx, orca-themes (quantified CIEDE2000), ColorSafe, Cindervale, Hakimi, first GitLab CVD skin, first Xcode CVD theme; WezTerm ships 7 CVD schemes built-in; first JupyterLab CVD theme (Pitaya Smoothie); **app-level: Grafana, coder, Kilocode, Daintree ship first-party CVD themes** |

## Simulation & validation tools

| Tool | What it does | Link |
|---|---|---|
| Coblis / Coblis2 | web image simulator, all CVD types (Machado 2009) | [color-blindness.com/coblis](https://www.color-blindness.com/coblis/coblis.html) |
| Firefox DevTools | Accessibility Inspector → live page CVD simulation | [docs](https://firefox-source-docs.mozilla.org/devtools-user/accessibility_inspector/simulation/index.html) |
| Chromium DevTools | Rendering → "Emulate vision deficiencies" | [docs](https://developer.chrome.com/docs/devtools/accessibility/reference/) |
| Sim Daltonism | macOS/iOS real-time screen/camera filter | [michelf.ca](https://michelf.ca/projects/sim-daltonism) |
| Color Oracle | full-screen simulator, Win/Mac/Linux | [colororacle.org](https://colororacle.org/) |
| whocanuse.com | fg/bg pair → WCAG grade + 13 vision-type simulations | [whocanuse.com](https://www.whocanuse.com/) |
| Viz Palette | palette-level simulation + name-confusion report | [projects.susielu.com/viz-palette](https://projects.susielu.com/viz-palette) |
| Adobe PS/AI | View → Proof Setup → Color Blindness (since CS4, 2008, with CUDO) | [jfly colorset §7](https://jfly.uni-koeln.de/colorset/) |
| DaltonLens | accuracy review of open-source simulation models | [daltonlens.org](https://daltonlens.org/opensource-cvd-simulation) |
| Colorblindly | Chrome extension simulator (no palettes shipped) | [repo](https://github.com/oftheheadland/Colorblindly) |

## Standards & guidance

- **WCAG 2.x**: no CVD-specific criterion; SC 1.4.1 (color not sole carrier) and contrast minimums
  are the operative rules — [Understanding 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html).
- **JIS X 8341 series** (Japan): 8341-5 mandates color-vision consideration for buttons/screens/lamps;
  parts internationalized as ISO/IEC 10779 — [NICT overview](https://www.nict.go.jp/info-barrierfree/jis/outline/index.html).
- **JPMA paint standard** (2011 F) embeds the CUD recommended color set in Japan's paint industry.
- **Japan Barrier-Free Law (2007)** guidelines: color-vision-aware signage in transit and public facilities.
- No general ISO standard mandates a specific CVD palette.
- Guidance worth reading: Urban Institute's [*Do No Harm Guide*](https://www.urban.org/sites/default/files/2022-12/Do%20No%20Harm%20Guide%20Centering%20Accessibility%20in%20Data%20Visualization.pdf)
  (2022) and [data-viz style guide](https://urbaninstitute.github.io/graphics-styleguide/) (Schwabish et al.);
  [Katsnelson 2021, *Colour me better*](https://media.nature.com/original/magazine-assets/d41586-021-02696-z/d41586-021-02696-z.pdf) (Nature news feature).

## Not included, and why

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

## Verification

The catalog above records what themes claim. This section tests it.

### How the test works

For every catalogued theme we take its **signal colors** — the small set that carries meaning
(success/error/warning, diff add/delete, syntax roles) — and run two computations:

1. **Simulate** each color under each dichromacy (deuteranopia, protanopia, tritanopia) using the
   Machado, Oliveira & Fernandes (2009) physiologically-based model at 100% severity — the same
   model behind Coblis and most modern simulators. This produces what each color actually looks like
   to a viewer with that deficiency.
2. **Measure** the closest pair among those simulated colors using **CIEDE2000 (ΔE00)**, the standard
   perceptual color-distance metric. The minimum pairwise distance is the theme's worst case: the
   two signals most likely to be confused.

### How to read the numbers

ΔE00 is roughly: **~1** = a just-noticeable difference under ideal lab conditions; **<3** = two
colors most people will struggle to tell apart on a real screen; **>8** = clearly different at a
glance. A theme is only as strong as its weakest pair.

**Verdict scale** (a heuristic, not pass/fail):

- **STRONG** — closest pair ≥ 8 ΔE00 under all three dichromacies. Robust for any viewer.
- **ok** — closest pair ≥ 3. Usable, but the closest pair is a known tight spot.
- **WEAK** — closest pair < 3 under at least one deficiency. Some pair collapses on hue+lightness.

Reproduce every number below: `python3 scripts/verify_colorblind_themes.py` (stdlib only,
deterministic — it reads the same hex tables that generate the examples).

| Tier | Themes (mode) |
|---|---|
| **STRONG** (robust across all three) | Kiro (dark+light), Wireshark (dark+light), Cindervale (dark), Insomnia (dark), Blinds (dark), Opo (light) |
| **ok** (no pair fully collapses) | datum (both), Dalton (both), Dichromatic, Gentle (dark), Monokai Deuteranopia, Pitaya, Blinds (light), Opo (dark), Pierre (light), Lx Deep Sea, Color Blind Themes, ef-themes (light), One Dark Pro, Hakimi (dark), dracula-colorblind |
| **WEAK** (a pair collapses for ≥1 deficiency) | GitHub/Gemini (both modes), Grafana (both), coder (dark), modus-deuteranopia (both), Pierre (dark), vision.nvim, morimo, Gentle (light), ef-themes (dark), Hakimi (light), ColorSafe, Shroom Space |

**See the difference, don't just read it.** Each plate below shows a STRONG theme against a WEAK
theme under one simulated dichromacy — Normal row, then the CVD view. The WEAK pair's two chips
collapse to near-identical tones; the STRONG pair stays apart.

![Deuteranopia: GitButler (strong) vs GitHub (weak)](assets/colorblind-themes/compare-deuteranopia.png)

Under deuteranopia, GitHub's keyword `#ec8e2c` and warning `#d29922` become `#C1AD2D` and `#BDA928`
— 7.5 RGB units apart, effectively one color. GitButler's addition `#99d9ff` and deletion `#ffbf66`
stay 156 units apart.

![Protanopia: Wireshark (strong) vs coder (weak)](assets/colorblind-themes/compare-protanopia.png)

![Tritanopia: Kiro (strong) vs Gentle light (weak)](assets/colorblind-themes/compare-tritanopia.png)

**Read this table honestly — three caveats:**

1. **A WEAK verdict is not "broken."** Most of these themes deliberately add a *luminance* gap
   between hues that share an axis (GitHub's keyword orange `#ec8e2c` vs. warning amber `#d29922`
   collapse to ΔE≈1.1 in *hue* under deuteranopia, but they're never used as a binary good/bad
   signal). The metric measures hue+lightness collapse; it does not model font weight, icons, or
   the redundant text cues these UIs also provide.
2. **Single-deficiency themes collapse by design under the others.** modus-deuteranopia scoring WEAK
   under deuteranopia looks alarming until you see the weakest pair is red `#ff5f59` vs green
   `#44bc44` — two colors the deuteranopia variant *deliberately stops using as a semantic pair*
   (errors route to a different channel). Judge a theme against the deficiency it targets.
3. **The strongest independent signal is the engineering gate, not the hue choice.** Every STRONG
   entry (Kiro, Wireshark, Cindervale, Opo, Blinds) ships a *test that measures exactly this* and
   fails the build on regression — which is why they top the table. Themes that only *assert* CVD
   safety cluster at the bottom.

The full per-theme numbers (all three deficiencies, weakest pair identified) are the script's
stdout and are reproducible.

**The one-line takeaway:** the themes that *measure* survive; the themes that *claim* often don't.
If you're choosing a theme for a CVD user, prefer one with a simulation/contrast build gate.

### App/platform-level themes verify far better than editor themes

Running the same metric over the app-level signal palettes (the small good/bad/status sets each
product shows) gives a markedly different picture: **11 STRONG, 3 ok, 5 WEAK** — versus the
editor/terminal tier's 8/17/17. Apps only need to separate 2–4 status colors, so they can space
them far apart; editors must cram 6–8 syntax roles into one palette.

| Tier | App-level themes |
|---|---|
| **STRONG** | GitButler (dark ΔE≈45, light ΔE≈61 — near-perfect), Cura, SimpleCov (dark), plannotator (dark), iamb, OpenFront.io, Jenkins Wall Display, deepinv, narmi, Insomnia, Wireshark-tritan |
| **ok** | Talishar deuteranopia + protanopia palettes, Moira |
| **WEAK** | Gitea (both), SimpleCov (light), plannotator (light), Talishar *tritanopia* palette |

Two findings worth naming:

- **Per-deficiency palettes confirmed empirically.** Talishar ships one palette per dichromacy, and
  the numbers show exactly why that's the right call: each palette is strong under its *target*
  deficiency (deutan palette ΔE 17.3 under deuteranopia; protan ΔE 20.2 under protanopia) but
  collapses under the others (tritan palette: 2.6 under deuteranopia). Per-deficiency variants beat
  one "universal" palette — matching what Grafana (4 themes) and modus/ef do.
- **The GitHub orange/amber weakness propagates downstream.** Gitea and SimpleCov inherit GitHub's
  colorblind pair (`#f0883e` orange vs `#d29922`/`#9a6700` amber), and both score WEAK for the same
  reason the flagship does. SimpleCov's *dark* mode dodges it (its missed-orange is far from its
  skipped-yellow); its *light* mode doesn't. When you port a palette, re-measure it.

**GitButler is the strongest CVD palette in this entire report** — its diff addition/deletion text
pair (`#99d9ff`/`#ffbf66` dark, `#0d59bf`/`#bf590d` light) sits ΔE 42–61 apart under every
dichromacy, roughly 5× the "clearly different" threshold. That's what designing the two-color case
from scratch, rather than remapping an existing 8-color palette, buys you.



---

## Reproducing the examples

```bash
python3 scripts/generate_colorblind_theme_examples.py
```

Regenerates all 105 SVGs into `docs/reports/assets/colorblind-themes/` from the hex tables embedded
in the script (each traceable to `.research/0*.md`). Simulation rows: Machado et al. (2009), severity
100%, applied in linear sRGB with gamma re-encoding. Neutrals are invariant by construction; red
shifts toward olive under protanopia and stays nearly fixed under tritanopia — matching Coblis
output for the same inputs.
