#!/usr/bin/env python3
"""Generate SVG examples for the colorblind-themes report.

Two artifact classes per the locked direction (precision instrument + real mockups):
  - Swatch plates: calibration-chart strips with hex labels, tick marks, and a
    four-row CVD simulation (Normal / Deuteranopia / Protanopia / Tritanopia)
    using the Machado et al. (2009) physiologically-based model.
  - Editor mockups: code-window renderings using each theme's real hexes.

Deterministic, no dependencies, stdlib only. Run: python3 scripts/generate_colorblind_theme_examples.py
Output: docs/reports/assets/colorblind-themes/*.svg
"""

import os

OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "reports", "assets", "colorblind-themes")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- simulation
# Machado, Oliveira & Fernandes (2009), severity 1.0 (full dichromacy),
# IEEE TVCG 15(6):1291-1298, DOI 10.1109/TVCG.2009.113
MACHADO = {
    "protanopia":   [[0.152286, 1.052583, -0.204868],
                     [0.114503, 0.786281, 0.099216],
                     [-0.003882, -0.048116, 1.051998]],
    "deuteranopia": [[0.367322, 0.860646, -0.227968],
                     [0.280085, 0.672501, 0.047413],
                     [-0.011820, 0.042940, 0.968881]],
    "tritanopia":   [[1.255528, -0.076749, -0.178779],
                     [-0.078411, 0.930809, 0.147602],
                     [0.004733, 0.691367, 0.303900]],
}

def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))

def rgb2hex(rgb):
    return "#%02X%02X%02X" % tuple(max(0, min(255, round(c * 255))) for c in rgb)

def _dec(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def _enc(c):
    return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055

def simulate(hexcolor, kind):
    """Apply Machado 2009 matrix in linear sRGB, re-encode to gamma sRGB."""
    if kind is None:
        return hexcolor
    r, g, b = hex2rgb(hexcolor)
    rl, gl, bl = _dec(r), _dec(g), _dec(b)
    m = MACHADO[kind]
    rr = m[0][0] * rl + m[0][1] * gl + m[0][2] * bl
    gg = m[1][0] * rl + m[1][1] * gl + m[1][2] * bl
    bb = m[2][0] * rl + m[2][1] * gl + m[2][2] * bl
    cl = lambda v: max(0.0, min(1.0, v))
    return rgb2hex((_enc(cl(rr)), _enc(cl(gg)), _enc(cl(bb))))

def luminance(hexcolor):
    r, g, b = hex2rgb(hexcolor)
    rl, gl, bl = _dec(r), _dec(g), _dec(b)
    return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl

def fg_for(bg):
    return "#000000" if luminance(bg) > 0.35 else "#FFFFFF"

def shade(hexcolor, factor):
    r, g, b = hex2rgb(hexcolor)
    return rgb2hex((min(1, r * factor), min(1, g * factor), min(1, b * factor)))

def esc(text):
    return (text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace('"', "&quot;"))

FONT = "ui-monospace,'SF Mono',Menlo,Consolas,monospace"

# ---------------------------------------------------------------- swatch plates

def swatch_plate(colors, labels, width=900, mode=None):
    """Calibration-chart plate: labeled strip, then Normal/Deutan/Protan/Tritan rows.
    The plate carries a solid background matching the site's mode surface:
    dark plates on #0B0D10, light plates on #F4F1EA (data-viz plates default to dark)."""
    n = len(colors)
    sw = min(124, (width - 176) / n)
    x0 = 118 + ((width - 176) - n * sw) / 2  # center plates with few chips
    sh, gap = 46, 8
    top = 26                  # main strip starts near the top (no rotated labels above anymore)
    label_row_h = 20          # horizontal label row under the main strip
    row_pitch = sh + gap
    rows = [("Normal", None), ("Deuteranopia", "deuteranopia"),
            ("Protanopia", "protanopia"), ("Tritanopia", "tritanopia")]
    # vertical layout: main strip at `top`, then label row, then the 4 sim rows, then footer room
    sim_top = top + sh + label_row_h + 8
    h = sim_top + len(rows) * row_pitch + 30
    w = width
    # solid plate background matching the site surface for the plate's mode
    plate_bg = "#0B0D10" if mode != "light" else "#F4F1EA"
    label_fg = "#9aa3ab" if mode != "light" else "#6b7280"
    foot_fg = "#a8a8a8" if mode != "light" else "#7a7060"
    p = [f'<svg xmlns="http://www.w3.org/2000/svg" class="swatch" viewBox="0 0 {w} {h}" font-family="{FONT}">']
    p.append(f'<rect x="0" y="0" width="{w}" height="{h}" rx="6" fill="{plate_bg}"/>')

    # swatch cells, main strip
    y = top
    for i, c in enumerate(colors):
        x = x0 + i * sw
        p.append(f'<rect x="{x:.1f}" y="{y}" width="{sw - 7:.1f}" height="{sh}" rx="4" fill="{c}"/>')
        inner = fg_for(c)
        p.append(f'<text x="{x + 6:.1f}" y="{y + sh - 7}" font-size="9.5" fill="{inner}" opacity="0.92">{c.upper()}</text>')
        # role label: horizontal, in a dedicated row directly under the main strip.
        # No rotation, no overlap with swatches; each label is centered on its own column.
        lx = x + (sw - 7) / 2
        ly = y + sh + 14
        p.append(f'<text x="{lx:.1f}" y="{ly}" font-size="9" fill="{label_fg}" text-anchor="middle">{esc(labels[i][:14])}</text>')

    # simulation rows
    y = sim_top
    for name, kind in rows:
        p.append(f'<text x="8" y="{y + sh / 2 + 4:.1f}" font-size="11" fill="{label_fg}">{name}</text>')
        for i, c in enumerate(colors):
            shown = simulate(c, kind)
            x = x0 + i * sw
            p.append(f'<rect x="{x:.1f}" y="{y}" width="{sw - 7:.1f}" height="{sh}" rx="4" fill="{shown}"/>')
        y += row_pitch

    # footer: simulation model credit
    p.append(f'<text x="8" y="{h - 12}" font-size="9" fill="{foot_fg}">Simulated: Machado, Oliveira &amp; Fernandes (2009), severity 100% &#183; doi:10.1109/TVCG.2009.113</text>')
    p.append("</svg>")
    return "\n".join(p)

# ---------------------------------------------------------------- editor mockups

def editor_mock(pal, width=900):
    """Editor window mock. pal: dict with keys
    name, variant, bg, fg, comment, plus optional gutter, status, and syntax roles:
    keyword, func, string, number, type, constant, variable, error, warn.
    """
    bg = pal["bg"]
    fg = pal["fg"]
    c = {
        "keyword":  pal.get("keyword", fg),
        "func":     pal.get("func", fg),
        "string":   pal.get("string", fg),
        "number":   pal.get("number", fg),
        "type":     pal.get("type", fg),
        "constant": pal.get("constant", fg),
        "variable": pal.get("variable", fg),
        "comment":  pal.get("comment", shade(fg, 0.55)),
        "error":    pal.get("error", "#ff0000"),
        "warn":     pal.get("warn", "#ffaa00"),
    }
    dark = luminance(bg) < 0.2
    gutter = pal.get("gutter", shade(bg, 1.25 if dark else 0.965))
    chrome = pal.get("chrome", shade(bg, 1.35 if dark else 0.93))
    status = pal.get("status", pal.get("keyword", fg))
    sel = pal.get("selection", shade(pal.get("func", fg), 0.35 if dark else 1.0))
    win_h = 404
    title_h = 30
    status_h = 24
    w = width
    p = [f'<svg xmlns="http://www.w3.org/2000/svg" class="editor" viewBox="0 0 {w} {win_h}" font-family="{FONT}">']

    # window frame
    p.append(f'<rect x="1" y="1" width="{w - 2}" height="{win_h - 2}" rx="10" fill="{bg}" stroke="{chrome}" stroke-width="1.5"/>')
    # title bar
    p.append(f'<path d="M1 11 a10 10 0 0 1 10-10 h{w - 22} a10 10 0 0 1 10 10 v{title_h - 10} h-{w - 2} z" fill="{chrome}"/>')
    for i, dot in enumerate(("#FF5F57", "#FEBC2E", "#28C840")):
        p.append(f'<circle cx="{24 + i * 16}" cy="{title_h / 2 + 1}" r="5" fill="{dot}"/>')
    p.append(f'<text x="{w / 2:.0f}" y="{title_h / 2 + 4}" font-size="11.5" fill="{fg}" opacity="0.75" text-anchor="middle">{esc(pal["name"])} &#8212; {esc(pal["variant"])}</text>')

    # gutter
    body_y = title_h + 1
    p.append(f'<rect x="1" y="{body_y}" width="52" height="{win_h - body_y - status_h}" fill="{gutter}"/>')
    p.append(f'<line x1="53" y1="{body_y}" x2="53" y2="{win_h - status_h}" stroke="{chrome}" stroke-width="1"/>')

    # code lines: list of (lineno, segments, indent_px). segments = (text, colorkey)
    # code lines (PowerShell): list of (lineno, segments, indent_px). segments = (text, colorkey)
    lines = [
        (1, [("# render a palette as an SVG swatch plate", "comment")], 0),
        (2, [("function ", "keyword"), ("New-SwatchPlate", "func"), (" {", "fg")], 0),
        (3, [("    param(", "fg"), ("[string[]]", "type"), ("$Colors", "variable"), (", ", "fg"), ("[string[]]", "type"), ("$Labels", "variable"), (")", "fg")], 0),
        (4, [("    ", "fg"), ("$Width", "fg"), (" = ", "keyword"), ("900", "number"), ("  ", "fg"), ("# px", "comment")], 0),
        (5, [], 0),
        (6, [("    foreach ", "keyword"), ("(", "fg"), ("$Color", "variable"), (" in ", "keyword"), ("$Colors", "variable"), (") {", "fg")], 0),
        (7, [("        ", "fg"), ("$Chip", "variable"), (" = ", "keyword"), ("[Chip]::", "type"), ("new(", "func"), ("$Color", "variable"), (")", "fg")], 0),
        (8, [("        ", "fg"), ("if ", "keyword"), ("(", "fg"), ("$Chip", "variable"), (".WcagRatio ", "constant"), ("-lt ", "keyword"), ("4.5", "number"), (") { ", "fg"), ("throw ", "keyword"), ("}", "fg")], 0),
        (9, [], 0),
        (10, [("        ", "fg"), ("[Plate]::", "type"), ("Add(", "func"), ("$Chip", "variable"), (")", "fg")], 0),
        (11, [("    }", "fg")], 0),
        (12, [("}", "fg")], 0),
        (13, [("class ", "keyword"), ("Chip", "type"), (" {", "fg")], 0),
        (14, [("    ", "fg"), ("[bool]", "type"), ("$Border", "variable"), (" = ", "keyword"), ("$true", "constant"), ("  ", "fg"), ("# always visible", "comment")], 0),
    ]
    # one line gets a squiggly error underline, one a warn underline
    error_line, warn_line = 8, 4
    ly = body_y + 26
    lh = 24
    for ln, segs, ind in lines:
        if ln == warn_line:
            # selection/highlight band behind a line to show selection color
            p.append(f'<rect x="53" y="{ly - 15}" width="{w - 56}" height="{lh - 2}" fill="{sel}" opacity="0.28"/>')
        p.append(f'<text x="38" y="{ly}" font-size="11" fill="{fg}" opacity="0.45" text-anchor="end">{ln}</text>')
        x = 66 + ind
        for text, key in segs:
            color = fg if key == "fg" else c[key]
            p.append(f'<text x="{x}" y="{ly}" font-size="12.5" fill="{color}">{esc(text)}</text>')
            x += len(text) * 7.55
        if ln == error_line:
            p.append(f'<path d="M66 {ly + 4} q 4 -4 8 0 t 8 0 t 8 0 t 8 0 t 8 0 t 8 0" fill="none" stroke="{c["error"]}" stroke-width="1.5"/>')
        if ln == warn_line:
            p.append(f'<path d="M66 {ly + 4} q 4 -4 8 0 t 8 0 t 8 0" fill="none" stroke="{c["warn"]}" stroke-width="1.5"/>')
        ly += lh

    # status bar
    sy = win_h - status_h - 1
    p.append(f'<path d="M1 {sy} h{w - 2} v{status_h - 9} a10 10 0 0 1 -10 10 h-{w - 22} a10 10 0 0 1 -10-10 z" fill="{status}"/>')
    sfg = fg_for(status)
    p.append(f'<text x="14" y="{sy + 16}" font-size="10.5" fill="{sfg}">&#9095; main*    New-SwatchPlate.ps1    pwsh 7.5    UTF-8    Ln 8, Col 24    spaces: 4</text>')
    p.append(f'<text x="{w - 14}" y="{sy + 16}" font-size="10.5" fill="{sfg}" text-anchor="end">LF  &#10003; prettier  CVD-safe</text>')
    p.append("</svg>")
    return "\n".join(p)

# ---------------------------------------------------------------- palettes (verified hexes from .research/*)

THEMES = {
    # ---- editors / IDE
    "github": {
        "name": "GitHub Colorblind", "variant_dark": "Dark Colorblind", "variant_light": "Light Colorblind",
        "dark": dict(bg="#0d1117", fg="#e6edf3", comment="#8b949e", keyword="#ec8e2c", func="#d2a8ff",
                     string="#a5d6ff", number="#79c0ff", type="#ffa657", constant="#79c0ff", variable="#fdac54",
                     error="#f0883e", warn="#d29922", status="#1f6feb"),
        "light": dict(bg="#ffffff", fg="#1f2328", comment="#57606a", keyword="#b35900", func="#6639ba",
                      string="#0a3069", number="#0550ae", type="#953800", constant="#0550ae", variable="#8a4600",
                      error="#b35900", warn="#9a6700", status="#0969da"),
        "strip_dark": ["#ec8e2c", "#58a6ff", "#d2a8ff", "#a5d6ff", "#79c0ff", "#d29922", "#39c5cf", "#be8fff"],
        "strip_dark_labels": ["keyword", "success*", "func", "string", "number", "warn", "cyan", "magenta"],
        "strip_light": ["#b35900", "#0969da", "#6639ba", "#0a3069", "#0550ae", "#9a6700", "#1b7c83", "#8250df"],
        "strip_light_labels": ["keyword", "success*", "func", "string", "number", "warn", "cyan", "magenta"],
        "note": "*success/danger are remapped: green&#8594;blue, red&#8594;orange",
    },
    "modus": {
        "name": "Modus (deuteranopia)", "variant_dark": "modus-vivendi-deuteranopia", "variant_light": "modus-operandi-deuteranopia",
        "dark": dict(bg="#000000", fg="#ffffff", comment="#989898", keyword="#feacd0", func="#00d3d0",
                     string="#cabf00", number="#ff5f59", type="#44bc44", constant="#2fafff", variable="#82b0ec",
                     error="#ff5f59", warn="#cabf00", status="#2fafff"),
        "light": dict(bg="#ffffff", fg="#000000", comment="#595959", keyword="#721045", func="#005e8b",
                      string="#695500", number="#a60000", type="#006800", constant="#0031a9", variable="#003497",
                      error="#a60000", warn="#695500", status="#0031a9"),
        "strip_dark": ["#ff5f59", "#44bc44", "#cabf00", "#2fafff", "#feacd0", "#00d3d0"],
        "strip_dark_labels": ["red", "green", "yellow", "blue", "magenta", "cyan"],
        "strip_light": ["#a60000", "#006800", "#695500", "#0031a9", "#721045", "#005e8b"],
        "strip_light_labels": ["red", "green", "yellow", "blue", "magenta", "cyan"],
        "note": "WCAG AAA (&#8805;7:1) base; CVD variants re-route semantic colors",
    },
    "pierre": {
        "name": "Pierre", "variant_dark": "Dark &#183; protanopia/deuteranopia", "variant_light": "Light &#183; protanopia/deuteranopia",
        "dark": dict(bg="#0a0a0a", fg="#fafafa", comment="#8a8a8a", keyword="#b969f3", func="#009fff",
                     string="#97c4ff", number="#69b1ff", type="#ffa359", constant="#97c4ff", variable="#ffa359",
                     error="#fe8c2c", warn="#ffde80", status="#009fff"),
        "light": dict(bg="#ffffff", fg="#0a0a0a", comment="#6e6e6e", keyword="#8836c7", func="#009fff",
                      string="#215584", number="#216cab", type="#ac6023", constant="#215584", variable="#ac6023",
                      error="#ac6023", warn="#ffca00", status="#009fff"),
        "strip_dark": ["#009fff", "#97c4ff", "#fe8c2c", "#ffde80", "#68cdf2", "#b969f3", "#ffa359", "#69b1ff"],
        "strip_dark_labels": ["accent", "success", "danger", "warn", "info", "merge", "tag", "ansi.green"],
        "strip_light": ["#009fff", "#216cab", "#ac6023", "#ffca00", "#2182a1", "#58287c"],
        "strip_light_labels": ["accent", "success", "danger", "warn", "info", "merge"],
        "note": "Build-gated: Machado (2009) sim, &#916;E &#8805; 8&#8211;11 between roles",
    },
    "datum": {
        "name": "datum", "variant_dark": "datum (dark)", "variant_light": "datum (light)",
        "dark": dict(bg="#0f1318", fg="#ced3d9", comment="#5f6b7a", keyword="#fa94cd", func="#69b9f7",
                     string="#54dcaa", number="#e8df69", type="#6ae5ec", constant="#f8bd5f", variable="#ced3d9",
                     error="#f8bd5f", warn="#e8df69", status="#69b9f7"),
        "light": dict(bg="#f1f6fd", fg="#242a30", comment="#7a8899", keyword="#973070", func="#0176b8",
                      string="#007553", number="#976700", type="#0d7a7f", constant="#a24500", variable="#242a30",
                      error="#a24500", warn="#976700", status="#0176b8"),
        "strip_dark": ["#69b9f7", "#54dcaa", "#6ae5ec", "#e8df69", "#f8bd5f", "#fa94cd"],
        "strip_dark_labels": ["blue", "green", "cyan", "yellow", "orange", "pink"],
        "strip_light": ["#0176b8", "#007553", "#0d7a7f", "#976700", "#a24500", "#973070"],
        "strip_light_labels": ["blue", "green", "cyan", "yellow", "orange", "pink"],
        "note": "OKLCH hues anchored on Okabe&#8211;Ito; WCAG 2.2 + APCA verified",
    },
    "dichromatic": {
        "name": "Dichromatic", "variant_dark": "vim-dichromatic", "variant_light": None,
        "dark": dict(bg="#080808", fg="#D0D0D0", comment="#808080", keyword="#AF5FAF", func="#5FAF87",
                     string="#AFAF00", number="#D75F87", type="#87D7D7", constant="#D75F87", variable="#D0D0D0",
                     error="#87005F", warn="#DFDF87", status="#5FAF87", selection="#87D7D7"),
        "strip_dark": ["#D75F87", "#AF5FAF", "#AFAF00", "#87D7D7", "#5FAF87", "#DFDF87"],
        "strip_dark_labels": ["number", "keyword", "string", "type", "func", "preproc"],
        "note": "Built on Paul Tol&#8217;s SRON palette, adapted to xterm-256",
    },
    "gentle": {
        "name": "Gentle", "variant_dark": "Gentle Dark", "variant_light": "Gentle Light",
        "dark": dict(bg="#1C1E22", fg="#D8DCE2", comment="#6B7A87", keyword="#B794D4", func="#6AAFE6",
                     string="#5FB49C", number="#E8A854", type="#56C4C8", constant="#70D8DC", variable="#A1A8B3",
                     error="#E8A854", warn="#E8A854", status="#6AAFE6"),
        "light": dict(bg="#FDFCFA", fg="#3D424A", comment="#7F8A93", keyword="#7B5EA7", func="#2A6DB0",
                      string="#1A7A6C", number="#B35D00", type="#0D7377", constant="#0D9488", variable="#5A6673",
                      error="#B35D00", warn="#B35D00", status="#2A6DB0"),
        "strip_dark": ["#5FB49C", "#B794D4", "#6AAFE6", "#56C4C8", "#E8A854", "#70D8DC"],
        "strip_dark_labels": ["string", "keyword", "func", "type", "number", "constant"],
        "strip_light": ["#1A7A6C", "#7B5EA7", "#2A6DB0", "#0D7377", "#B35D00", "#0D9488"],
        "strip_light_labels": ["string", "keyword", "func", "type", "number", "constant"],
        "note": "Teal+orange replaces the red/green signal pair; WCAG AA",
    },
    "blinds": {
        "name": "Blinds", "variant_dark": "Blinds Dark", "variant_light": "Blinds Light",
        "dark": dict(bg="#1f1f1f", fg="#f7f7f7", comment="#515151", keyword="#aa3377", func="#ccbb44",
                     string="#228833", number="#66CCEE", type="#ffffff", constant="#66CCEE", variable="#4477aa",
                     error="#EE6677", warn="#ccbb44", status="#4477aa"),
        "light": dict(bg="#ffffff", fg="#3b3b3b", comment="#8a8a8a", keyword="#aa3377", func="#9a8600",
                      string="#228833", number="#0099bb", type="#222222", constant="#0099bb", variable="#4477aa",
                      error="#CC3311", warn="#9a8600", status="#4477aa"),
        "strip_dark": ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377"],
        "strip_dark_labels": ["variable", "error", "string", "func", "number", "keyword"],
        "strip_light": ["#4477AA", "#CC3311", "#228833", "#9a8600", "#0099bb", "#AA3377"],
        "strip_light_labels": ["variable", "error", "string", "func", "number", "keyword"],
        "note": "Syntax roles taken from Paul Tol&#8217;s &#8220;bright&#8221; scheme",
    },
    "monokai_deuteranopia": {
        "name": "Monokai Deuteranopia", "variant_dark": "Monokai Deuteranopia Colorblind", "variant_light": None,
        "dark": dict(bg="#0B1026", fg="#D4E4FF", comment="#6B7D94", keyword="#B28BFF", func="#DCDCAA",
                     string="#E6C07B", number="#D4A0FF", type="#CC79A7", constant="#D4A0FF", variable="#D4A0FF",
                     error="#56B4E9", warn="#F0E442", status="#56B4E9", selection="#1A2E55"),
        "strip_dark": ["#56B4E9", "#B28BFF", "#DCDCAA", "#E6C07B", "#CC79A7", "#D4A0FF", "#F0E442"],
        "strip_dark_labels": ["caret", "keyword", "func", "string", "type", "number", "find"],
        "note": "Blue&#8211;yellow axis; Okabe&#8211;Ito sky blue / reddish purple reused",
    },
    "hakimi": {
        "name": "Hakimi Deuteranopia Safe", "variant_dark": "Hakimi Dark", "variant_light": "Hakimi Light",
        "dark": dict(bg="#263238", fg="#e0e0e0", comment="#5d7078", keyword="#e878cf", func="#7ab2ff",
                     string="#50c0b6", number="#ff9536", type="#8bdcff", constant="#e1be6a", variable="#91bfff",
                     error="#ff8585", warn="#e1be6a", status="#7ab2ff"),
        "light": dict(bg="#ffead8", fg="#45494c", comment="#9b7f66", keyword="#7a255d", func="#336fd6",
                      string="#00543f", number="#7a3f00", type="#005b9f", constant="#684100", variable="#336fd6",
                      error="#6f1f65", warn="#684100", status="#336fd6"),
        "strip_dark": ["#7ab2ff", "#8bdcff", "#50c0b6", "#ff9536", "#e1be6a", "#ff8585", "#e878cf"],
        "strip_dark_labels": ["blue", "sky", "teal", "peach", "yellow", "red", "pink"],
        "strip_light": ["#336fd6", "#005b9f", "#00543f", "#7a3f00", "#684100", "#6f1f65", "#7a255d"],
        "strip_light_labels": ["blue", "sky", "teal", "peach", "yellow", "red", "pink"],
        "note": "Every color chosen from deuteranopia-safe sets; Zed/VS Code/Obsidian",
    },
    "goofygoobers": {
        "name": "Color Blind Themes", "variant_dark": "Color Blind Themes (protan/deutan)", "variant_light": None,
        "dark": dict(bg="#141622", fg="#eff0eb", comment="#4D4E4F", keyword="#ff6ac1", func="#57c7ff",
                     string="#5af78e", number="#ffbc58", type="#9aedfe", constant="#ff5c57", variable="#eff0eb",
                     error="#ff5c57", warn="#ffbc58", status="#57c7ff"),
        "strip_dark": ["#ffbc58", "#9aedfe", "#5af78e", "#b76aff", "#ff5c57", "#ff6ac1", "#57c7ff"],
        "strip_dark_labels": ["number", "type", "string", "boolean", "class", "keyword", "func"],
        "note": "By a protanopia/deuteranopia author, for the same audience",
    },
    "onedarkpro_cb": {
        "name": "One Dark Pro Colorblind", "variant_dark": "OneDarkPro Colorblind v1", "variant_light": None,
        "dark": dict(bg="#282c34", fg="#abb2bf", comment="#5c6370", keyword="#c678dd", func="#61afef",
                     string="#dae36d", number="#90e9ff", type="#7DF9FF", constant="#e06c75", variable="#c678dd",
                     error="#e06c75", warn="#dae36d", status="#61afef"),
        "strip_dark": ["#dae36d", "#c678dd", "#61afef", "#7DF9FF", "#90e9ff", "#e06c75"],
        "strip_dark_labels": ["string", "keyword", "func", "type", "number", "constant"],
        "note": "One Dark Pro hues retuned onto distinguishable axes",
    },
    "morimo": {
        "name": "morimo", "variant_dark": "morimo (dark)", "variant_light": None,
        "dark": dict(bg="#2a2a2e", fg="#b5d2a9", comment="#767b82", keyword="#b384b1", func="#9bb9d4",
                     string="#a0c8cc", number="#d99872", type="#729e7b", constant="#d3c785", variable="#98b18e",
                     error="#ff6e6e", warn="#e0d7a3", status="#9bb9d4"),
        "strip_dark": ["#ff6e6e", "#98c593", "#d3c785", "#9bb9d4", "#b384b1", "#a0c8cc", "#d99872"],
        "strip_dark_labels": ["red", "green", "yellow", "blue", "magenta", "cyan", "orange"],
        "note": "Muted, lightness-separated ramps; performance-focused Neovim",
    },
    "vision": {
        "name": "vision.nvim", "variant_dark": "vision (night)", "variant_light": None,
        "dark": dict(bg="#000022", fg="#ffffff", comment="#565f89", keyword="#bb9af7", func="#7aa2ee",
                     string="#9ece6a", number="#ff9e64", type="#7dcfff", constant="#e0af68", variable="#eeffee",
                     error="#f7768e", warn="#e0af68", status="#7aa2ee"),
        "strip_dark": ["#7aa2ee", "#7dcfff", "#bb9af7", "#ff9e64", "#e0af68", "#9ece6a", "#f7768e", "#1abc9c"],
        "strip_dark_labels": ["blue", "cyan", "magenta", "orange", "yellow", "green", "red", "teal"],
        "note": "Tokyonight hues the CVD author could not tell apart, retuned",
    },
    # ---- terminals
    "dalton": {
        "name": "Dalton", "variant_dark": "Dalton Dark", "variant_light": "Dalton Bright",
        "dark": dict(bg="#1b1b1b", fg="#c8c9cc", comment="#666a70", keyword="#a050d0", func="#7aa2f7",
                     string="#5b914e", number="#f07068", type="#56717f", constant="#c4c40c", variable="#c8c9cc",
                     error="#d85050", warn="#eded02", status="#7aa2f7", selection="#333333"),
        "light": dict(bg="#f4f1eb", fg="#2e3038", comment="#8a8d95", keyword="#7830a8", func="#3060c8",
                      string="#3a7530", number="#c83838", type="#3a5565", constant="#7a6d00", variable="#2e3038",
                      error="#b83030", warn="#8a7d00", status="#3060c8"),
        "strip_dark": ["#d85050", "#5b914e", "#c4c40c", "#7aa2f7", "#a050d0", "#56717f"],
        "strip_dark_labels": ["red", "green", "yellow", "blue", "magenta", "cyan"],
        "strip_light": ["#b83030", "#3a7530", "#7a6d00", "#3060c8", "#7830a8", "#3a5565"],
        "strip_light_labels": ["red", "green", "yellow", "blue", "magenta", "cyan"],
        "note": "ANSI slots tuned for deuteranopia + protanopia separation",
    },
    "hakarune_dracula": {
        "name": "dracula-colorblind", "variant_dark": "hakarune remix", "variant_light": None,
        "dark": dict(bg="#282a36", fg="#f8f8f2", comment="#6272a4", keyword="#BF6CFF", func="#50fa7b",
                     string="#f1fa8c", number="#bd93f9", type="#8be9fd", constant="#bd93f9", variable="#f8f8f2",
                     error="#FF7155", warn="#f1fa8c", status="#bd93f9"),
        "strip_dark": ["#FF7155", "#BF6CFF", "#f1fa8c", "#bd93f9", "#8be9fd", "#50fa7b"],
        "strip_dark_labels": ["red→orange", "green→purple", "yellow", "purple", "cyan", "green*"],
        "note": "Only red/green ANSI slots remapped; rest of Dracula intact",
    },
    "opo": {
        "name": "Opo", "variant_dark": "Opo Dark", "variant_light": "Opo Light",
        "dark": dict(bg="#161410", fg="#d1d7df", comment="#7d7a72", keyword="#498beb", func="#74acff",
                     string="#e08440", number="#dca331", type="#cd718f", constant="#33a397", variable="#d1d7df",
                     error="#e08440", warn="#dca331", status="#498beb"),
        "light": dict(bg="#fdfcf9", fg="#24292f", comment="#5e5a55", keyword="#002c85", func="#007570",
                      string="#a75000", number="#583500", type="#75254e", constant="#002c85", variable="#24292f",
                      error="#a75000", warn="#583500", status="#005ccc"),
        "strip_dark": ["#e08440", "#33a397", "#dca331", "#498beb", "#cd718f", "#74acff"],
        "strip_dark_labels": ["red→orange", "green→teal", "yellow", "blue", "magenta", "cyan"],
        "strip_light": ["#002c85", "#007570", "#a75000", "#005ccc", "#75254e", "#583500"],
        "strip_light_labels": ["keyword", "func", "string", "accent", "type", "warn"],
        "note": "OKLCH; 363 build-time contrast checks + trichromacy CVD-distance gate; 21 export targets",
    },
    "shroom": {
        "name": "Shroom Space", "variant_dark": "Shroom Space Deuteranopia", "variant_light": None,
        "dark": dict(bg="#24212E", fg="#CCC8D9", comment="#726D89", keyword="#BE9AF7", func="#FFCB6B",
                     string="#E8C990", number="#E8C990", type="#E794D2", constant="#E8C990", variable="#E794D2",
                     error="#E68484", warn="#FFCB6B", status="#BE9AF7"),
        "strip_dark": ["#BE9AF7", "#FFCB6B", "#E794D2", "#E8C990", "#E68484"],
        "strip_dark_labels": ["keyword", "func", "variable", "string", "invalid"],
        "note": "APCA + linear-RGB CVD simulation enforced in CI",
    },
    "colorsafe": {
        "name": "ColorSafe (JetBrains)", "variant_dark": "Pro-Deutan Dark", "variant_light": None,
        "dark": dict(bg="#1C1C2E", fg="#E2E2F0", comment="#9CA3C8", keyword="#5BB8F5", func="#5BB8F5",
                     string="#E6A020", number="#F0D060", type="#5BB8F5", constant="#F0D060", variable="#E2E2F0",
                     error="#FF5F87", warn="#FFAB40", status="#5BB8F5"),
        "strip_dark": ["#5BB8F5", "#E6A020", "#F0D060", "#9CA3C8", "#FF5F87", "#FFAB40"],
        "strip_dark_labels": ["blue (axis)", "amber (axis)", "number", "comment", "error", "warn"],
        "note": "Blue/amber axis; per-color WCAG tables in the .icls source",
    },
    "cindervale": {
        "name": "Cindervale Accessible", "variant_dark": "Accessible Dark", "variant_light": None,
        "dark": dict(bg="#191517", fg="#F4E9E2", comment="#9E8379", keyword="#AF8CE0", func="#B0CDF1",
                     string="#B0CDF1", number="#71A3A9", type="#BB901F", constant="#71A3A9", variable="#F4E9E2",
                     error="#AF8CE0", warn="#BB901F", status="#B0CDF1"),
        "strip_dark": ["#AF8CE0", "#B0CDF1", "#BB901F", "#71A3A9", "#9E8379"],
        "strip_dark_labels": ["keyword", "func", "type", "number", "comment"],
        "note": "Five accents separated by hue AND a full lightness tier",
    },
    "ef-deuteranopia": {
        "name": "ef-themes", "variant_dark": "ef-deuteranopia-dark", "variant_light": "ef-deuteranopia-light",
        "dark": dict(bg="#000a1f", fg="#ddddee", comment="#5a6a8a", keyword="#b379bf", func="#3f90f0",
                     string="#5faaef", number="#aa9f32", type="#3faa26", constant="#cf8560", variable="#ddddee",
                     error="#cfaf00", warn="#aa9f32", status="#3f90f0", cursor="#ffff00"),
        "light": dict(bg="#f5f5ff", fg="#1a1a2f", comment="#7a7a9a", keyword="#ba35af", func="#375cd8",
                      string="#375cd8", number="#805d00", type="#217a3c", constant="#d3303a", variable="#1a1a2f",
                      error="#d3303a", warn="#805d00", status="#375cd8"),
        "strip_dark": ["#cf8560", "#3faa26", "#aa9f32", "#3f90f0", "#b379bf", "#5faaef"],
        "strip_dark_labels": ["red→orange", "green", "yellow", "blue", "magenta", "cyan"],
        "strip_light": ["#d3303a", "#217a3c", "#805d00", "#375cd8", "#ba35af", "#1a8a9f"],
        "strip_light_labels": ["red", "green", "yellow", "blue", "magenta", "cyan"],
        "note": "Errors remapped to yellow (err→yellow-warmer), not red; Emacs, GPL-3.0",
    },
    "pitaya": {
        "name": "Pitaya Smoothie (JupyterLab)", "variant_dark": "Pitaya Smoothie", "variant_light": None,
        "dark": dict(bg="#181036", fg="#f7f7f7", comment="#7a7a9a", keyword="#f25a92", func="#1abec2",
                     string="#fad000", number="#a56cf5", type="#7998f2", constant="#f38672", variable="#f7f7f7",
                     error="#f45c7b", warn="#fad000", status="#1abec2"),
        "strip_dark": ["#1abec2", "#f25a92", "#fad000", "#7998f2", "#a56cf5", "#f38672"],
        "strip_dark_labels": ["teal", "pink", "yellow", "periwinkle", "lilac", "orange"],
        "note": "Teal/pink axis; WCAG AAA grid + protan/deutan/tritan sims in README; JupyterLab",
    },
    "lxdeepsea": {
        "name": "Lx Deep Sea (KDE Plasma)", "variant_dark": "Lx Deep Sea", "variant_light": None,
        "dark": dict(bg="#302F2F", fg="#E0DEDB", comment="#787775", keyword="#508ED8", func="#96BFF0",
                     string="#55AAFF", number="#5781B0", type="#96BFF0", constant="#8E79A5", variable="#D4D2CF",
                     error="#FF1B13", warn="#55AAFF", status="#275EA0", selection="#184880"),
        "strip_dark": ["#FF1B13", "#57CF1F", "#55AAFF", "#508ED8", "#96BFF0", "#8E79A5"],
        "strip_dark_labels": ["negative", "positive", "neutral", "link", "active", "visited"],
        "note": "Author-claimed red-green CVD; negatives/positive still differ mainly by hue",
    },
    "grafana": {
        "name": "Grafana Colorblind", "variant_dark": "Deuteranopia/Protanopia Dark", "variant_light": "Deuteranopia/Protanopia Light",
        "dark": dict(bg="#111217", fg="#d8d9da", comment="#7b8087", keyword="#FF7A18", func="#56B4E9",
                     string="#FFF899", number="#CC79A7", type="#2EC4B6", constant="#56B4E9", variable="#d8d9da",
                     error="#FF7A18", warn="#FFF899", status="#2EC4B6"),
        "light": dict(bg="#ffffff", fg="#1f2328", comment="#6a6e74", keyword="#FF9900", func="#0072B2",
                      string="#6a5a00", number="#8a3b6b", type="#006F7A", constant="#0072B2", variable="#1f2328",
                      error="#FF9900", warn="#8a7a00", status="#006F7A"),
        "strip_dark": ["#2EC4B6", "#FF7A18", "#FFF899", "#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00"],
        "strip_dark_labels": ["success", "error", "warn", "viz1", "viz2", "viz3", "viz4", "viz6"],
        "strip_light": ["#006F7A", "#FF9900", "#FFEE52", "#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00"],
        "strip_light_labels": ["success", "error", "warn", "viz1", "viz2", "viz3", "viz4", "viz6"],
        "note": "Merged 2026-03; success→teal, error→orange; viz palette is Wong/Okabe-Ito verbatim",
    },
    "coder": {
        "name": "coder/coder", "variant_dark": "Dark Protan/Deuter", "variant_light": "Light Protan/Deuter",
        "dark": dict(bg="#0d1117", fg="#e6edf3", comment="#8b949e", keyword="#f97583", func="#79c0ff",
                     string="#a5d6ff", number="#79c0ff", type="#d2a8ff", constant="#79c0ff", variable="#e6edf3",
                     error="#f97583", warn="#e879f9", status="#38bdf8"),
        "strip_dark": ["#f97583", "#38bdf8", "#e879f9", "#a78bfa"],
        "strip_dark_labels": ["danger→vermilion", "success→sky", "warning→fuchsia", "preview→violet"],
        "note": "Okabe-Ito cited in source; Tailwind orange/sky/fuchsia/violet axes; 4 themes",
    },
    "wireshark": {
        "name": "Wireshark", "variant_dark": "Protanopia & Deuteranopia Dark", "variant_light": "Protanopia & Deuteranopia Light",
        "dark": dict(bg="#1e1f24", fg="#e8e8e8", comment="#8a8f98", keyword="#ff8a50", func="#56b4e9",
                     string="#f0e442", number="#d995bf", type="#56b4e9", constant="#0072b2", variable="#e8e8e8",
                     error="#ff8a50", warn="#f0e442", status="#56b4e9"),
        "light": dict(bg="#ffffff", fg="#1a1a1a", comment="#6e747c", keyword="#a33a00", func="#0072b2",
                      string="#6a5a00", type="#0072b2", number="#8f4a78", constant="#0072b2", variable="#1a1a1a",
                      error="#a33a00", warn="#c27a00", status="#0072b2"),
        "strip_dark": ["#56b4e9", "#f0e442", "#ff8a50", "#d995bf"],
        "strip_dark_labels": ["success", "warning", "error", "info"],
        "strip_light": ["#0072b2", "#c27a00", "#a33a00", "#8f4a78"],
        "strip_light_labels": ["success", "warning", "error", "info"],
        "note": "Okabe-Ito/Wong verbatim; CI gate suite_theme.py checks distinguishability per deficiency",
    },
    "insomnia": {
        "name": "Insomnia", "variant_dark": "Dark Colorblind", "variant_light": None,
        "dark": dict(bg="#21262D", fg="#e6e6e6", comment="#7b8794", keyword="#58A6FF", func="#0080FF",
                     string="#E8F086", number="#FFC20A", type="#A691AE", constant="#0080FF", variable="#e6e6e6",
                     error="#CC5500", warn="#FFC20A", status="#0080FF"),
        "strip_dark": ["#0080FF", "#E8F086", "#A691AE", "#CC5500", "#FFC20A", "#58A6FF"],
        "strip_dark_labels": ["POST/200", "GET", "PUT", "DELETE", "surprise", "info"],
        "note": "First-party core theme (Kong, 2021); blue/orange swap; the only API client CVD theme",
    },
    "kiro": {
        "name": "Kiro", "variant_dark": "Color-blind safe Dark", "variant_light": "Color-blind safe Light",
        "dark": dict(bg="#101418", fg="#e8ecef", comment="#7d8894", keyword="#CC79A7", func="#56B4E9",
                     string="#F0E442", number="#DB5A00", type="#56B4E9", constant="#56B4E9", variable="#e8ecef",
                     error="#DB5A00", warn="#F0E442", status="#56B4E9"),
        "light": dict(bg="#ffffff", fg="#1c2126", comment="#6f7880", keyword="#8f4a78", func="#0072B2",
                      string="#6a5a00", type="#0072B2", number="#A43000", constant="#0072B2", variable="#1c2126",
                      error="#A43000", warn="#AB9100", status="#0072B2"),
        "strip_dark": ["#56B4E9", "#F0E442", "#DB5A00", "#CC79A7"],
        "strip_dark_labels": ["ok", "warn", "danger", "accent"],
        "strip_light": ["#0072B2", "#AB9100", "#A43000", "#8f4a78"],
        "strip_light_labels": ["ok", "warn", "danger", "accent"],
        "note": "Okabe-Ito status hues; colorBlindTheme.test.tsx measures every status pair under 3 sims",
    },
    "gemini-cli": {
        "name": "Gemini CLI", "variant_dark": "github-dark-colorblind", "variant_light": "github-light-colorblind",
        "dark": dict(bg="#0d1117", fg="#e6edf3", comment="#8b949e", keyword="#ec8e2c", func="#d2a8ff",
                     string="#a5d6ff", number="#79c0ff", type="#ffa657", constant="#79c0ff", variable="#fdac54",
                     error="#f0883e", warn="#d29922", status="#1f6feb"),
        "light": dict(bg="#ffffff", fg="#1f2328", comment="#57606a", keyword="#b35900", func="#6639ba",
                      string="#0a3069", number="#0550ae", type="#953800", constant="#0550ae", variable="#8a4600",
                      error="#b35900", warn="#9a6700", status="#0969da"),
        "strip_dark": ["#ec8e2c", "#58a6ff", "#d2a8ff", "#a5d6ff", "#d29922"],
        "strip_dark_labels": ["keyword", "success", "func", "string", "warn"],
        "strip_light": ["#b35900", "#0969da", "#6639ba", "#0a3069", "#9a6700"],
        "strip_light_labels": ["keyword", "success", "func", "string", "warn"],
        "note": "Google first-party CLI shipping Primer colorblind tokens as built-ins",
    },
}

# data-viz palettes: (filename, title, colors, labels)
DATAVIZ = [
    ("okabe-ito", ["#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000"],
     ["orange", "sky blue", "bluish green", "yellow", "blue", "vermilion", "reddish purple", "black"]),
    ("tol-bright", ["#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377", "#BBBBBB"],
     ["blue", "red", "green", "yellow", "cyan", "magenta", "grey"]),
    ("tol-vibrant", ["#EE7733", "#0077BB", "#33BBEE", "#EE3377", "#CC3311", "#009988", "#BBBBBB"],
     ["orange", "blue", "cyan", "magenta", "red", "teal", "grey"]),
    ("tol-muted", ["#CC6677", "#332288", "#DDCC77", "#117733", "#88CCEE", "#882255", "#44AA99", "#999933", "#AA4499"],
     ["rose", "indigo", "sand", "green", "cyan", "wine", "teal", "olive", "purple"]),
    ("tol-high-contrast", ["#004488", "#DDAA33", "#BB5566"], ["blue", "yellow", "red"]),
    ("ibm-v1", ["#648FFF", "#785EF0", "#DC267F", "#FE6100", "#FFB000"],
     ["ultramarine", "indigo", "magenta", "orange", "gold"]),
    ("carbon-categorical", ["#6929C4", "#1192E8", "#005D5D", "#9F1853", "#FA4D56", "#570408", "#198038",
                            "#002D9C", "#EE538B", "#B28600", "#009D9A", "#012749", "#8A3800", "#A56EFF"],
     ["purple70", "cyan50", "teal70", "magenta70", "red50", "red90", "green60", "blue80",
      "magenta50", "yellow50", "teal50", "blue90", "orange70", "purple50"]),
    ("seaborn-colorblind", ["#0173B2", "#DE8F05", "#029E73", "#D55E00", "#CC78BC", "#CA9161", "#FBAFE4", "#949494", "#ECE133", "#56B4E9"],
     ["blue", "orange", "green", "vermilion", "purple", "tan", "pink", "grey", "yellow", "sky"]),
    ("tableau-colorblind10", ["#006BA4", "#FF800E", "#ABABAB", "#595959", "#5F9ED1", "#C85200", "#898989", "#A2C8EC", "#FFBC79", "#CFCFCF"],
     ["blue", "orange", "grey", "dk grey", "lt blue", "dk orange", "md grey", "pale blue", "pale orange", "lt grey"]),
    ("nichols-default", ["#D81B60", "#1E88E5", "#FFC107", "#004D40"], ["magenta", "blue", "yellow", "teal"]),
    ("colorbrewer-set2", ["#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3"],
     ["teal", "orange", "lavender", "pink", "lime", "yellow", "tan", "grey"]),
    ("krzywinski-15", ["#000000", "#004949", "#009292", "#FF6DB6", "#FFB6DB", "#490092", "#006DDB", "#B66DFF",
                       "#6DB6FF", "#B6DBFF", "#920000", "#924900", "#DB6D00", "#24FF24", "#FFFF6D"],
     ["black", "dk teal", "teal", "pink", "lt pink", "purple", "blue", "lt purple",
      "lt blue", "pale blue", "dk red", "brown", "orange", "green", "yellow"]),
    ("crameri-batlow", ["#011959", "#226061", "#828231", "#F29D6D", "#FACCFA"],
     ["start", "&#188;", "&#189;", "&#190;", "end"]),
    ("cividis", ["#00224E", "#434E6C", "#7D7C78", "#BCAE6C", "#FEE838"], ["start", "&#188;", "&#189;", "&#190;", "end"]),
    ("viridis", ["#440154", "#3B528B", "#21918C", "#5EC962", "#FDE725"], ["start", "¼", "½", "¾", "end"]),
    ("petroff6", ["#5790FC", "#F89C20", "#E42536", "#964A8B", "#9C9CA1", "#7A21DD"],
     ["blue", "orange", "red", "purple", "grey", "violet"]),
    ("petroff10", ["#3F90DA", "#FFA90E", "#BD1F01", "#94A4A2", "#832DB6", "#A96B59", "#E76300", "#B9AC70", "#717581", "#92DADD"],
     ["blue", "yellow", "red", "grey", "purple", "brown", "orange", "tan", "dk grey", "cyan"]),
    ("plotly-safe", ["#88CCEE", "#CC6677", "#DDCC77", "#117733", "#332288", "#AA4499", "#44AA99", "#999933", "#882255", "#661100", "#888888"],
     ["cyan", "rose", "sand", "green", "indigo", "purple", "teal", "olive", "wine", "brown", "grey"]),
    ("bokeh-colorblind", ["#0072B2", "#E69F00", "#F0E442", "#009E73", "#56B4E9", "#D55E00", "#CC79A7", "#000000"],
     ["blue", "orange", "yellow", "bluish grn", "sky blue", "vermilion", "red-purple", "black"]),
    ("zesty-four", ["#F5793A", "#A95AA1", "#85C0F9", "#0F2080"], ["orange", "purple", "sky", "navy"]),
    ("retro-four", ["#601A4A", "#EE442F", "#63ACBE", "#F9F4EC"], ["plum", "vermilion", "teal", "paper"]),
]

# ---------------------------------------------------------------- build

def slug(name):
    return name.lower().replace(" ", "-").replace("_", "-")

built = []
for key, t in THEMES.items():
    for mode in ("dark", "light"):
        if mode not in t:
            continue
        pal = dict(t[mode])
        pal["name"] = t["name"]
        pal["variant"] = t["variant_dark"] if mode == "dark" else t.get("variant_light") or ""
        svg = editor_mock(pal)
        fn = f"{slug(key)}-{mode}-editor.svg"
        with open(os.path.join(OUT, fn), "w") as f:
            f.write(svg)
        built.append(fn)
    for mode in ("dark", "light"):
        strip_key = f"strip_{mode}"
        if strip_key not in t:
            continue
        svg = swatch_plate(t[strip_key], t[f"strip_{mode}_labels"], mode=mode)
        fn = f"{slug(key)}-{mode}-strip.svg"
        with open(os.path.join(OUT, fn), "w") as f:
            f.write(svg)
        built.append(fn)

for fn_name, colors, labels in DATAVIZ:
    svg = swatch_plate(colors, labels, mode="dark")
    fn = f"dataviz-{fn_name}.svg"
    with open(os.path.join(OUT, fn), "w") as f:
        f.write(svg)
    built.append(fn)

def compare_plate(themeA, colorsA, labelsA, themeB, colorsB, labelsB, cvd, width=900):
    """Side-by-side: a STRONG theme vs a WEAK theme, each shown Normal + one CVD view.
    Transparent background (sits on the page surface)."""
    nA, nB = len(colorsA), len(colorsB)
    sw = min(150, (width - 200) / max(nA, nB))
    sh = 56
    block_h = sh * 2 + 46
    h = 40 + block_h * 2 + 60
    p = [f'<svg xmlns="http://www.w3.org/2000/svg" class="swatch" viewBox="0 0 {width} {h}" font-family="{FONT}">']
    cvd_name = cvd.capitalize()
    p.append(f'<text x="10" y="24" font-size="15" font-weight="bold" fill="#999">Simulated under {cvd_name} (Machado 2009, 100%) &#8212; do the signal colors stay apart?</text>')
    y = 50
    for name, colors, labels in ((themeA, colorsA, labelsA), (themeB, colorsB, labelsB)):
        x0 = 150
        p.append(f'<text x="10" y="{y + sh}" font-size="13" font-weight="bold" fill="#bbb">{esc(name)}</text>')
        for i, lab in enumerate(labels):
            lx = x0 + i * sw + (sw - 8) / 2
            p.append(f'<text x="{lx:.1f}" y="{y - 8}" font-size="9.5" fill="#888" text-anchor="middle">{esc(lab[:14])}</text>')
        for row, kind in (("Normal", None), (cvd_name, cvd)):
            for i, c in enumerate(colors):
                shown = simulate(c, kind)
                x = x0 + i * sw
                p.append(f'<rect x="{x:.1f}" y="{y}" width="{sw - 8:.1f}" height="{sh}" rx="5" fill="{shown}"/>')
                p.append(f'<text x="{x + 6:.1f}" y="{y + sh - 8}" font-size="9.5" fill="{fg_for(shown)}" opacity="0.9">{shown.upper()}</text>')
            y += sh
        y += 16
    p.append("</svg>")
    return "\n".join(p)

COMPARISONS = [
    ("compare-deuteranopia", "deuteranopia",
     "GitButler (STRONG)", ["#99d9ff", "#ffbf66"], ["addition", "deletion"],
     "GitHub (WEAK)", ["#ec8e2c", "#d29922"], ["keyword", "warning"]),
    ("compare-protanopia", "protanopia",
     "Wireshark (STRONG)", ["#56b4e9", "#f0e442", "#ff8a50"], ["success", "warning", "error"],
     "coder (WEAK)", ["#38bdf8", "#e879f9"], ["success/sky", "warning/fuchsia"]),
    ("compare-tritanopia", "tritanopia",
     "Kiro (STRONG)", ["#56B4E9", "#F0E442", "#DB5A00", "#CC79A7"], ["ok", "warn", "danger", "accent"],
     "Gentle light (WEAK)", ["#7B5EA7", "#2A6DB0"], ["keyword", "function"]),
]
for fn, cvd, st, sc, sl, wt, wc, wl in COMPARISONS:
    with open(os.path.join(OUT, f"{fn}.svg"), "w") as f:
        f.write(compare_plate(st, sc, sl, wt, wc, wl, cvd))
    built.append(f"{fn}.svg")

print(f"{len(built)} SVGs written to {os.path.relpath(OUT)}")
for b in built:
    print(" ", b)
