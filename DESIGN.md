# DESIGN.md — Normalled Jackfield

Ground truth, not intention. Derived from `themes/jackfield/static/css/jackfield.css` and `themes/jackfield/layouts/_default/baseof.html`. Contract: `DIRECTION.md`.

A dark machine-room instrument for a colorblind-theme reference. State is drawn by stroke **pattern** (unbroken / ticked / doubled / open), never by hue alone. The site must stay fully legible under desaturation — that is the product's thesis, demonstrated on itself.

## Color tokens (`:root`)

| Token | Hex | Role |
|---|---|---|
| `--glass` | `#0b0d10` | page ground (black glass) |
| `--panel` | `#12151a` | nav strip, thead, blockquote fill |
| `--panel2` | `#1a1f26` | code wells, pre blocks |
| `--edge` | `#1d232b` | hairline borders (outer) |
| `--edge2` | `#232a33` | hairline borders (wells, tables) |
| `--amber` | `#f5a623` | the one signal color |
| `--ink` | `#e8eef4` | headings, strong |
| `--text` | `#c4ced8` | body (steel) |
| `--muted` | `#7a8896` | lane numbers, crumbs, de-emphasis |

Rule: **no meaning rides hue alone.** Amber marks signal, but every state it colors is also a shape, pattern, weight, or label. Supporting hexes: link underline `#6b4a12`, link hover `#ffc95e`, inline code `#ffd28a`, idle rail `#3a4450`, lane text `#aeb9c4`.

## Signature grammar: lanes and rails

Nav is a fixed left legend strip (`.lanes`, 224px, sticky, `--panel` with `--edge` right border). Each entry (`.lane`) = lane number (`.ln`, 10px mono, muted) + rail (`.rail`) + label (`.lbl`). Lane numbers come from front matter; label is the page title.

The rail (22×3px bar) encodes state by **stroke pattern**:

| State | Pattern | CSS |
|---|---|---|
| idle | unbroken solid bar | `background: #3a4450` |
| hover | ticked dashes | `repeating-linear-gradient(90deg, amber 0 5px, transparent 5px 8px)` |
| current | **doubled** bar (bar + 5px-offset shadow twin) | `background: amber; box-shadow: 0 5px 0 amber` |

Current also colors the label amber — redundant with the doubled rail, never the sole carrier.

**Mobile (≤860px):** rails are hidden (`display: none`). Current is carried by triple redundancy: `border-bottom: 3px double amber` + bold ink label + tick glyph appended to the lane number (`.lane.cur .ln::after`, an amber check clipped via `clip-path` polygon).

## Typography

- **Body:** system sans stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, …`), 16px/1.65.
- **Mono:** `ui-monospace, "SF Mono", Menlo, Consolas` — used for all *instrument* text: brand, lane numbers, breadcrumb, table heads, code, hex values.
- **Scale:** H1 30px/700 ink · H2 21px/650 **amber** · H3 16.5px/650 ink · H4 14px/650 ink · body 16px · tables 14px · code 13px · thead/lane-num 10–12px mono.
- Links: amber, underlined with `#6b4a12` decoration at 3px offset; hover brightens to `#ffc95e`.

## Component conventions

- **Breadcrumb** (`.crumb`, baseof): `LANE {{lane}} / {{LANENAME}}` — 11px mono, muted, 0.14em tracking. Rendered on every page; defaults to `00 / OVERVIEW`.
- **H1 + rule:** every article opens with H1 followed by `.rule` — a 3px amber **ticked** rule (`repeating-linear-gradient`, 14px on / 6px off). Same dash grammar as the hover rail.
- **Swatch image wells** (`.article img`): white background, `--edge2` border, 6px radius, 8px padding. The white well is deliberate: the SVG swatches are drawn on transparent/light plates; the well keeps swatch colors true against the dark field. Never drop the white bg to "match" the theme.
- **Code:** inline = amber-ish `#ffd28a` text in a `--panel2` well with `--edge2` border; `pre` = same well, larger, radius 6px, code inside reverts to `--text`. Amber paired with the well shape, never hue-only.
- **Tables:** hairline `--edge2` borders, collapse, block+overflow-x for narrow frames. `thead th`: 12px/650 mono, amber, `--panel` fill, **2px amber bottom border**. Row hover lifts to `--panel`.
- **Blockquote:** `--panel` fill, 3px amber left bar.

## Responsive rule

One breakpoint: **≤860px**. Body flips to column; `.lanes` becomes a horizontal wrapping top strip (static, full width, bottom border instead of right); rails hidden; current state via the doubled-underline + bold + tick-glyph triple above; `.field` padding shrinks to 26px/20px.

## Accessibility invariant (hard requirement)

The site is about colorblindness; it must remain legible fully desaturated. Invariants to preserve when extending:

1. Every state is a pattern, shape, weight, or text label — hue is always redundant.
2. Hex values always appear as text; a swatch is never the only carrier.
3. Contrast: body `--text` on `--glass` and `--ink` headings sit well above WCAG AA; keep new text at or above `--muted` (#7a8896 on #0b0d10 ≈ 4.6:1) for anything informational.

## How to add a page

1. Create `content/<name>.md` with front matter:

```yaml
---
title: "Visible label in nav"
lane: "02c"        # lane number shown in nav + crumb
laneName: "Editors" # uppercased in crumb
slug: "<name>"
weight: 5           # nav order (Site.Pages.ByWeight)
---
```

2. Lanes group by section number (`02` = Editors), sub-lettered within a group (`02a`, `02b`, …). Home is lane `00` automatically.
3. Start the body with `##` sections; the H1 and ticked rule come from the template/single layout — don't add your own H1.
4. Reference SVGs from `/assets/…`; the white well is automatic.
