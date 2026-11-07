---
title: "Terminal themes"
lane: "03"
laneName: "Terminals"
slug: "terminals"
weight: 6
---

## Dalton Dark / Dalton Bright (gerchowl)

[repo](https://github.com/gerchowl/dalton-colorscheme), MIT. "A colorblind-friendly terminal color
scheme for deuteranopia and protanopia." Ghostty, iTerm2, lazygit, CSS. 16-color ANSI palettes where
red/green/blue slots are luminance- and hue-separated under both dichromacies. **Dark and light.**

![Dalton dark editor mock](colorblind-themes/dalton-dark-editor.png)

![Dalton dark CVD strip](colorblind-themes/dalton-dark-strip.png)

![Dalton bright editor mock](colorblind-themes/dalton-light-editor.png)

![Dalton bright CVD strip](colorblind-themes/dalton-light-strip.png)

## hakarune/colorblind-terminal-themes

[repo](https://github.com/hakarune/colorblind-terminal-themes), GPL-3.0. A **verified** (not just
designed) collection: ships its own Machado-2009 simulation script (`scripts/cvd_sim.py`) and checks
every theme against protanopia, deuteranopia, and tritanopia. Strategy: replace only the red/green
ANSI slots (red→orange, green→blue), keeping the rest of each upstream palette intact. Covers the
five major terminal stock palettes (GNOME, Konsole, iTerm2 Basic, Windows Terminal Campbell,
Alacritty) plus CVD remixes of Dracula, Nord, Solarized, Tokyo Night, Catppuccin, Gruvbox, and a
repaired dichromatic port (`dichromatic-fixed` fixes a real deuteranopia collision between the
original's color9/color10).

![dracula-colorblind editor mock](colorblind-themes/hakarune-dracula-dark-editor.png)

![dracula-colorblind CVD strip](colorblind-themes/hakarune-dracula-dark-strip.png)

## iTerm2-Color-Schemes CVD entries

[repo](https://github.com/mbadolato/iTerm2-Color-Schemes) (gallery
[iterm2colorschemes.com](https://iterm2colorschemes.com)): ships **GitHub Dark/Light Colorblind**
(converted from Primer), **Modus Operandi/Vivendi Deuteranopia & Tritanopia** ports, and **datum**.
Hexes verified against the `.itermcolors` plists; they match the Primer/Modus sources in the
sections above.

## WezTerm ships 7 CVD schemes built in

WezTerm's [built-in scheme index](https://wezterm.org/colorschemes/data.json)
(1001 schemes synced from iTerm2-Color-Schemes/base16/Gogh) contains exactly **7 CVD-named schemes**,
all from the two Protesilaos Emacs families: `Ef-Deuteranopia-Dark/Light`, `Ef-Tritanopia-Dark/Light`,
and `Modus-Operandi/Vivendi-Deuteranopia`, `Modus-Vivendi-Tritanopia`. WezTerm is therefore one of
the only terminals with first-party CVD schemes out of the box. (`Ef-Deuteranopia-Dark`: bg `#000a1f`,
fg `#ddddee`, red→orange-brown `#cf8560`, cursor `#ffff00`.)

## Microsoft's own deuteranopia scheme

Windows Terminal ships no built-in CVD scheme. But Microsoft's own Windows Terminal **repo** ships
[`deuteranopia.itermcolors`](https://github.com/microsoft/terminal/blob/main/src/tools/ColorTool/schemes/deuteranopia.itermcolors)
in its ColorTool samples (MIT) — an aggressive remap (red→yellow `#999900`, green→blue `#000099`,
bright red→`#ffff00`, bright green→`#0000ff`). Functional, not refined; the blue channel is heavily
reused. It's a sample, not a shipping default — hence the "no built-in" finding stands, but a
Microsoft-authored CVD palette does exist.

## Konsole / Yakuake — no dedicated project, but an import path

No Konsole- or Yakuake-specific CVD theme project exists (store.kde.org is bot-walled). The import
path that works: iTerm2-Color-Schemes' `konsole/` directory ships 7 CVD `.colorscheme` files
(Dalton Dark, GitHub Dark/Light Colorblind, and four Modus variants), which import into Konsole and
Yakuake. And projekt0n's [github-theme-contrib](https://github.com/projekt0n/github-theme-contrib)
publishes four GitHub Colorblind/Tritanopia Konsole schemes (MIT) on the KDE store.

## orca-themes — deuteranopia, quantified

[repo](https://github.com/Sandstorm831/orca-themes) (2026) for the [Orca terminal](https://onorca.dev).
The most measurement-driven terminal entry: every theme is run through full-strength Machado 2009
simulation and scored by **CIEDE2000 red/green gap**, with the numbers published (their GitHub Dark
Colorblind Fixed scores 58; Orca's stock Tango Light scores only 8; "above 20 reads as clearly
different"). Ships `github-dark-colorblind-fixed.yaml` which repairs real defects in GitHub's own
colorblind terminal port (duplicated ANSI blue, red/yellow clash). Dark + light.

---
