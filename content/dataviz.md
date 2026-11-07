---
title: "Data-viz & scientific palettes"
lane: "05a"
laneName: "Data-viz"
slug: "dataviz"
weight: 8
---

This is where the science lives. Editor themes borrow from these.

## Okabe–Ito "Color Universal Design" (2008) — the canonical palette

Masataka Okabe & Kei Ito — **both strong protanopes themselves** — via the NPO
[CUDO](https://cudo.jp/?page_id=1936) they co-founded in 2004
([palette page](https://jfly.uni-koeln.de/color/), [colorset](https://jfly.uni-koeln.de/colorset/)).
Designed to be unambiguous under **all three** dichromacies: no yellow-green range, bluish-green for
"green", vermilion instead of pure red (dark red ≈ black for protanopes). Ships as base R ≥4.0's
`palette.colors("Okabe-Ito")`, underlies seaborn's default, and inspired datum, Blinds, and half the
editor themes above. Free with attribution.

![Okabe-Ito palette under CVD simulation](colorblind-themes/dataviz-okabe-ito.png)

Designed for white backgrounds (print); the pure yellow `#F0E442` is nearly invisible on white —
base R substitutes amber `#F5C710` in its default variant. Not a dark-mode palette.

## Paul Tol's colour schemes (SRON) — the most complete family

[Paul Tol, SRON](https://sronpersonalpages.nl/~pault) — technical note SRON/EPS/TN/09-002 (issue
3.2, 2021). ~16 schemes (qualitative, diverging, sequential), each tested against protanopia and
deuteranopia simulations using CIEDE2000 differences, with the simulations published on the page.
Highlights:

![Tol bright](colorblind-themes/dataviz-tol-bright.png)

![Tol vibrant](colorblind-themes/dataviz-tol-vibrant.png)

![Tol muted](colorblind-themes/dataviz-tol-muted.png)

![Tol high-contrast](colorblind-themes/dataviz-tol-high-contrast.png)

Also: `medium-contrast` (pairs survive grayscale), `dark` (every color ≥4.5:1 on white — the one to
use when WCAG text contrast matters), `pale`/`light` (fills behind black text), diverging `sunset`,
`nightfall`, `BuRd`, `PRGn`, sequential `YlOrBr`, `iridescent`, `incandescent`, and discrete/smooth
rainbows ("reasonably colour-blind safe" — the author grades his own claims). Full hexes in
`.research/02-dataviz.md`.

## Wong 2011 (Nature Methods)

Bang Wong, ["Points of view: Color blindness"](https://www.nature.com/articles/nmeth.1618), Nat.
Methods 8:441 (DOI 10.1038/nmeth.1618). The figure-2 palette is numerically identical to
Okabe–Ito — this paper is why the life-sciences call it the "Wong palette". 360+ citations.

## IBM: v1 colorblind-safe palette & Carbon data-viz

- **IDL v1 5-color set** (`#648FFF #785EF0 #DC267F #FE6100 #FFB000`) — the widely-quoted IBM
  colorblind-safe palette; the original page is archived but the values are corroborated in Nichols'
  tool and Lospec's catalog of the v1 token names.
- **Carbon Design System** ([data-viz color palettes](https://www.carbondesignsystem.com/data-visualization/color-palettes),
  Apache-2.0) — current, actively maintained; 14-color categorical sequence curated to maximize
  neighbor contrast, monochromatic sequential ramps used inverted on dark themes, theme-agnostic
  diverging ramps. **Explicitly supports light and dark.**

![IBM v1 colorblind-safe](colorblind-themes/dataviz-ibm-v1.png)

![IBM Carbon categorical](colorblind-themes/dataviz-carbon-categorical.png)

## cividis (2018) — uniform *under CVD simulation itself*

[Nuñez, Anderton & Renslow, PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0199239)
(DOI 10.1371/journal.pone.0199239). Optimized in CAM02-UCS so the map is perceptually linear **for
normal and CVD-simulated vision alike** — a deuteranope reads the same data values as anyone else.
In matplotlib since 2.2.2; also R, Bokeh, Plotly.

![cividis endpoints under CVD simulation](colorblind-themes/dataviz-cividis.png)

Note how little the five sampled stops move across the simulation rows. That invariance is the point.

## viridis family (2015) — perceptual uniformity + monotonic luminance

[van der Walt & Smith](https://bids.github.io/colormap) (SciPy 2015), matplotlib's default since 2.0;
[R viridisLite](https://sjmgarnier.github.io/viridis). Genuinely CVD-safe by design requirement
(monotonic luminance degrades gracefully), with the caveat that its uniformity is computed for normal
vision — cividis exists precisely to close that gap. viridis / magma / inferno / plasma all qualify.

![viridis endpoints under CVD simulation](colorblind-themes/dataviz-viridis.png)

## seaborn "colorblind" & matplotlib "tableau-colorblind10"

- `sns.color_palette("colorblind")` (seaborn's **default**) is a lightened Okabe–Ito variant plus
  tan, pink, grey — [source](https://github.com/mwaskom/seaborn/blob/master/seaborn/palettes.py).
- `plt.style.use('tableau-colorblind10')` ships Tableau's color-blind 10 —
  [source](https://github.com/matplotlib/matplotlib/blob/main/lib/matplotlib/mpl-data/stylelib/tableau-colorblind10.mplstyle);
  blue/orange-led with graded lightness so the grey pairs stay separable.

![seaborn colorblind](colorblind-themes/dataviz-seaborn-colorblind.png)

![tableau-colorblind10](colorblind-themes/dataviz-tableau-colorblind10.png)

## Petroff accessible color cycles (2021) — in matplotlib as built-in styles

Matthew A. Petroff, ["Accessible Color Sequences for Data Visualization"](https://arxiv.org/abs/2107.02270)
(arXiv:2107.02270, v3 Feb 2024). Combines a crowdsourced aesthetic-preference survey with CAM02-UCS
and CVD simulation to generate 6/8/10-color cycles that are **both accessible and aesthetic** —
evaluated under all three dichromacies. Ships in matplotlib as the built-in styles `petroff6`,
`petroff8`, `petroff10`; code at [mpetroff/accessible-color-cycles](https://github.com/mpetroff/accessible-color-cycles) (MIT).

![Petroff 6 under CVD simulation](colorblind-themes/dataviz-petroff6.png)

![Petroff 10 under CVD simulation](colorblind-themes/dataviz-petroff10.png)

## Qualpal (2025) — the newest peer-reviewed CVD palette generator

Johan Larsson, ["Qualpal: Qualitative Color Palettes for Everyone"](https://joss.theoj.org/papers/10.21105/joss.08936),
*Journal of Open Source Software* (DOI 10.21105/joss.08936, Oct 2025). Where Okabe–Ito and Tol ship
fixed N-color sets, Qualpal **generates** palettes for arbitrary N by maximizing pairwise CIEDE2000
distance — with optional CVD simulation (deuteranopia/protanopia/tritanopia, severity-adjustable)
built into the objective, so palettes are distinct *for CVD viewers*, not merely checked afterward.
C++ library + CLI, R package [qualpalr](https://cran.r-project.org/package=qualpalr) (GPL-3), Python
`qualpal`, and a web app at [qualpal.cc](https://qualpal.cc). GPL-3.

## Plotly, Bokeh & CARTO — a verified CVD-safe qualitative palette

Both ship a verified CVD-safe palette:

- **Plotly `Safe`** — `px.colors.qualitative.Safe` is the **CARTOColors "Safe"** scheme, tagged
  `["qualitative","colorblind"]` in [CARTO's source](https://github.com/CartoDB/CartoColor/blob/master/src/carto.ts).
  It is essentially **Paul Tol's "muted" scheme reordered** (plus `#661100` at size 10–11). Verified
  in [`_plotly_utils/colors/carto.py`](https://raw.githubusercontent.com/plotly/plotly.py/main/_plotly_utils/colors/carto.py).
  The default `Plotly` 10-color cycle is **not** CVD-safe.
- **Bokeh `Colorblind`** — `Colorblind8` in [`bokeh/palettes.py`](https://github.com/bokeh/bokeh/blob/main/src/bokeh/palettes.py)
  is Okabe–Ito reordered (blue first), plus Tol's `Bright`/`HighContrast`/`Vibrant`/`Muted` groups.

![Plotly Safe (CARTO / Tol muted) under CVD simulation](colorblind-themes/dataviz-plotly-safe.png)

![Bokeh Colorblind8 (Okabe–Ito) under CVD simulation](colorblind-themes/dataviz-bokeh-colorblind.png)

## ggpubfigs / pypubfigs — journal-published, actively maintained

Steenwyk & Rokas, [*Microbiology Resource Announcements* 2021](https://journals.asm.org/doi/10.1128/MRA.00871-21)
(DOI 10.1128/MRA.00871-21); [R](https://github.com/JLSteenwyk/ggpubfigs) and
[Python](https://github.com/JLSteenwyk/pypubfigs) (MIT, updated through 2026-02). A curated,
publication-oriented bundle re-exporting the canonical CVD sets (Tol bright/muted/vibrant/high-contrast,
Okabe–Ito `ito_seven`, Wong `wong_eight`, IBM `ibm_five`) plus two claimed-CVD-safe originals,
`zesty_four` and `retro_four`:

![ggpubfigs zesty_four](colorblind-themes/dataviz-zesty-four.png)

![ggpubfigs retro_four](colorblind-themes/dataviz-retro-four.png)

**Correction:** their `tableau_ten` is the stock Tableau 10 (`#4E79A7 #F28E2B …`), which is **not**
the Tableau Color Blind 10 and is not CVD-verified — don't confuse the two.

## Palette generators and checkers (produce or verify CVD-safe palettes)

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

## ColorBrewer's colorblind-safe flag (1999–2002) — the first mainstream tool

[colorbrewer2.org](https://colorbrewer2.org/) (Cynthia Brewer) was the first widely used tool to tag
schemes "colorblind safe". Verified flag list from RColorBrewer source: diverging **BrBG, PiYG, PRGn,
PuOr, RdBu, RdYlBu**; qualitative **Dark2, Paired, Set2**; **all 18 sequential** schemes. Not flagged:
RdGy, RdYlGn, Spectral, Accent, Pastel1/2, Set1, Set3.

![ColorBrewer Set2](colorblind-themes/dataviz-colorbrewer-set2.png)

## Fabio Crameri's Scientific colour maps (2018–2023)

[fabiocrameri.ch/colourmaps](https://www.fabiocrameri.ch/colourmaps) — every map marked
"Colour-vision-deficiency friendly" and grayscale-readable (perceptually uniform, ordered lightness;
[Kovesi](https://arxiv.org/abs/1509.03700) diagnostics). **batlow** is the flagship "scientific
rainbow"; W/K variants (white-/black-ended) make the suite unusually good on both backgrounds.
Companion manifesto: [Crameri, Shephard & Heron 2020, *The misuse of colour in science
communication*](https://www.nature.com/articles/s41467-020-19160-7) (Nat. Comms, DOI
10.1038/s41467-020-19160-7). MIT; available via Zenodo, cmasher, GMT ≥6.0, R `scico`/`khroma`.

![batlow endpoints under CVD simulation](colorblind-themes/dataviz-crameri-batlow.png)

## David Nichols — Coloring for Colorblindness

[davidmathlogic.com/colorblind](https://davidmathlogic.com/colorblind) — interactive checker that
renders any palette under protanopia, deuteranopia, tritanopia, and monochrome. His recommended
4-color default and 8 pre-verified safe **pairs** (e.g. `#1A85FF`/`#D41159`):

![Nichols default 4](colorblind-themes/dataviz-nichols-default.png)

## Krzywinski's 15-color palette

Martin Krzywinski's [mkweb.bcgsc.ca/biovis2012](http://mkweb.bcgsc.ca/biovis2012/) 15-color set,
preserved in the CRAN [colorBlindness](https://cran.r-project.org/web/packages/colorBlindness/vignettes/colorBlindness.html)
package as `paletteMartin`:

![Krzywinski 15-color palette](colorblind-themes/dataviz-krzywinski-15.png)

## R packages collecting the above

- [**khroma**](https://packages.tesselle.org/khroma) (Tesselle, GPL-3) — Okabe–Ito + Tol + Crameri
  implementations with built-in CVD-simulation diagnostics (`plot_scheme_colorblind()`).
- [**colorBlindness**](https://cran.r-project.org/web/packages/colorBlindness/vignettes/colorBlindness.html)
  (Jianhong Ou, GPL≥2) — Wong/Okabe–Ito `safeColors`, Krzywinski's 15, heatmap diverging ramps, and
  a Viénot–Brettel–Mollon simulator (`cvdPlot()`).

---
