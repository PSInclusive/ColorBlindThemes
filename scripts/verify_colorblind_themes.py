#!/usr/bin/env python3
"""Independent CVD verification of the colorblind-themes catalog.

For every theme in generate_colorblind_theme_examples.py's THEMES dict, simulate its
semantic/signal color strip under each dichromacy (Machado, Oliveira & Fernandes 2009,
severity 100%) and compute the minimum pairwise CIEDE2000 (ΔE00) distance between signal
colors. A small minimum means two signal colors collapse toward each other for that
deficiency.

CAVEATS (read before citing a number):
  - ΔE00 thresholds are rough: ~1 is just-noticeable, <3 is hard to separate on screen,
    >8 is clearly different. They are NOT a pass/fail for usability.
  - Many themes deliberately add a luminance (lightness) difference between hues that
    share an axis, so a low ΔE00 pair can still be separable by brightness. This metric
    measures hue+lightness collapse together, so it partially captures that, but it does
    not model font-weight, icons, or redundant non-color encodings.
  - A theme designed for deuteranopia only may legitimately collapse under tritanopia;
    read the "targets" column in the report before judging a cross-deficiency number.
  - The strip is a representative subset of signal colors, chosen per theme; a theme's
    full palette may contain closer or more-distant pairs than the strip shows.

Stdlib only. Run: python3 scripts/verify_colorblind_themes.py
"""

import math
import re
import os

# --- Machado 2009 (severity 1.0), linear sRGB -------------------------------------
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

def _hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))

def _dec(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def _enc(c):
    return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055

def simulate(hexcolor, kind):
    if kind is None:
        return hexcolor
    r, g, b = _hex2rgb(hexcolor)
    rl, gl, bl = _dec(r), _dec(g), _dec(b)
    m = MACHADO[kind]
    rr = m[0][0] * rl + m[0][1] * gl + m[0][2] * bl
    gg = m[1][0] * rl + m[1][1] * gl + m[1][2] * bl
    bb = m[2][0] * rl + m[2][1] * gl + m[2][2] * bl
    cl = lambda v: max(0.0, min(1.0, v))
    return "#%02X%02X%02X" % tuple(round(_enc(cl(c)) * 255) for c in (rr, gg, bb))

# --- sRGB -> CIE L*a*b* (D65) ------------------------------------------------------
def hex2lab(h):
    r, g, b = _hex2rgb(h)
    r, g, b = _dec(r), _dec(g), _dec(b)
    x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
    y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
    z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
    xn, yn, zn = 0.95047, 1.0, 1.08883
    def f(t):
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x / xn), f(y / yn), f(z / zn)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))

# --- CIEDE2000 (Sharma et al. 2005) ------------------------------------------------
def ciede2000(lab1, lab2):
    L1, a1, b1 = lab1
    L2, a2, b2 = lab2
    C1 = math.hypot(a1, b1)
    C2 = math.hypot(a2, b2)
    Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt((Cb ** 7) / (Cb ** 7 + 25 ** 7))) if Cb > 0 else 0
    a1p = (1 + G) * a1
    a2p = (1 + G) * a2
    C1p = math.hypot(a1p, b1)
    C2p = math.hypot(a2p, b2)
    def hp(a, b):
        if a == 0 and b == 0:
            return 0
        h = math.degrees(math.atan2(b, a))
        return h + 360 if h < 0 else h
    h1p = hp(a1p, b1)
    h2p = hp(a2p, b2)
    dLp = L2 - L1
    dCp = C2p - C1p
    if C1p * C2p == 0:
        dhp = 0
    else:
        dh = h2p - h1p
        if dh > 180:
            dh -= 360
        elif dh < -180:
            dh += 360
        dhp = dh
    dHp = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dhp / 2))
    Lbp = (L1 + L2) / 2
    Cbp = (C1p + C2p) / 2
    if C1p * C2p == 0:
        hbp = h1p + h2p
    else:
        dh = abs(h1p - h2p)
        if dh <= 180:
            hbp = (h1p + h2p) / 2
        elif h1p + h2p < 360:
            hbp = (h1p + h2p + 360) / 2
        else:
            hbp = (h1p + h2p - 360) / 2
    T = (1 - 0.17 * math.cos(math.radians(hbp - 30)) + 0.24 * math.cos(math.radians(2 * hbp))
         + 0.32 * math.cos(math.radians(3 * hbp + 6)) - 0.20 * math.cos(math.radians(4 * hbp - 63)))
    dtheta = 30 * math.exp(-(((hbp - 275) / 25) ** 2))
    Rc = 2 * math.sqrt((Cbp ** 7) / (Cbp ** 7 + 25 ** 7)) if Cbp > 0 else 0
    Sl = 1 + ((0.015 * (Lbp - 50) ** 2) / math.sqrt(20 + (Lbp - 50) ** 2))
    Sc = 1 + 0.045 * Cbp
    Sh = 1 + 0.015 * Cbp * T
    Rt = -math.sin(math.radians(2 * dtheta)) * Rc
    return math.sqrt((dLp / Sl) ** 2 + (dCp / Sc) ** 2 + (dHp / Sh) ** 2
                     + Rt * (dCp / Sc) * (dHp / Sh))

def min_pair(colors, cvd):
    labs = [hex2lab(simulate(c, cvd)) for c in colors]
    best = (1e9, None)
    for i in range(len(labs)):
        for j in range(i + 1, len(labs)):
            d = ciede2000(labs[i], labs[j])
            if d < best[0]:
                best = (d, (colors[i], colors[j]))
    return best

def verdict(res):
    worst = min(res[c][0] for c in res)
    return "STRONG" if worst >= 8 else ("ok" if worst >= 3 else "WEAK")

# App/platform-level themes ship real semantic palettes (see .research/09, .research/10).
# Keyed: name -> {mode: [signal colors]} — the small good/bad/status set each app shows.
APP_THEMES = {
    "Gitea": {
        "dark": ["#58a6ff", "#f0883e", "#d29922", "#ab7df8"],
        "light": ["#0860cc", "#a84400", "#9a6700", "#8250df"],
    },
    "SimpleCov": {
        "dark": ["#6cb6ff", "#f0883e", "#f0e05a"],
        "light": ["#0060a8", "#c2410c", "#9a6700"],
    },
    "plannotator": {
        "dark": ["#4f83d1", "#c96e12", "#d9a839", "#35b6d9"],
        "light": ["#216cab", "#a55c1e", "#8f6400", "#0e7d9e"],
    },
    "GitButler": {
        "dark": ["#99d9ff", "#ffbf66"],
        "light": ["#0d59bf", "#bf590d"],
    },
    "iamb (okabe-ito-dark)": {
        "dark": ["#D55E00", "#E69F00", "#F0E442", "#0072B2", "#56B4E9", "#009E73", "#CC79A7"],
    },
    "Cura Colorblind Assist": {
        "dark": ["#ff4000", "#009c80", "#ffff56", "#00ffff", "#0064ff"],
    },
    "OpenFront.io": {
        "dark": ["#0072b2", "#56b4e9", "#d55e00", "#009e73", "#cc79a7", "#f0e442", "#e69f00"],
    },
    "Talishar deuteranopia": {
        "dark": ["#33aaee", "#cc5599", "#eeaa11", "#cc5522", "#55bb88", "#8855aa", "#aa2244"],
    },
    "Talishar protanopia": {
        "dark": ["#11bbff", "#ee1100", "#ff8811", "#118899", "#99ff11", "#bb22aa", "#aa1144"],
    },
    "Talishar tritanopia": {
        "dark": ["#22eeff", "#ee2200", "#eeaa44", "#aa88ff", "#22aa00", "#6666cc", "#992255"],
    },
    "Insomnia": {
        "dark": ["#0080FF", "#E8F086", "#A691AE", "#CC5500", "#FFC20A", "#58A6FF"],
    },
    "narmi red-green": {
        "light": ["#6F6BAD", "#1A56B0", "#6F004F", "#4B0200"],
    },
    "Moira": {
        "light": ["#00771e", "#ffc107", "#ff5722", "#9e9e9e"],
    },
    "Jenkins Wall Display": {
        "light": ["#BFD4FF", "#FF9180", "#FFF780", "#EEEEEE"],
    },
    "deepinv (seaborn cb)": {
        "light": ["#0173B2", "#DE8F05", "#029E73", "#D55E00", "#CC78BC"],
    },
}

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    src = open(os.path.join(here, "generate_colorblind_theme_examples.py")).read()
    THEMES = eval(re.search(r"THEMES = (\{.*?\n\})\n\n# data-viz", src, re.S).group(1))
    recs = []
    for key, t in THEMES.items():
        for mode in ("dark", "light"):
            sk = f"strip_{mode}"
            if sk not in t:
                continue
            colors = t[sk]
            res = {c: min_pair(colors, c) for c in ("deuteranopia", "protanopia", "tritanopia")}
            recs.append((t["name"], mode, res, verdict(res)))
    order = {"STRONG": 0, "ok": 1, "WEAK": 2}
    recs.sort(key=lambda r: (order[r[3]], -min(r[2][c][0] for c in r[2])))
    print(f"{'theme':28} {'mode':6} {'deut':>6} {'prot':>6} {'trit':>6}  verdict")
    for name, mode, res, v in recs:
        print(f"{name[:28]:28} {mode:6} {res['deuteranopia'][0]:6.1f} {res['protanopia'][0]:6.1f} "
              f"{res['tritanopia'][0]:6.1f}  {v}")
    s = sum(1 for r in recs if r[3] == "STRONG")
    o = sum(1 for r in recs if r[3] == "ok")
    w = sum(1 for r in recs if r[3] == "WEAK")
    print(f"\nSTRONG={s}  ok={o}  WEAK={w}   (thresholds: >=8 strong, >=3 ok, <3 weak)")

    # --- app/platform-level themes ---
    print("\n--- app/platform-level themes ---")
    print(f"{'app theme':28} {'mode':6} {'deut':>6} {'prot':>6} {'trit':>6}  verdict")
    arecs = []
    for name, modes in APP_THEMES.items():
        for mode, colors in modes.items():
            res = {c: min_pair(colors, c) for c in ("deuteranopia", "protanopia", "tritanopia")}
            arecs.append((name, mode, res, verdict(res)))
    arecs.sort(key=lambda r: (order[r[3]], -min(r[2][c][0] for c in r[2])))
    for name, mode, res, v in arecs:
        print(f"{name[:28]:28} {mode:6} {res['deuteranopia'][0]:6.1f} {res['protanopia'][0]:6.1f} "
              f"{res['tritanopia'][0]:6.1f}  {v}")
    sa = sum(1 for r in arecs if r[3] == "STRONG")
    oa = sum(1 for r in arecs if r[3] == "ok")
    wa = sum(1 for r in arecs if r[3] == "WEAK")
    print(f"\napp-level: STRONG={sa}  ok={oa}  WEAK={wa}")

if __name__ == "__main__":
    main()
