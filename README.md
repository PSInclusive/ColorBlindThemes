# ColorBlindThemes

A catalog of color themes and palettes built for color-vision-deficient (CVD) users — with links to primary sources, real hex values, rendered examples in dark and light modes, and a computed test of which palettes actually survive CVD simulation.

**Read the site:** https://psinclusive.github.io/ColorBlindThemes/

## What's here

- `content/` — the site pages (one per theme type, plus an all-themes table)
- `themes/jackfield/` — the Hugo theme (a dark, CVD-legible instrument; state by pattern, never hue)
- `static/assets/colorblind-themes/` — the generated example SVGs (editor mocks + CVD-simulation swatch plates)
- `data/themes.json`, the table data (scores, hexes, links, demo images)
- `scripts/` — the two deterministic generators (examples + verification)

## Develop

Requires [Hugo](https://gohugo.io) (extended).

```powershell
hugo serve            # local dev server with live reload
hugo --destination public   # production build
```

## Regenerate the examples and verification

```powershell
pwsh scripts/New-ColorblindThemeExamples.ps1   # rebuild all SVGs
pwsh scripts/Test-ColorblindThemes.ps1             # recompute the CVD-survival table
```

## Deploy

Pushes to `main` build and deploy to GitHub Pages via `.github/workflows/gh-pages.yml`.

---

Made with 💜 by [Jake Hildreth](https://jakehildreth.com)
