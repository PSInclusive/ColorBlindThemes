#requires -Version 7.0
<#
.SYNOPSIS
    Generates SVG examples for the colorblind-themes report.

.DESCRIPTION
    PowerShell-native port of generate_colorblind_theme_examples.py.

    Two artifact classes per the locked direction (precision instrument + real mockups):
      - Swatch plates: calibration-chart strips with hex labels, tick marks, and a
        four-row CVD simulation (Normal / Deuteranopia / Protanopia / Tritanopia)
        using the Machado et al. (2009) physiologically-based model.
      - Editor mockups: code-window renderings using each theme's real hexes.

    Deterministic, no dependencies beyond .NET.

.EXAMPLE
    pwsh scripts/New-ColorblindThemeExamples.ps1
    Writes assets/colorblind-themes/*.svg
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:OutDir = Join-Path $PSScriptRoot '..' 'assets' 'colorblind-themes'
$null = New-Item -ItemType Directory -Force -Path $script:OutDir

# ---------------------------------------------------------------- simulation
# Machado, Oliveira & Fernandes (2009), severity 1.0 (full dichromacy),
# IEEE TVCG 15(6):1291-1298, DOI 10.1109/TVCG.2009.113
$script:Machado = @{
    protanopia   = @(
        @(0.152286, 1.052583, -0.204868),
        @(0.114503, 0.786281, 0.099216),
        @(-0.003882, -0.048116, 1.051998))
    deuteranopia = @(
        @(0.367322, 0.860646, -0.227968),
        @(0.280085, 0.672501, 0.047413),
        @(-0.011820, 0.042940, 0.968881))
    tritanopia   = @(
        @(1.255528, -0.076749, -0.178779),
        @(-0.078411, 0.930809, 0.147602),
        @(0.004733, 0.691367, 0.303900))
}

function ConvertFrom-HexRgb {
    <#
    .SYNOPSIS
        Converts a '#RRGGBB' hex color to normalized sRGB components.
    .DESCRIPTION
        Returns [double[]]@(r, g, b) with each channel in the range 0.0-1.0.
    .EXAMPLE
        ConvertFrom-HexRgb '#FF8000'
    #>
    [CmdletBinding()]
    [OutputType([double[]])]
    param([Parameter(Mandatory)][string]$Hex)
    $h = $Hex.TrimStart('#')
    $r = [Convert]::ToInt32($h.Substring(0, 2), 16) / 255.0
    $g = [Convert]::ToInt32($h.Substring(2, 2), 16) / 255.0
    $b = [Convert]::ToInt32($h.Substring(4, 2), 16) / 255.0
    return [double[]]@($r, $g, $b)
}

function ConvertTo-HexRgb {
    <#
    .SYNOPSIS
        Converts normalized sRGB components back to an uppercase '#RRGGBB' string.
    .DESCRIPTION
        Each channel is clamped to 0-255 after scaling by 255, matching the
        Python rgb2hex helper (round-half-even via [Math]::Round, as CPython does).
    .EXAMPLE
        ConvertTo-HexRgb -Rgb @(1.0, 0.5, 0.0)
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][double[]]$Rgb)
    $channels = foreach ($c in $Rgb) {
        [Math]::Max(0, [Math]::Min(255, [int][Math]::Round($c * 255)))
    }
    return ('#{0:X2}{1:X2}{2:X2}' -f $channels)
}

function ConvertFrom-SRgbGamma {
    <#
    .SYNOPSIS
        Decodes one sRGB gamma-encoded channel to linear intensity.
    .DESCRIPTION
        Implements the sRGB EOTF segment: c/12.92 for c <= 0.04045, else
        ((c + 0.055) / 1.055) ^ 2.4.
    .EXAMPLE
        ConvertFrom-SRgbGamma 0.5
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory)][double]$C)
    if ($C -le 0.04045) { return $C / 12.92 }
    return [Math]::Pow(($C + 0.055) / 1.055, 2.4)
}

function ConvertTo-SRgbGamma {
    <#
    .SYNOPSIS
        Encodes one linear intensity channel to gamma sRGB.
    .DESCRIPTION
        Implements the sRGB OETF segment: 12.92*c for c <= 0.0031308, else
        1.055 * c ^ (1/2.4) - 0.055.
    .EXAMPLE
        ConvertTo-SRgbGamma 0.25
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory)][double]$C)
    if ($C -le 0.0031308) { return 12.92 * $C }
    return 1.055 * [Math]::Pow($C, 1 / 2.4) - 0.055
}

function Get-CvdSimulation {
    <#
    .SYNOPSIS
        Simulates a hex color under one full dichromacy (Machado 2009).
    .DESCRIPTION
        Applies the Machado, Oliveira & Fernandes (2009) matrix in linear sRGB,
        then re-encodes to gamma sRGB. Pass $Kind = $null to return the input
        unchanged.
    .EXAMPLE
        Get-CvdSimulation -HexColor '#E69F00' -Kind deuteranopia
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string]$HexColor,
        [Parameter()][AllowNull()][AllowEmptyString()][string]$Kind
    )
    if ([string]::IsNullOrEmpty($Kind)) { return $HexColor }
    $rgb = ConvertFrom-HexRgb $HexColor
    $rl = ConvertFrom-SRgbGamma $rgb[0]
    $gl = ConvertFrom-SRgbGamma $rgb[1]
    $bl = ConvertFrom-SRgbGamma $rgb[2]
    $m = $script:Machado[$Kind]
    $rr = $m[0][0] * $rl + $m[0][1] * $gl + $m[0][2] * $bl
    $gg = $m[1][0] * $rl + $m[1][1] * $gl + $m[1][2] * $bl
    $bb = $m[2][0] * $rl + $m[2][1] * $gl + $m[2][2] * $bl
    $enc = [double[]]@(
        (ConvertTo-SRgbGamma ([Math]::Max(0.0, [Math]::Min(1.0, $rr)))),
        (ConvertTo-SRgbGamma ([Math]::Max(0.0, [Math]::Min(1.0, $gg)))),
        (ConvertTo-SRgbGamma ([Math]::Max(0.0, [Math]::Min(1.0, $bb)))))
    $hex = ConvertTo-HexRgb $enc
    Write-Verbose "simulate $HexColor/$Kind -> $hex"
    return $hex
}

function Get-RelativeLuminance {
    <#
    .SYNOPSIS
        Computes the WCAG relative luminance of a hex color.
    .DESCRIPTION
        Linearizes each sRGB channel and returns
        0.2126*R + 0.7152*G + 0.0722*B.
    .EXAMPLE
        Get-RelativeLuminance '#0d1117'
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory)][string]$HexColor)
    $rgb = ConvertFrom-HexRgb $HexColor
    $rl = ConvertFrom-SRgbGamma $rgb[0]
    $gl = ConvertFrom-SRgbGamma $rgb[1]
    $bl = ConvertFrom-SRgbGamma $rgb[2]
    return 0.2126 * $rl + 0.7152 * $gl + 0.0722 * $bl
}

function Get-ForegroundFor {
    <#
    .SYNOPSIS
        Picks black or white foreground text for a background color.
    .DESCRIPTION
        Returns '#000000' when the background luminance exceeds 0.35,
        otherwise '#FFFFFF'.
    .EXAMPLE
        Get-ForegroundFor '#E69F00'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string]$Background)
    if ((Get-RelativeLuminance $Background) -gt 0.35) { return '#000000' }
    return '#FFFFFF'
}

function Get-ShadedColor {
    <#
    .SYNOPSIS
        Scales a hex color toward white by a factor.
    .DESCRIPTION
        Multiplies each gamma-encoded channel by $Factor (clamped to 1.0) and
        returns the result as hex.
    .EXAMPLE
        Get-ShadedColor -HexColor '#808080' -Factor 0.55
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string]$HexColor,
        [Parameter(Mandatory)][double]$Factor
    )
    $rgb = ConvertFrom-HexRgb $HexColor
    $scaled = [double[]]@(
        [Math]::Min(1.0, $rgb[0] * $Factor),
        [Math]::Min(1.0, $rgb[1] * $Factor),
        [Math]::Min(1.0, $rgb[2] * $Factor))
    return ConvertTo-HexRgb $scaled
}

function Protect-SvgText {
    <#
    .SYNOPSIS
        XML-escapes text for embedding in SVG markup.
    .DESCRIPTION
        Escapes &, <, >, and " in that order (amp first), matching the Python
        esc() helper.
    .EXAMPLE
        Protect-SvgText 'a < b & "c"'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    return $Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

function Format-PyFloat {
    <#
    .SYNOPSIS
        Formats a double the way Python's str(float) does.
    .DESCRIPTION
        Uses the round-trip 'R' format, then restores the trailing '.0' for
        integral values that .NET renders as a bare integer. Integers outside
        SVG float contexts never arrive here.
    .EXAMPLE
        Format-PyFloat 156.60000000000002   # -> 156.60000000000002
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][double]$Value)
    $s = $Value.ToString('R', [System.Globalization.CultureInfo]::InvariantCulture)
    if ($s -notmatch '[.Ee]') { $s += '.0' }
    return $s
}

$script:Font = "ui-monospace,'SF Mono',Menlo,Consolas,monospace"

# ---------------------------------------------------------------- swatch plates

function New-SwatchPlate {
    <#
    .SYNOPSIS
        Builds a calibration-chart SVG plate for a signal-color strip.
    .DESCRIPTION
        Labeled strip, then Normal/Deuteranopia/Protanopia/Tritanopia simulation
        rows. The plate carries a solid background matching the site's mode
        surface: dark plates on #0B0D10, light plates on #F4F1EA.
    .EXAMPLE
        New-SwatchPlate -Colors @('#E69F00','#56B4E9') -Labels @('orange','sky blue') -Mode dark
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string[]]$Colors,
        [Parameter(Mandatory)][string[]]$Labels,
        [Parameter()][int]$Width = 900,
        [Parameter()][AllowNull()][string]$Mode
    )
    $n = $Colors.Count
    $sw = [Math]::Min(124.0, ($Width - 176) / $n)
    $x0 = 118 + (($Width - 176) - $n * $sw) / 2  # center plates with few chips
    $sh = 46; $gap = 8
    $top = 26               # main strip starts near the top (no rotated labels above anymore)
    $labelRowH = 20         # horizontal label row under the main strip
    $rowPitch = $sh + $gap
    $rows = @(
        @('Normal', $null),
        @('Deuteranopia', 'deuteranopia'),
        @('Protanopia', 'protanopia'),
        @('Tritanopia', 'tritanopia'))
    # vertical layout: main strip at $top, then label row, then the 4 sim rows, then footer room
    $simTop = $top + $sh + $labelRowH + 8
    $h = $simTop + $rows.Count * $rowPitch + 30
    $w = $Width
    # solid plate background matching the site surface for the plate's mode
    $plateBg = if ($Mode -ne 'light') { '#0B0D10' } else { '#F4F1EA' }
    $labelFg = if ($Mode -ne 'light') { '#9aa3ab' } else { '#6b7280' }
    $footFg = if ($Mode -ne 'light') { '#a8a8a8' } else { '#7a7060' }
    $p = [System.Collections.Generic.List[string]]::new()
    $p.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" class=`"swatch`" width=`"$w`" height=`"$h`" viewBox=`"0 0 $w $h`" font-family=`"$($script:Font)`">")
    $p.Add("<rect x=`"0`" y=`"0`" width=`"$w`" height=`"$h`" rx=`"6`" fill=`"$plateBg`"/>")

    # swatch cells, main strip
    $y = $top
    for ($i = 0; $i -lt $n; $i++) {
        $c = $Colors[$i]
        $x = $x0 + $i * $sw
        $p.Add(('<rect x="{0:F1}" y="{1}" width="{2:F1}" height="{3}" rx="4" fill="{4}"/>' -f $x, $y, ($sw - 7), $sh, $c))
        $inner = Get-ForegroundFor $c
        $p.Add(('<text x="{0:F1}" y="{1}" font-size="9.5" fill="{2}" opacity="0.92">{3}</text>' -f ($x + 6), ($y + $sh - 7), $inner, $c.ToUpper()))
        # role label: horizontal, in a dedicated row directly under the main strip.
        # No rotation, no overlap with swatches; each label is centered on its own column.
        $lx = $x + ($sw - 7) / 2
        $ly = $y + $sh + 14
        $lab = $Labels[$i]
        if ($lab.Length -gt 14) { $lab = $lab.Substring(0, 14) }
        $p.Add(('<text x="{0:F1}" y="{1}" font-size="9" fill="{2}" text-anchor="middle">{3}</text>' -f $lx, $ly, $labelFg, (Protect-SvgText $lab)))
    }

    # simulation rows
    $y = $simTop
    foreach ($row in $rows) {
        $name = $row[0]; $kind = $row[1]
        $p.Add(('<text x="8" y="{0:F1}" font-size="11" fill="{1}">{2}</text>' -f ($y + $sh / 2 + 4), $labelFg, $name))
        for ($i = 0; $i -lt $n; $i++) {
            $shown = Get-CvdSimulation -HexColor $Colors[$i] -Kind $kind
            $x = $x0 + $i * $sw
            $p.Add(('<rect x="{0:F1}" y="{1}" width="{2:F1}" height="{3}" rx="4" fill="{4}"/>' -f $x, $y, ($sw - 7), $sh, $shown))
        }
        $y += $rowPitch
    }

    # footer: simulation model credit
    $p.Add("<text x=`"8`" y=`"$($h - 12)`" font-size=`"9`" fill=`"$footFg`">Simulated: Machado, Oliveira &amp; Fernandes (2009), severity 100% &#183; doi:10.1109/TVCG.2009.113</text>")
    $p.Add('</svg>')
    return ($p -join "`n")
}

# ---------------------------------------------------------------- editor mockups

function New-EditorMock {
    <#
    .SYNOPSIS
        Builds an editor-window SVG mock for one theme palette.
    .DESCRIPTION
        $Pal is a hashtable with keys name, variant, bg, fg, comment, plus
        optional gutter, status, and syntax roles: keyword, func, string,
        number, type, constant, variable, error, warn.
    .EXAMPLE
        New-EditorMock -Pal $Themes['github']['dark']
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][hashtable]$Pal,
        [Parameter()][int]$Width = 900
    )
    $bg = $Pal['bg']
    $fg = $Pal['fg']
    $c = @{
        keyword  = [string]($Pal.Contains('keyword') ? $Pal['keyword'] : $fg)
        func     = [string]($Pal.Contains('func') ? $Pal['func'] : $fg)
        string   = [string]($Pal.Contains('string') ? $Pal['string'] : $fg)
        number   = [string]($Pal.Contains('number') ? $Pal['number'] : $fg)
        type     = [string]($Pal.Contains('type') ? $Pal['type'] : $fg)
        constant = [string]($Pal.Contains('constant') ? $Pal['constant'] : $fg)
        variable = [string]($Pal.Contains('variable') ? $Pal['variable'] : $fg)
        comment  = [string]($Pal.Contains('comment') ? $Pal['comment'] : (Get-ShadedColor $fg 0.55))
        error    = [string]($Pal.Contains('error') ? $Pal['error'] : '#ff0000')
        warn     = [string]($Pal.Contains('warn') ? $Pal['warn'] : '#ffaa00')
    }
    $dark = (Get-RelativeLuminance $bg) -lt 0.2
    $gutter = if ($Pal.Contains('gutter')) { $Pal['gutter'] } else { Get-ShadedColor $bg $(if ($dark) { 1.25 } else { 0.965 }) }
    $chrome = if ($Pal.Contains('chrome')) { $Pal['chrome'] } else { Get-ShadedColor $bg $(if ($dark) { 1.35 } else { 0.93 }) }
    $status = if ($Pal.Contains('status')) { $Pal['status'] } elseif ($Pal.Contains('keyword')) { $Pal['keyword'] } else { $fg }
    $sel = if ($Pal.Contains('selection')) { $Pal['selection'] } else {
        Get-ShadedColor $(if ($Pal.Contains('func')) { $Pal['func'] } else { $fg }) $(if ($dark) { 0.35 } else { 1.0 })
    }
    $winH = 404
    $titleH = 30
    $statusH = 24
    $w = $Width
    $p = [System.Collections.Generic.List[string]]::new()
    $p.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" class=`"editor`" width=`"$w`" height=`"$winH`" viewBox=`"0 0 $w $winH`" font-family=`"$($script:Font)`">")

    # window frame
    $p.Add("<rect x=`"1`" y=`"1`" width=`"$($w - 2)`" height=`"$($winH - 2)`" rx=`"10`" fill=`"$bg`" stroke=`"$chrome`" stroke-width=`"1.5`"/>")
    # title bar
    $p.Add("<path d=`"M1 11 a10 10 0 0 1 10-10 h$($w - 22) a10 10 0 0 1 10 10 v$($titleH - 10) h-$($w - 2) z`" fill=`"$chrome`"/>")
    $dots = @('#FF5F57', '#FEBC2E', '#28C840')
    for ($i = 0; $i -lt $dots.Count; $i++) {
        $p.Add("<circle cx=`"$(24 + $i * 16)`" cy=`"$(Format-PyFloat ($titleH / 2 + 1))`" r=`"5`" fill=`"$($dots[$i])`"/>")
    }
    $title = "$(Protect-SvgText $Pal['name']) &#8212; $(Protect-SvgText $Pal['variant'])"
    $p.Add(('<text x="{0:F0}" y="{1}" font-size="11.5" fill="{2}" opacity="0.75" text-anchor="middle">{3}</text>' -f ($w / 2), (Format-PyFloat ($titleH / 2 + 4)), $fg, $title))

    # gutter
    $bodyY = $titleH + 1
    $p.Add("<rect x=`"1`" y=`"$bodyY`" width=`"52`" height=`"$($winH - $bodyY - $statusH)`" fill=`"$gutter`"/>")
    $p.Add("<line x1=`"53`" y1=`"$bodyY`" x2=`"53`" y2=`"$($winH - $statusH)`" stroke=`"$chrome`" stroke-width=`"1`"/>")

    # code lines (PowerShell): list of (lineno, segments, indent_px). segments = (text, colorkey)
    $lines = @(
        @(1, (, @('# render a palette as an SVG swatch plate', 'comment')), 0),
        @(2, @(@('function ', 'keyword'), @('New-SwatchPlate', 'func'), @(' {', 'fg')), 0),
        @(3, @(@('    param(', 'fg'), @('[string[]]', 'type'), @('$Colors', 'variable'), @(', ', 'fg'), @('[string[]]', 'type'), @('$Labels', 'variable'), @(')', 'fg')), 0),
        @(4, @(@('    ', 'fg'), @('$Width', 'fg'), @(' = ', 'keyword'), @('900', 'number'), @('  ', 'fg'), @('# px', 'comment')), 0),
        @(5, @(), 0),
        @(6, @(@('    foreach ', 'keyword'), @('(', 'fg'), @('$Color', 'variable'), @(' in ', 'keyword'), @('$Colors', 'variable'), @(') {', 'fg')), 0),
        @(7, @(@('        ', 'fg'), @('$Chip', 'variable'), @(' = ', 'keyword'), @('[Chip]::', 'type'), @('new(', 'func'), @('$Color', 'variable'), @(')', 'fg')), 0),
        @(8, @(@('        ', 'fg'), @('if ', 'keyword'), @('(', 'fg'), @('$Chip', 'variable'), @('.WcagRatio ', 'constant'), @('-lt ', 'keyword'), @('4.5', 'number'), @(') { ', 'fg'), @('throw ', 'keyword'), @('}', 'fg')), 0),
        @(9, @(), 0),
        @(10, @(@('        ', 'fg'), @('[Plate]::', 'type'), @('Add(', 'func'), @('$Chip', 'variable'), @(')', 'fg')), 0),
        @(11, (, @('    }', 'fg')), 0),
        @(12, (, @('}', 'fg')), 0),
        @(13, @(@('class ', 'keyword'), @('Chip', 'type'), @(' {', 'fg')), 0),
        @(14, @(@('    ', 'fg'), @('[bool]', 'type'), @('$Border', 'variable'), @(' = ', 'keyword'), @('$true', 'constant'), @('  ', 'fg'), @('# always visible', 'comment')), 0)
    )
    # one line gets a squiggly error underline, one a warn underline
    $errorLine = 8; $warnLine = 4
    $ly = $bodyY + 26
    $lh = 24
    foreach ($line in $lines) {
        $ln = $line[0]; $segs = $line[1]; $ind = $line[2]
        if ($ln -eq $warnLine) {
            # selection/highlight band behind a line to show selection color
            $p.Add("<rect x=`"53`" y=`"$($ly - 15)`" width=`"$($w - 56)`" height=`"$($lh - 2)`" fill=`"$sel`" opacity=`"0.28`"/>")
        }
        $p.Add("<text x=`"38`" y=`"$ly`" font-size=`"11`" fill=`"$fg`" opacity=`"0.45`" text-anchor=`"end`">$ln</text>")
        [double]$x = 66 + $ind
        $xIsInt = $true   # Python: x is int until the first += len(text) * 7.55
        foreach ($seg in $segs) {
            [string]$text = $seg[0]
            [string]$key = [string]$seg[1]
            $color = if ($key -eq 'fg') { $fg } else { $c[$key] }
            $xStr = if ($xIsInt) { "$([int]$x)" } else { Format-PyFloat $x }
            $p.Add("<text x=`"$xStr`" y=`"$ly`" font-size=`"12.5`" fill=`"$color`">$(Protect-SvgText $text)</text>")
            $x += $text.Length * 7.55
            $xIsInt = $false
        }
        if ($ln -eq $errorLine) {
            $p.Add("<path d=`"M66 $($ly + 4) q 4 -4 8 0 t 8 0 t 8 0 t 8 0 t 8 0 t 8 0`" fill=`"none`" stroke=`"$($c['error'])`" stroke-width=`"1.5`"/>")
        }
        if ($ln -eq $warnLine) {
            $p.Add("<path d=`"M66 $($ly + 4) q 4 -4 8 0 t 8 0 t 8 0`" fill=`"none`" stroke=`"$($c['warn'])`" stroke-width=`"1.5`"/>")
        }
        $ly += $lh
    }

    # status bar
    $sy = $winH - $statusH - 1
    $p.Add("<path d=`"M1 $sy h$($w - 2) v$($statusH - 9) a10 10 0 0 1 -10 10 h-$($w - 22) a10 10 0 0 1 -10-10 z`" fill=`"$status`"/>")
    $sfg = Get-ForegroundFor $status
    $p.Add("<text x=`"14`" y=`"$($sy + 16)`" font-size=`"10.5`" fill=`"$sfg`">&#9095; main*    New-SwatchPlate.ps1    pwsh 7.5    UTF-8    Ln 8, Col 24    spaces: 4</text>")
    $p.Add("<text x=`"$($w - 14)`" y=`"$($sy + 16)`" font-size=`"10.5`" fill=`"$sfg`" text-anchor=`"end`">LF  &#10003; prettier  CVD-safe</text>")
    $p.Add('</svg>')
    return ($p -join "`n")
}

function New-ComparePlate {
    <#
    .SYNOPSIS
        Builds a side-by-side SVG comparing a STRONG theme vs a WEAK theme.
    .DESCRIPTION
        Each theme is shown Normal plus one CVD view. Transparent background
        (sits on the page surface).
    .EXAMPLE
        New-ComparePlate -ThemeA 'GitButler (STRONG)' -ColorsA @('#99d9ff','#ffbf66') -LabelsA @('addition','deletion') -ThemeB 'GitHub (WEAK)' -ColorsB @('#ec8e2c','#d29922') -LabelsB @('keyword','warning') -Cvd deuteranopia
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string]$ThemeA,
        [Parameter(Mandatory)][string[]]$ColorsA,
        [Parameter(Mandatory)][string[]]$LabelsA,
        [Parameter(Mandatory)][string]$ThemeB,
        [Parameter(Mandatory)][string[]]$ColorsB,
        [Parameter(Mandatory)][string[]]$LabelsB,
        [Parameter(Mandatory)][string]$Cvd,
        [Parameter()][int]$Width = 900
    )
    $nA = $ColorsA.Count; $nB = $ColorsB.Count
    $sw = [Math]::Min(150.0, ($Width - 200) / [Math]::Max($nA, $nB))
    $sh = 56
    $blockH = $sh * 2 + 46
    $h = 40 + $blockH * 2 + 60
    $p = [System.Collections.Generic.List[string]]::new()
    $p.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" class=`"swatch`" width=`"$Width`" height=`"$h`" viewBox=`"0 0 $Width $h`" font-family=`"$($script:Font)`">")
    $cvdName = $Cvd.Substring(0, 1).ToUpper() + $Cvd.Substring(1)
    $p.Add("<text x=`"10`" y=`"24`" font-size=`"15`" font-weight=`"bold`" fill=`"#999`">Simulated under $cvdName (Machado 2009, 100%) &#8212; do the signal colors stay apart?</text>")
    $y = 50
    foreach ($block in @(@($ThemeA, $ColorsA, $LabelsA), @($ThemeB, $ColorsB, $LabelsB))) {
        $name = $block[0]; [string[]]$colors = $block[1]; [string[]]$labels = $block[2]
        $x0 = 150
        $p.Add("<text x=`"10`" y=`"$($y + $sh)`" font-size=`"13`" font-weight=`"bold`" fill=`"#bbb`">$(Protect-SvgText $name)</text>")
        for ($i = 0; $i -lt $labels.Count; $i++) {
            $lx = $x0 + $i * $sw + ($sw - 8) / 2
            $lab = $labels[$i]
            if ($lab.Length -gt 14) { $lab = $lab.Substring(0, 14) }
            $p.Add(('<text x="{0:F1}" y="{1}" font-size="9.5" fill="#888" text-anchor="middle">{2}</text>' -f $lx, ($y - 8), (Protect-SvgText $lab)))
        }
        foreach ($rowKind in @(@('Normal', $null), @($cvdName, $Cvd))) {
            $kind = $rowKind[1]
            for ($i = 0; $i -lt $colors.Count; $i++) {
                $shown = Get-CvdSimulation -HexColor $colors[$i] -Kind $kind
                $x = $x0 + $i * $sw
                $p.Add(('<rect x="{0:F1}" y="{1}" width="{2:F1}" height="{3}" rx="5" fill="{4}"/>' -f $x, $y, ($sw - 8), $sh, $shown))
                $p.Add(('<text x="{0:F1}" y="{1}" font-size="9.5" fill="{2}" opacity="0.9">{3}</text>' -f ($x + 6), ($y + $sh - 8), (Get-ForegroundFor $shown), $shown.ToUpper()))
            }
            $y += $sh
        }
        $y += 16
    }
    $p.Add('</svg>')
    return ($p -join "`n")
}

# ---------------------------------------------------------------- palettes (verified hexes from .research/*)

$script:Themes = [ordered]@{
    # ---- editors / IDE
    github = @{
        name = 'GitHub Colorblind'; variant_dark = 'Dark Colorblind'; variant_light = 'Light Colorblind'
        dark = @{ bg = '#0d1117'; fg = '#e6edf3'; comment = '#8b949e'; keyword = '#ec8e2c'; func = '#d2a8ff';
                  string = '#a5d6ff'; number = '#79c0ff'; type = '#ffa657'; constant = '#79c0ff'; variable = '#fdac54';
                  error = '#f0883e'; warn = '#d29922'; status = '#1f6feb' }
        light = @{ bg = '#ffffff'; fg = '#1f2328'; comment = '#57606a'; keyword = '#b35900'; func = '#6639ba';
                   string = '#0a3069'; number = '#0550ae'; type = '#953800'; constant = '#0550ae'; variable = '#8a4600';
                   error = '#b35900'; warn = '#9a6700'; status = '#0969da' }
        strip_dark = [string[]]@('#ec8e2c', '#58a6ff', '#d2a8ff', '#a5d6ff', '#79c0ff', '#d29922', '#39c5cf', '#be8fff')
        strip_dark_labels = [string[]]@('keyword', 'success*', 'func', 'string', 'number', 'warn', 'cyan', 'magenta')
        strip_light = [string[]]@('#b35900', '#0969da', '#6639ba', '#0a3069', '#0550ae', '#9a6700', '#1b7c83', '#8250df')
        strip_light_labels = [string[]]@('keyword', 'success*', 'func', 'string', 'number', 'warn', 'cyan', 'magenta')
        note = '*success/danger are remapped: green&#8594;blue, red&#8594;orange'
    }
    modus = @{
        name = 'Modus (deuteranopia)'; variant_dark = 'modus-vivendi-deuteranopia'; variant_light = 'modus-operandi-deuteranopia'
        dark = @{ bg = '#000000'; fg = '#ffffff'; comment = '#989898'; keyword = '#feacd0'; func = '#00d3d0';
                  string = '#cabf00'; number = '#ff5f59'; type = '#44bc44'; constant = '#2fafff'; variable = '#82b0ec';
                  error = '#ff5f59'; warn = '#cabf00'; status = '#2fafff' }
        light = @{ bg = '#ffffff'; fg = '#000000'; comment = '#595959'; keyword = '#721045'; func = '#005e8b';
                   string = '#695500'; number = '#a60000'; type = '#006800'; constant = '#0031a9'; variable = '#003497';
                   error = '#a60000'; warn = '#695500'; status = '#0031a9' }
        strip_dark = [string[]]@('#ff5f59', '#44bc44', '#cabf00', '#2fafff', '#feacd0', '#00d3d0')
        strip_dark_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        strip_light = [string[]]@('#a60000', '#006800', '#695500', '#0031a9', '#721045', '#005e8b')
        strip_light_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        note = 'WCAG AAA (&#8805;7:1) base; CVD variants re-route semantic colors'
    }
    pierre = @{
        name = 'Pierre'; variant_dark = 'Dark &#183; protanopia/deuteranopia'; variant_light = 'Light &#183; protanopia/deuteranopia'
        dark = @{ bg = '#0a0a0a'; fg = '#fafafa'; comment = '#8a8a8a'; keyword = '#b969f3'; func = '#009fff';
                  string = '#97c4ff'; number = '#69b1ff'; type = '#ffa359'; constant = '#97c4ff'; variable = '#ffa359';
                  error = '#fe8c2c'; warn = '#ffde80'; status = '#009fff' }
        light = @{ bg = '#ffffff'; fg = '#0a0a0a'; comment = '#6e6e6e'; keyword = '#8836c7'; func = '#009fff';
                   string = '#215584'; number = '#216cab'; type = '#ac6023'; constant = '#215584'; variable = '#ac6023';
                   error = '#ac6023'; warn = '#ffca00'; status = '#009fff' }
        strip_dark = [string[]]@('#009fff', '#97c4ff', '#fe8c2c', '#ffde80', '#68cdf2', '#b969f3', '#ffa359', '#69b1ff')
        strip_dark_labels = [string[]]@('accent', 'success', 'danger', 'warn', 'info', 'merge', 'tag', 'ansi.green')
        strip_light = [string[]]@('#009fff', '#216cab', '#ac6023', '#ffca00', '#2182a1', '#58287c')
        strip_light_labels = [string[]]@('accent', 'success', 'danger', 'warn', 'info', 'merge')
        note = 'Build-gated: Machado (2009) sim, &#916;E &#8805; 8&#8211;11 between roles'
    }
    datum = @{
        name = 'datum'; variant_dark = 'datum (dark)'; variant_light = 'datum (light)'
        dark = @{ bg = '#0f1318'; fg = '#ced3d9'; comment = '#5f6b7a'; keyword = '#fa94cd'; func = '#69b9f7';
                  string = '#54dcaa'; number = '#e8df69'; type = '#6ae5ec'; constant = '#f8bd5f'; variable = '#ced3d9';
                  error = '#f8bd5f'; warn = '#e8df69'; status = '#69b9f7' }
        light = @{ bg = '#f1f6fd'; fg = '#242a30'; comment = '#7a8899'; keyword = '#973070'; func = '#0176b8';
                   string = '#007553'; number = '#976700'; type = '#0d7a7f'; constant = '#a24500'; variable = '#242a30';
                   error = '#a24500'; warn = '#976700'; status = '#0176b8' }
        strip_dark = [string[]]@('#69b9f7', '#54dcaa', '#6ae5ec', '#e8df69', '#f8bd5f', '#fa94cd')
        strip_dark_labels = [string[]]@('blue', 'green', 'cyan', 'yellow', 'orange', 'pink')
        strip_light = [string[]]@('#0176b8', '#007553', '#0d7a7f', '#976700', '#a24500', '#973070')
        strip_light_labels = [string[]]@('blue', 'green', 'cyan', 'yellow', 'orange', 'pink')
        note = 'OKLCH hues anchored on Okabe&#8211;Ito; WCAG 2.2 + APCA verified'
    }
    dichromatic = @{
        name = 'Dichromatic'; variant_dark = 'vim-dichromatic'; variant_light = $null
        dark = @{ bg = '#080808'; fg = '#D0D0D0'; comment = '#808080'; keyword = '#AF5FAF'; func = '#5FAF87';
                  string = '#AFAF00'; number = '#D75F87'; type = '#87D7D7'; constant = '#D75F87'; variable = '#D0D0D0';
                  error = '#87005F'; warn = '#DFDF87'; status = '#5FAF87'; selection = '#87D7D7' }
        strip_dark = [string[]]@('#D75F87', '#AF5FAF', '#AFAF00', '#87D7D7', '#5FAF87', '#DFDF87')
        strip_dark_labels = [string[]]@('number', 'keyword', 'string', 'type', 'func', 'preproc')
        note = 'Built on Paul Tol&#8217;s SRON palette, adapted to xterm-256'
    }
    gentle = @{
        name = 'Gentle'; variant_dark = 'Gentle Dark'; variant_light = 'Gentle Light'
        dark = @{ bg = '#1C1E22'; fg = '#D8DCE2'; comment = '#6B7A87'; keyword = '#B794D4'; func = '#6AAFE6';
                  string = '#5FB49C'; number = '#E8A854'; type = '#56C4C8'; constant = '#70D8DC'; variable = '#A1A8B3';
                  error = '#E8A854'; warn = '#E8A854'; status = '#6AAFE6' }
        light = @{ bg = '#FDFCFA'; fg = '#3D424A'; comment = '#7F8A93'; keyword = '#7B5EA7'; func = '#2A6DB0';
                   string = '#1A7A6C'; number = '#B35D00'; type = '#0D7377'; constant = '#0D9488'; variable = '#5A6673';
                   error = '#B35D00'; warn = '#B35D00'; status = '#2A6DB0' }
        strip_dark = [string[]]@('#5FB49C', '#B794D4', '#6AAFE6', '#56C4C8', '#E8A854', '#70D8DC')
        strip_dark_labels = [string[]]@('string', 'keyword', 'func', 'type', 'number', 'constant')
        strip_light = [string[]]@('#1A7A6C', '#7B5EA7', '#2A6DB0', '#0D7377', '#B35D00', '#0D9488')
        strip_light_labels = [string[]]@('string', 'keyword', 'func', 'type', 'number', 'constant')
        note = 'Teal+orange replaces the red/green signal pair; WCAG AA'
    }
    blinds = @{
        name = 'Blinds'; variant_dark = 'Blinds Dark'; variant_light = 'Blinds Light'
        dark = @{ bg = '#1f1f1f'; fg = '#f7f7f7'; comment = '#515151'; keyword = '#aa3377'; func = '#ccbb44';
                  string = '#228833'; number = '#66CCEE'; type = '#ffffff'; constant = '#66CCEE'; variable = '#4477aa';
                  error = '#EE6677'; warn = '#ccbb44'; status = '#4477aa' }
        light = @{ bg = '#ffffff'; fg = '#3b3b3b'; comment = '#8a8a8a'; keyword = '#aa3377'; func = '#9a8600';
                   string = '#228833'; number = '#0099bb'; type = '#222222'; constant = '#0099bb'; variable = '#4477aa';
                   error = '#CC3311'; warn = '#9a8600'; status = '#4477aa' }
        strip_dark = [string[]]@('#4477AA', '#EE6677', '#228833', '#CCBB44', '#66CCEE', '#AA3377')
        strip_dark_labels = [string[]]@('variable', 'error', 'string', 'func', 'number', 'keyword')
        strip_light = [string[]]@('#4477AA', '#CC3311', '#228833', '#9a8600', '#0099bb', '#AA3377')
        strip_light_labels = [string[]]@('variable', 'error', 'string', 'func', 'number', 'keyword')
        note = 'Syntax roles taken from Paul Tol&#8217;s &#8220;bright&#8221; scheme'
    }
    monokai_deuteranopia = @{
        name = 'Monokai Deuteranopia'; variant_dark = 'Monokai Deuteranopia Colorblind'; variant_light = $null
        dark = @{ bg = '#0B1026'; fg = '#D4E4FF'; comment = '#6B7D94'; keyword = '#B28BFF'; func = '#DCDCAA';
                  string = '#E6C07B'; number = '#D4A0FF'; type = '#CC79A7'; constant = '#D4A0FF'; variable = '#D4A0FF';
                  error = '#56B4E9'; warn = '#F0E442'; status = '#56B4E9'; selection = '#1A2E55' }
        strip_dark = [string[]]@('#56B4E9', '#B28BFF', '#DCDCAA', '#E6C07B', '#CC79A7', '#D4A0FF', '#F0E442')
        strip_dark_labels = [string[]]@('caret', 'keyword', 'func', 'string', 'type', 'number', 'find')
        note = 'Blue&#8211;yellow axis; Okabe&#8211;Ito sky blue / reddish purple reused'
    }
    hakimi = @{
        name = 'Hakimi Deuteranopia Safe'; variant_dark = 'Hakimi Dark'; variant_light = 'Hakimi Light'
        dark = @{ bg = '#263238'; fg = '#e0e0e0'; comment = '#5d7078'; keyword = '#e878cf'; func = '#7ab2ff';
                  string = '#50c0b6'; number = '#ff9536'; type = '#8bdcff'; constant = '#e1be6a'; variable = '#91bfff';
                  error = '#ff8585'; warn = '#e1be6a'; status = '#7ab2ff' }
        light = @{ bg = '#ffead8'; fg = '#45494c'; comment = '#9b7f66'; keyword = '#7a255d'; func = '#336fd6';
                   string = '#00543f'; number = '#7a3f00'; type = '#005b9f'; constant = '#684100'; variable = '#336fd6';
                   error = '#6f1f65'; warn = '#684100'; status = '#336fd6' }
        strip_dark = [string[]]@('#7ab2ff', '#8bdcff', '#50c0b6', '#ff9536', '#e1be6a', '#ff8585', '#e878cf')
        strip_dark_labels = [string[]]@('blue', 'sky', 'teal', 'peach', 'yellow', 'red', 'pink')
        strip_light = [string[]]@('#336fd6', '#005b9f', '#00543f', '#7a3f00', '#684100', '#6f1f65', '#7a255d')
        strip_light_labels = [string[]]@('blue', 'sky', 'teal', 'peach', 'yellow', 'red', 'pink')
        note = 'Every color chosen from deuteranopia-safe sets; Zed/VS Code/Obsidian'
    }
    goofygoobers = @{
        name = 'Color Blind Themes'; variant_dark = 'Color Blind Themes (protan/deutan)'; variant_light = $null
        dark = @{ bg = '#141622'; fg = '#eff0eb'; comment = '#4D4E4F'; keyword = '#ff6ac1'; func = '#57c7ff';
                  string = '#5af78e'; number = '#ffbc58'; type = '#9aedfe'; constant = '#ff5c57'; variable = '#eff0eb';
                  error = '#ff5c57'; warn = '#ffbc58'; status = '#57c7ff' }
        strip_dark = [string[]]@('#ffbc58', '#9aedfe', '#5af78e', '#b76aff', '#ff5c57', '#ff6ac1', '#57c7ff')
        strip_dark_labels = [string[]]@('number', 'type', 'string', 'boolean', 'class', 'keyword', 'func')
        note = 'By a protanopia/deuteranopia author, for the same audience'
    }
    onedarkpro_cb = @{
        name = 'One Dark Pro Colorblind'; variant_dark = 'OneDarkPro Colorblind v1'; variant_light = $null
        dark = @{ bg = '#282c34'; fg = '#abb2bf'; comment = '#5c6370'; keyword = '#c678dd'; func = '#61afef';
                  string = '#dae36d'; number = '#90e9ff'; type = '#7DF9FF'; constant = '#e06c75'; variable = '#c678dd';
                  error = '#e06c75'; warn = '#dae36d'; status = '#61afef' }
        strip_dark = [string[]]@('#dae36d', '#c678dd', '#61afef', '#7DF9FF', '#90e9ff', '#e06c75')
        strip_dark_labels = [string[]]@('string', 'keyword', 'func', 'type', 'number', 'constant')
        note = 'One Dark Pro hues retuned onto distinguishable axes'
    }
    morimo = @{
        name = 'morimo'; variant_dark = 'morimo (dark)'; variant_light = $null
        dark = @{ bg = '#2a2a2e'; fg = '#b5d2a9'; comment = '#767b82'; keyword = '#b384b1'; func = '#9bb9d4';
                  string = '#a0c8cc'; number = '#d99872'; type = '#729e7b'; constant = '#d3c785'; variable = '#98b18e';
                  error = '#ff6e6e'; warn = '#e0d7a3'; status = '#9bb9d4' }
        strip_dark = [string[]]@('#ff6e6e', '#98c593', '#d3c785', '#9bb9d4', '#b384b1', '#a0c8cc', '#d99872')
        strip_dark_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'orange')
        note = 'Muted, lightness-separated ramps; performance-focused Neovim'
    }
    vision = @{
        name = 'vision.nvim'; variant_dark = 'vision (night)'; variant_light = $null
        dark = @{ bg = '#000022'; fg = '#ffffff'; comment = '#565f89'; keyword = '#bb9af7'; func = '#7aa2ee';
                  string = '#9ece6a'; number = '#ff9e64'; type = '#7dcfff'; constant = '#e0af68'; variable = '#eeffee';
                  error = '#f7768e'; warn = '#e0af68'; status = '#7aa2ee' }
        strip_dark = [string[]]@('#7aa2ee', '#7dcfff', '#bb9af7', '#ff9e64', '#e0af68', '#9ece6a', '#f7768e', '#1abc9c')
        strip_dark_labels = [string[]]@('blue', 'cyan', 'magenta', 'orange', 'yellow', 'green', 'red', 'teal')
        note = 'Tokyonight hues the CVD author could not tell apart, retuned'
    }
    # ---- terminals
    dalton = @{
        name = 'Dalton'; variant_dark = 'Dalton Dark'; variant_light = 'Dalton Bright'
        dark = @{ bg = '#1b1b1b'; fg = '#c8c9cc'; comment = '#666a70'; keyword = '#a050d0'; func = '#7aa2f7';
                  string = '#5b914e'; number = '#f07068'; type = '#56717f'; constant = '#c4c40c'; variable = '#c8c9cc';
                  error = '#d85050'; warn = '#eded02'; status = '#7aa2f7'; selection = '#333333' }
        light = @{ bg = '#f4f1eb'; fg = '#2e3038'; comment = '#8a8d95'; keyword = '#7830a8'; func = '#3060c8';
                   string = '#3a7530'; number = '#c83838'; type = '#3a5565'; constant = '#7a6d00'; variable = '#2e3038';
                   error = '#b83030'; warn = '#8a7d00'; status = '#3060c8' }
        strip_dark = [string[]]@('#d85050', '#5b914e', '#c4c40c', '#7aa2f7', '#a050d0', '#56717f')
        strip_dark_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        strip_light = [string[]]@('#b83030', '#3a7530', '#7a6d00', '#3060c8', '#7830a8', '#3a5565')
        strip_light_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        note = 'ANSI slots tuned for deuteranopia + protanopia separation'
    }
    hakarune_dracula = @{
        name = 'dracula-colorblind'; variant_dark = 'hakarune remix'; variant_light = $null
        dark = @{ bg = '#282a36'; fg = '#f8f8f2'; comment = '#6272a4'; keyword = '#BF6CFF'; func = '#50fa7b';
                  string = '#f1fa8c'; number = '#bd93f9'; type = '#8be9fd'; constant = '#bd93f9'; variable = '#f8f8f2';
                  error = '#FF7155'; warn = '#f1fa8c'; status = '#bd93f9' }
        strip_dark = [string[]]@('#FF7155', '#BF6CFF', '#f1fa8c', '#bd93f9', '#8be9fd', '#50fa7b')
        strip_dark_labels = [string[]]@('red→orange', 'green→purple', 'yellow', 'purple', 'cyan', 'green*')
        note = 'Only red/green ANSI slots remapped; rest of Dracula intact'
    }
    opo = @{
        name = 'Opo'; variant_dark = 'Opo Dark'; variant_light = 'Opo Light'
        dark = @{ bg = '#161410'; fg = '#d1d7df'; comment = '#7d7a72'; keyword = '#498beb'; func = '#74acff';
                  string = '#e08440'; number = '#dca331'; type = '#cd718f'; constant = '#33a397'; variable = '#d1d7df';
                  error = '#e08440'; warn = '#dca331'; status = '#498beb' }
        light = @{ bg = '#fdfcf9'; fg = '#24292f'; comment = '#5e5a55'; keyword = '#002c85'; func = '#007570';
                   string = '#a75000'; number = '#583500'; type = '#75254e'; constant = '#002c85'; variable = '#24292f';
                   error = '#a75000'; warn = '#583500'; status = '#005ccc' }
        strip_dark = [string[]]@('#e08440', '#33a397', '#dca331', '#498beb', '#cd718f', '#74acff')
        strip_dark_labels = [string[]]@('red→orange', 'green→teal', 'yellow', 'blue', 'magenta', 'cyan')
        strip_light = [string[]]@('#002c85', '#007570', '#a75000', '#005ccc', '#75254e', '#583500')
        strip_light_labels = [string[]]@('keyword', 'func', 'string', 'accent', 'type', 'warn')
        note = 'OKLCH; 363 build-time contrast checks + trichromacy CVD-distance gate; 21 export targets'
    }
    shroom = @{
        name = 'Shroom Space'; variant_dark = 'Shroom Space Deuteranopia'; variant_light = $null
        dark = @{ bg = '#24212E'; fg = '#CCC8D9'; comment = '#726D89'; keyword = '#BE9AF7'; func = '#FFCB6B';
                  string = '#E8C990'; number = '#E8C990'; type = '#E794D2'; constant = '#E8C990'; variable = '#E794D2';
                  error = '#E68484'; warn = '#FFCB6B'; status = '#BE9AF7' }
        strip_dark = [string[]]@('#BE9AF7', '#FFCB6B', '#E794D2', '#E8C990', '#E68484')
        strip_dark_labels = [string[]]@('keyword', 'func', 'variable', 'string', 'invalid')
        note = 'APCA + linear-RGB CVD simulation enforced in CI'
    }
    colorsafe = @{
        name = 'ColorSafe (JetBrains)'; variant_dark = 'Pro-Deutan Dark'; variant_light = $null
        dark = @{ bg = '#1C1C2E'; fg = '#E2E2F0'; comment = '#9CA3C8'; keyword = '#5BB8F5'; func = '#5BB8F5';
                  string = '#E6A020'; number = '#F0D060'; type = '#5BB8F5'; constant = '#F0D060'; variable = '#E2E2F0';
                  error = '#FF5F87'; warn = '#FFAB40'; status = '#5BB8F5' }
        strip_dark = [string[]]@('#5BB8F5', '#E6A020', '#F0D060', '#9CA3C8', '#FF5F87', '#FFAB40')
        strip_dark_labels = [string[]]@('blue (axis)', 'amber (axis)', 'number', 'comment', 'error', 'warn')
        note = 'Blue/amber axis; per-color WCAG tables in the .icls source'
    }
    cindervale = @{
        name = 'Cindervale Accessible'; variant_dark = 'Accessible Dark'; variant_light = $null
        dark = @{ bg = '#191517'; fg = '#F4E9E2'; comment = '#9E8379'; keyword = '#AF8CE0'; func = '#B0CDF1';
                  string = '#B0CDF1'; number = '#71A3A9'; type = '#BB901F'; constant = '#71A3A9'; variable = '#F4E9E2';
                  error = '#AF8CE0'; warn = '#BB901F'; status = '#B0CDF1' }
        strip_dark = [string[]]@('#AF8CE0', '#B0CDF1', '#BB901F', '#71A3A9', '#9E8379')
        strip_dark_labels = [string[]]@('keyword', 'func', 'type', 'number', 'comment')
        note = 'Five accents separated by hue AND a full lightness tier'
    }
    'ef-deuteranopia' = @{
        name = 'ef-themes'; variant_dark = 'ef-deuteranopia-dark'; variant_light = 'ef-deuteranopia-light'
        dark = @{ bg = '#000a1f'; fg = '#ddddee'; comment = '#5a6a8a'; keyword = '#b379bf'; func = '#3f90f0';
                  string = '#5faaef'; number = '#aa9f32'; type = '#3faa26'; constant = '#cf8560'; variable = '#ddddee';
                  error = '#cfaf00'; warn = '#aa9f32'; status = '#3f90f0'; cursor = '#ffff00' }
        light = @{ bg = '#f5f5ff'; fg = '#1a1a2f'; comment = '#7a7a9a'; keyword = '#ba35af'; func = '#375cd8';
                   string = '#375cd8'; number = '#805d00'; type = '#217a3c'; constant = '#d3303a'; variable = '#1a1a2f';
                   error = '#d3303a'; warn = '#805d00'; status = '#375cd8' }
        strip_dark = [string[]]@('#cf8560', '#3faa26', '#aa9f32', '#3f90f0', '#b379bf', '#5faaef')
        strip_dark_labels = [string[]]@('red→orange', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        strip_light = [string[]]@('#d3303a', '#217a3c', '#805d00', '#375cd8', '#ba35af', '#1a8a9f')
        strip_light_labels = [string[]]@('red', 'green', 'yellow', 'blue', 'magenta', 'cyan')
        note = 'Errors remapped to yellow (err→yellow-warmer), not red; Emacs, GPL-3.0'
    }
    pitaya = @{
        name = 'Pitaya Smoothie (JupyterLab)'; variant_dark = 'Pitaya Smoothie'; variant_light = $null
        dark = @{ bg = '#181036'; fg = '#f7f7f7'; comment = '#7a7a9a'; keyword = '#f25a92'; func = '#1abec2';
                  string = '#fad000'; number = '#a56cf5'; type = '#7998f2'; constant = '#f38672'; variable = '#f7f7f7';
                  error = '#f45c7b'; warn = '#fad000'; status = '#1abec2' }
        strip_dark = [string[]]@('#1abec2', '#f25a92', '#fad000', '#7998f2', '#a56cf5', '#f38672')
        strip_dark_labels = [string[]]@('teal', 'pink', 'yellow', 'periwinkle', 'lilac', 'orange')
        note = 'Teal/pink axis; WCAG AAA grid + protan/deutan/tritan sims in README; JupyterLab'
    }
    lxdeepsea = @{
        name = 'Lx Deep Sea (KDE Plasma)'; variant_dark = 'Lx Deep Sea'; variant_light = $null
        dark = @{ bg = '#302F2F'; fg = '#E0DEDB'; comment = '#787775'; keyword = '#508ED8'; func = '#96BFF0';
                  string = '#55AAFF'; number = '#5781B0'; type = '#96BFF0'; constant = '#8E79A5'; variable = '#D4D2CF';
                  error = '#FF1B13'; warn = '#55AAFF'; status = '#275EA0'; selection = '#184880' }
        strip_dark = [string[]]@('#FF1B13', '#57CF1F', '#55AAFF', '#508ED8', '#96BFF0', '#8E79A5')
        strip_dark_labels = [string[]]@('negative', 'positive', 'neutral', 'link', 'active', 'visited')
        note = 'Author-claimed red-green CVD; negatives/positive still differ mainly by hue'
    }
    grafana = @{
        name = 'Grafana Colorblind'; variant_dark = 'Deuteranopia/Protanopia Dark'; variant_light = 'Deuteranopia/Protanopia Light'
        dark = @{ bg = '#111217'; fg = '#d8d9da'; comment = '#7b8087'; keyword = '#FF7A18'; func = '#56B4E9';
                  string = '#FFF899'; number = '#CC79A7'; type = '#2EC4B6'; constant = '#56B4E9'; variable = '#d8d9da';
                  error = '#FF7A18'; warn = '#FFF899'; status = '#2EC4B6' }
        light = @{ bg = '#ffffff'; fg = '#1f2328'; comment = '#6a6e74'; keyword = '#FF9900'; func = '#0072B2';
                   string = '#6a5a00'; number = '#8a3b6b'; type = '#006F7A'; constant = '#0072B2'; variable = '#1f2328';
                   error = '#FF9900'; warn = '#8a7a00'; status = '#006F7A' }
        strip_dark = [string[]]@('#2EC4B6', '#FF7A18', '#FFF899', '#0072B2', '#E69F00', '#009E73', '#CC79A7', '#D55E00')
        strip_dark_labels = [string[]]@('success', 'error', 'warn', 'viz1', 'viz2', 'viz3', 'viz4', 'viz6')
        strip_light = [string[]]@('#006F7A', '#FF9900', '#FFEE52', '#0072B2', '#E69F00', '#009E73', '#CC79A7', '#D55E00')
        strip_light_labels = [string[]]@('success', 'error', 'warn', 'viz1', 'viz2', 'viz3', 'viz4', 'viz6')
        note = 'Merged 2026-03; success→teal, error→orange; viz palette is Wong/Okabe-Ito verbatim'
    }
    coder = @{
        name = 'coder/coder'; variant_dark = 'Dark Protan/Deuter'; variant_light = 'Light Protan/Deuter'
        dark = @{ bg = '#0d1117'; fg = '#e6edf3'; comment = '#8b949e'; keyword = '#f97583'; func = '#79c0ff';
                  string = '#a5d6ff'; number = '#79c0ff'; type = '#d2a8ff'; constant = '#79c0ff'; variable = '#e6edf3';
                  error = '#f97583'; warn = '#e879f9'; status = '#38bdf8' }
        strip_dark = [string[]]@('#f97583', '#38bdf8', '#e879f9', '#a78bfa')
        strip_dark_labels = [string[]]@('danger→vermilion', 'success→sky', 'warning→fuchsia', 'preview→violet')
        note = 'Okabe-Ito cited in source; Tailwind orange/sky/fuchsia/violet axes; 4 themes'
    }
    wireshark = @{
        name = 'Wireshark'; variant_dark = 'Protanopia & Deuteranopia Dark'; variant_light = 'Protanopia & Deuteranopia Light'
        dark = @{ bg = '#1e1f24'; fg = '#e8e8e8'; comment = '#8a8f98'; keyword = '#ff8a50'; func = '#56b4e9';
                  string = '#f0e442'; number = '#d995bf'; type = '#56b4e9'; constant = '#0072b2'; variable = '#e8e8e8';
                  error = '#ff8a50'; warn = '#f0e442'; status = '#56b4e9' }
        light = @{ bg = '#ffffff'; fg = '#1a1a1a'; comment = '#6e747c'; keyword = '#a33a00'; func = '#0072b2';
                   string = '#6a5a00'; type = '#0072b2'; number = '#8f4a78'; constant = '#0072b2'; variable = '#1a1a1a';
                   error = '#a33a00'; warn = '#c27a00'; status = '#0072b2' }
        strip_dark = [string[]]@('#56b4e9', '#f0e442', '#ff8a50', '#d995bf')
        strip_dark_labels = [string[]]@('success', 'warning', 'error', 'info')
        strip_light = [string[]]@('#0072b2', '#c27a00', '#a33a00', '#8f4a78')
        strip_light_labels = [string[]]@('success', 'warning', 'error', 'info')
        note = 'Okabe-Ito/Wong verbatim; CI gate suite_theme.py checks distinguishability per deficiency'
    }
    insomnia = @{
        name = 'Insomnia'; variant_dark = 'Dark Colorblind'; variant_light = $null
        dark = @{ bg = '#21262D'; fg = '#e6e6e6'; comment = '#7b8794'; keyword = '#58A6FF'; func = '#0080FF';
                  string = '#E8F086'; number = '#FFC20A'; type = '#A691AE'; constant = '#0080FF'; variable = '#e6e6e6';
                  error = '#CC5500'; warn = '#FFC20A'; status = '#0080FF' }
        strip_dark = [string[]]@('#0080FF', '#E8F086', '#A691AE', '#CC5500', '#FFC20A', '#58A6FF')
        strip_dark_labels = [string[]]@('POST/200', 'GET', 'PUT', 'DELETE', 'surprise', 'info')
        note = 'First-party core theme (Kong, 2021); blue/orange swap; the only API client CVD theme'
    }
    kiro = @{
        name = 'Kiro'; variant_dark = 'Color-blind safe Dark'; variant_light = 'Color-blind safe Light'
        dark = @{ bg = '#101418'; fg = '#e8ecef'; comment = '#7d8894'; keyword = '#CC79A7'; func = '#56B4E9';
                  string = '#F0E442'; number = '#DB5A00'; type = '#56B4E9'; constant = '#56B4E9'; variable = '#e8ecef';
                  error = '#DB5A00'; warn = '#F0E442'; status = '#56B4E9' }
        light = @{ bg = '#ffffff'; fg = '#1c2126'; comment = '#6f7880'; keyword = '#8f4a78'; func = '#0072B2';
                   string = '#6a5a00'; type = '#0072B2'; number = '#A43000'; constant = '#0072B2'; variable = '#1c2126';
                   error = '#A43000'; warn = '#AB9100'; status = '#0072B2' }
        strip_dark = [string[]]@('#56B4E9', '#F0E442', '#DB5A00', '#CC79A7')
        strip_dark_labels = [string[]]@('ok', 'warn', 'danger', 'accent')
        strip_light = [string[]]@('#0072B2', '#AB9100', '#A43000', '#8f4a78')
        strip_light_labels = [string[]]@('ok', 'warn', 'danger', 'accent')
        note = 'Okabe-Ito status hues; colorBlindTheme.test.tsx measures every status pair under 3 sims'
    }
    'gemini-cli' = @{
        name = 'Gemini CLI'; variant_dark = 'github-dark-colorblind'; variant_light = 'github-light-colorblind'
        dark = @{ bg = '#0d1117'; fg = '#e6edf3'; comment = '#8b949e'; keyword = '#ec8e2c'; func = '#d2a8ff';
                  string = '#a5d6ff'; number = '#79c0ff'; type = '#ffa657'; constant = '#79c0ff'; variable = '#fdac54';
                  error = '#f0883e'; warn = '#d29922'; status = '#1f6feb' }
        light = @{ bg = '#ffffff'; fg = '#1f2328'; comment = '#57606a'; keyword = '#b35900'; func = '#6639ba';
                   string = '#0a3069'; number = '#0550ae'; type = '#953800'; constant = '#0550ae'; variable = '#8a4600';
                   error = '#b35900'; warn = '#9a6700'; status = '#0969da' }
        strip_dark = [string[]]@('#ec8e2c', '#58a6ff', '#d2a8ff', '#a5d6ff', '#d29922')
        strip_dark_labels = [string[]]@('keyword', 'success', 'func', 'string', 'warn')
        strip_light = [string[]]@('#b35900', '#0969da', '#6639ba', '#0a3069', '#9a6700')
        strip_light_labels = [string[]]@('keyword', 'success', 'func', 'string', 'warn')
        note = 'Google first-party CLI shipping Primer colorblind tokens as built-ins'
    }
}

# data-viz palettes: (filename, title, colors, labels)
$script:DataViz = @(
    @('okabe-ito', [string[]]@('#E69F00', '#56B4E9', '#009E73', '#F0E442', '#0072B2', '#D55E00', '#CC79A7', '#000000'),
     [string[]]@('orange', 'sky blue', 'bluish green', 'yellow', 'blue', 'vermilion', 'reddish purple', 'black')),
    @('tol-bright', [string[]]@('#4477AA', '#EE6677', '#228833', '#CCBB44', '#66CCEE', '#AA3377', '#BBBBBB'),
     [string[]]@('blue', 'red', 'green', 'yellow', 'cyan', 'magenta', 'grey')),
    @('tol-vibrant', [string[]]@('#EE7733', '#0077BB', '#33BBEE', '#EE3377', '#CC3311', '#009988', '#BBBBBB'),
     [string[]]@('orange', 'blue', 'cyan', 'magenta', 'red', 'teal', 'grey')),
    @('tol-muted', [string[]]@('#CC6677', '#332288', '#DDCC77', '#117733', '#88CCEE', '#882255', '#44AA99', '#999933', '#AA4499'),
     [string[]]@('rose', 'indigo', 'sand', 'green', 'cyan', 'wine', 'teal', 'olive', 'purple')),
    @('tol-high-contrast', [string[]]@('#004488', '#DDAA33', '#BB5566'), [string[]]@('blue', 'yellow', 'red')),
    @('ibm-v1', [string[]]@('#648FFF', '#785EF0', '#DC267F', '#FE6100', '#FFB000'),
     [string[]]@('ultramarine', 'indigo', 'magenta', 'orange', 'gold')),
    @('carbon-categorical', [string[]]@('#6929C4', '#1192E8', '#005D5D', '#9F1853', '#FA4D56', '#570408', '#198038',
                            '#002D9C', '#EE538B', '#B28600', '#009D9A', '#012749', '#8A3800', '#A56EFF'),
     [string[]]@('purple70', 'cyan50', 'teal70', 'magenta70', 'red50', 'red90', 'green60', 'blue80',
      'magenta50', 'yellow50', 'teal50', 'blue90', 'orange70', 'purple50')),
    @('seaborn-colorblind', [string[]]@('#0173B2', '#DE8F05', '#029E73', '#D55E00', '#CC78BC', '#CA9161', '#FBAFE4', '#949494', '#ECE133', '#56B4E9'),
     [string[]]@('blue', 'orange', 'green', 'vermilion', 'purple', 'tan', 'pink', 'grey', 'yellow', 'sky')),
    @('tableau-colorblind10', [string[]]@('#006BA4', '#FF800E', '#ABABAB', '#595959', '#5F9ED1', '#C85200', '#898989', '#A2C8EC', '#FFBC79', '#CFCFCF'),
     [string[]]@('blue', 'orange', 'grey', 'dk grey', 'lt blue', 'dk orange', 'md grey', 'pale blue', 'pale orange', 'lt grey')),
    @('nichols-default', [string[]]@('#D81B60', '#1E88E5', '#FFC107', '#004D40'), [string[]]@('magenta', 'blue', 'yellow', 'teal')),
    @('colorbrewer-set2', [string[]]@('#66C2A5', '#FC8D62', '#8DA0CB', '#E78AC3', '#A6D854', '#FFD92F', '#E5C494', '#B3B3B3'),
     [string[]]@('teal', 'orange', 'lavender', 'pink', 'lime', 'yellow', 'tan', 'grey')),
    @('krzywinski-15', [string[]]@('#000000', '#004949', '#009292', '#FF6DB6', '#FFB6DB', '#490092', '#006DDB', '#B66DFF',
                       '#6DB6FF', '#B6DBFF', '#920000', '#924900', '#DB6D00', '#24FF24', '#FFFF6D'),
     [string[]]@('black', 'dk teal', 'teal', 'pink', 'lt pink', 'purple', 'blue', 'lt purple',
      'lt blue', 'pale blue', 'dk red', 'brown', 'orange', 'green', 'yellow')),
    @('crameri-batlow', [string[]]@('#011959', '#226061', '#828231', '#F29D6D', '#FACCFA'),
     [string[]]@('start', '&#188;', '&#189;', '&#190;', 'end')),
    @('cividis', [string[]]@('#00224E', '#434E6C', '#7D7C78', '#BCAE6C', '#FEE838'), [string[]]@('start', '&#188;', '&#189;', '&#190;', 'end')),
    @('viridis', [string[]]@('#440154', '#3B528B', '#21918C', '#5EC962', '#FDE725'), [string[]]@('start', '¼', '½', '¾', 'end')),
    @('petroff6', [string[]]@('#5790FC', '#F89C20', '#E42536', '#964A8B', '#9C9CA1', '#7A21DD'),
     [string[]]@('blue', 'orange', 'red', 'purple', 'grey', 'violet')),
    @('petroff10', [string[]]@('#3F90DA', '#FFA90E', '#BD1F01', '#94A4A2', '#832DB6', '#A96B59', '#E76300', '#B9AC70', '#717581', '#92DADD'),
     [string[]]@('blue', 'yellow', 'red', 'grey', 'purple', 'brown', 'orange', 'tan', 'dk grey', 'cyan')),
    @('plotly-safe', [string[]]@('#88CCEE', '#CC6677', '#DDCC77', '#117733', '#332288', '#AA4499', '#44AA99', '#999933', '#882255', '#661100', '#888888'),
     [string[]]@('cyan', 'rose', 'sand', 'green', 'indigo', 'purple', 'teal', 'olive', 'wine', 'brown', 'grey')),
    @('bokeh-colorblind', [string[]]@('#0072B2', '#E69F00', '#F0E442', '#009E73', '#56B4E9', '#D55E00', '#CC79A7', '#000000'),
     [string[]]@('blue', 'orange', 'yellow', 'bluish grn', 'sky blue', 'vermilion', 'red-purple', 'black')),
    @('zesty-four', [string[]]@('#F5793A', '#A95AA1', '#85C0F9', '#0F2080'), [string[]]@('orange', 'purple', 'sky', 'navy')),
    @('retro-four', [string[]]@('#601A4A', '#EE442F', '#63ACBE', '#F9F4EC'), [string[]]@('plum', 'vermilion', 'teal', 'paper'))
)

$script:AppPlates = @(
    @('gitea', 'dark', [string[]]@('#58a6ff', '#f0883e', '#d29922', '#ab7df8'), [string[]]@('1', '2', '3', '4')),
    @('gitea', 'light', [string[]]@('#0860cc', '#a84400', '#9a6700', '#8250df'), [string[]]@('1', '2', '3', '4')),
    @('simplecov', 'dark', [string[]]@('#6cb6ff', '#f0883e', '#f0e05a'), [string[]]@('1', '2', '3')),
    @('simplecov', 'light', [string[]]@('#0060a8', '#c2410c', '#9a6700'), [string[]]@('1', '2', '3')),
    @('plannotator', 'dark', [string[]]@('#4f83d1', '#c96e12', '#d9a839', '#35b6d9'), [string[]]@('1', '2', '3', '4')),
    @('plannotator', 'light', [string[]]@('#216cab', '#a55c1e', '#8f6400', '#0e7d9e'), [string[]]@('1', '2', '3', '4')),
    @('gitbutler', 'dark', [string[]]@('#99d9ff', '#ffbf66'), [string[]]@('addition', 'deletion')),
    @('gitbutler', 'light', [string[]]@('#0d59bf', '#bf590d'), [string[]]@('addition', 'deletion')),
    @('iamb', 'dark', [string[]]@('#D55E00', '#E69F00', '#F0E442', '#0072B2', '#56B4E9', '#009E73', '#CC79A7'), [string[]]@('1', '2', '3', '4', '5', '6', '7')),
    @('cura', 'dark', [string[]]@('#ff4000', '#009c80', '#ffff56', '#00ffff', '#0064ff'), [string[]]@('1', '2', '3', '4', '5')),
    @('openfront', 'dark', [string[]]@('#0072b2', '#56b4e9', '#d55e00', '#009e73', '#cc79a7', '#f0e442', '#e69f00'), [string[]]@('1', '2', '3', '4', '5', '6', '7')),
    @('talishar-deuteranopia', 'dark', [string[]]@('#33aaee', '#cc5599', '#eeaa11', '#cc5522', '#55bb88', '#8855aa', '#aa2244'), [string[]]@('1', '2', '3', '4', '5', '6', '7')),
    @('talishar-protanopia', 'dark', [string[]]@('#11bbff', '#ee1100', '#ff8811', '#118899', '#99ff11', '#bb22aa', '#aa1144'), [string[]]@('1', '2', '3', '4', '5', '6', '7')),
    @('talishar-tritanopia', 'dark', [string[]]@('#22eeff', '#ee2200', '#eeaa44', '#aa88ff', '#22aa00', '#6666cc', '#992255'), [string[]]@('1', '2', '3', '4', '5', '6', '7')),
    @('narmi', 'light', [string[]]@('#6F6BAD', '#1A56B0', '#6F004F', '#4B0200'), [string[]]@('1', '2', '3', '4')),
    @('moira', 'light', [string[]]@('#00771e', '#ffc107', '#ff5722', '#9e9e9e'), [string[]]@('1', '2', '3', '4')),
    @('jenkins', 'light', [string[]]@('#BFD4FF', '#FF9180', '#FFF780', '#EEEEEE'), [string[]]@('blue', 'red', 'yellow', 'grey')),
    @('deepinv', 'light', [string[]]@('#0173B2', '#DE8F05', '#029E73', '#D55E00', '#CC78BC'), [string[]]@('1', '2', '3', '4', '5'))
)

$script:Comparisons = @(
    @('compare-deuteranopia', 'deuteranopia',
     'GitButler (STRONG)', [string[]]@('#99d9ff', '#ffbf66'), [string[]]@('addition', 'deletion'),
     'GitHub (WEAK)', [string[]]@('#ec8e2c', '#d29922'), [string[]]@('keyword', 'warning')),
    @('compare-protanopia', 'protanopia',
     'Wireshark (STRONG)', [string[]]@('#56b4e9', '#f0e442', '#ff8a50'), [string[]]@('success', 'warning', 'error'),
     'coder (WEAK)', [string[]]@('#38bdf8', '#e879f9'), [string[]]@('success/sky', 'warning/fuchsia')),
    @('compare-tritanopia', 'tritanopia',
     'Kiro (STRONG)', [string[]]@('#56B4E9', '#F0E442', '#DB5A00', '#CC79A7'), [string[]]@('ok', 'warn', 'danger', 'accent'),
     'Gentle light (WEAK)', [string[]]@('#7B5EA7', '#2A6DB0'), [string[]]@('keyword', 'function'))
)

# ---------------------------------------------------------------- build

function ConvertTo-Slug {
    <#
    .SYNOPSIS
        Converts a theme key to a filename slug.
    .DESCRIPTION
        Lowercases and replaces spaces and underscores with hyphens.
    .EXAMPLE
        ConvertTo-Slug 'monokai_deuteranopia'   # -> monokai-deuteranopia
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string]$Name)
    return $Name.ToLower().Replace(' ', '-').Replace('_', '-')
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$built = [System.Collections.Generic.List[string]]::new()

foreach ($key in $script:Themes.Keys) {
    $t = $script:Themes[$key]
    foreach ($mode in @('dark', 'light')) {
        if (-not $t.Contains($mode)) { continue }
        $pal = @{} + $t[$mode]
        $pal['name'] = $t['name']
        $pal['variant'] = if ($mode -eq 'dark') { $t['variant_dark'] } elseif ($null -ne $t['variant_light']) { $t['variant_light'] } else { '' }
        $svg = New-EditorMock -Pal $pal
        $fn = "$(ConvertTo-Slug $key)-$mode-editor.svg"
        Write-Verbose "writing $fn"
        [System.IO.File]::WriteAllText((Join-Path $script:OutDir $fn), $svg, $utf8NoBom)
        $built.Add($fn)
    }
    foreach ($mode in @('dark', 'light')) {
        $stripKey = "strip_$mode"
        if (-not $t.Contains($stripKey)) { continue }
        $svg = New-SwatchPlate -Colors $t[$stripKey] -Labels $t["${stripKey}_labels"] -Mode $mode
        $fn = "$(ConvertTo-Slug $key)-$mode-strip.svg"
        Write-Verbose "writing $fn"
        [System.IO.File]::WriteAllText((Join-Path $script:OutDir $fn), $svg, $utf8NoBom)
        $built.Add($fn)
    }
}

foreach ($dv in $script:DataViz) {
    $svg = New-SwatchPlate -Colors $dv[1] -Labels $dv[2] -Mode 'dark'
    $fn = "dataviz-$($dv[0]).svg"
    Write-Verbose "writing $fn"
    [System.IO.File]::WriteAllText((Join-Path $script:OutDir $fn), $svg, $utf8NoBom)
    $built.Add($fn)
}

foreach ($ap in $script:AppPlates) {
    $svg = New-SwatchPlate -Colors $ap[2] -Labels $ap[3] -Mode $ap[1]
    $fn = "$($ap[0])-$($ap[1])-strip.svg"
    Write-Verbose "writing $fn"
    [System.IO.File]::WriteAllText((Join-Path $script:OutDir $fn), $svg, $utf8NoBom)
    $built.Add($fn)
}

foreach ($cmp in $script:Comparisons) {
    $svg = New-ComparePlate -ThemeA $cmp[2] -ColorsA $cmp[3] -LabelsA $cmp[4] -ThemeB $cmp[5] -ColorsB $cmp[6] -LabelsB $cmp[7] -Cvd $cmp[1]
    $fn = "$($cmp[0]).svg"
    Write-Verbose "writing $fn"
    [System.IO.File]::WriteAllText((Join-Path $script:OutDir $fn), $svg, $utf8NoBom)
    $built.Add($fn)
}

$relOut = [System.IO.Path]::GetRelativePath((Get-Location).Path, $script:OutDir)
Write-Output "$($built.Count) SVGs written to $relOut"
foreach ($b in $built) {
    Write-Output "  $b"
}
