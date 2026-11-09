#requires -Version 7.0
<#
.SYNOPSIS
    Independent CVD verification of the colorblind-themes catalog.

.DESCRIPTION
    PowerShell-native port of verify_colorblind_themes.py.

    For every theme in New-ColorblindThemeExamples.ps1's THEMES table, simulate its
    semantic/signal color strip under each dichromacy (Machado, Oliveira & Fernandes
    2009, severity 100%) and compute the minimum pairwise CIEDE2000 (ΔE00) distance
    between signal colors. A small minimum means two signal colors collapse toward
    each other for that deficiency.

    CAVEATS (read before citing a number):
      - ΔE00 thresholds are rough: ~1 is just-noticeable, <3 is hard to separate on
        screen, >8 is clearly different. They are NOT a pass/fail for usability.
      - Many themes deliberately add a luminance (lightness) difference between hues
        that share an axis, so a low ΔE00 pair can still be separable by brightness.
        This metric measures hue+lightness collapse together, so it partially
        captures that, but it does not model font-weight, icons, or redundant
        non-color encodings.
      - A theme designed for deuteranopia only may legitimately collapse under
        tritanopia; read the "targets" column in the report before judging a
        cross-deficiency number.
      - The strip is a representative subset of signal colors, chosen per theme; a
        theme's full palette may contain closer or more-distant pairs than the
        strip shows.

.EXAMPLE
    pwsh scripts/Test-ColorblindThemes.ps1
    Prints the per-theme verification table and verdict tallies.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Machado 2009 (severity 1.0), linear sRGB -------------------------------------
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

function ConvertFrom-SRgbGamma {
    <#
    .SYNOPSIS
        Decodes one sRGB gamma-encoded channel to linear intensity.
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
        Applies the Machado 2009 matrix in linear sRGB, re-encodes to gamma sRGB.
        Pass $Kind = $null/empty to return the input unchanged.
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
    $channels = foreach ($c in $enc) { [int][Math]::Round($c * 255) }
    return ('#{0:X2}{1:X2}{2:X2}' -f $channels)
}

# --- sRGB -> CIE L*a*b* (D65) ------------------------------------------------------
function ConvertTo-Lab {
    <#
    .SYNOPSIS
        Converts a hex sRGB color to CIE L*a*b* (D65 illuminant).
    .DESCRIPTION
        Returns [double[]]@(L, a, b) via the standard sRGB->XYZ->Lab chain.
    .EXAMPLE
        ConvertTo-Lab '#E69F00'
    #>
    [CmdletBinding()]
    [OutputType([double[]])]
    param([Parameter(Mandatory)][string]$Hex)
    $rgb = ConvertFrom-HexRgb $Hex
    $r = ConvertFrom-SRgbGamma $rgb[0]
    $g = ConvertFrom-SRgbGamma $rgb[1]
    $b = ConvertFrom-SRgbGamma $rgb[2]
    $x = $r * 0.4124564 + $g * 0.3575761 + $b * 0.1804375
    $y = $r * 0.2126729 + $g * 0.7151522 + $b * 0.0721750
    $z = $r * 0.0193339 + $g * 0.1191920 + $b * 0.9503041
    $xn = 0.95047; $yn = 1.0; $zn = 1.08883
    $fx = Get-LabF ($x / $xn)
    $fy = Get-LabF ($y / $yn)
    $fz = Get-LabF ($z / $zn)
    return [double[]]@((116 * $fy - 16), (500 * ($fx - $fy)), (200 * ($fy - $fz)))
}

function Get-LabF {
    <#
    .SYNOPSIS
        Lab helper function: cube root above the epsilon threshold, linear below.
    .EXAMPLE
        Get-LabF 0.5
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory)][double]$T)
    if ($T -gt 0.008856) { return [Math]::Pow($T, 1 / 3) }
    return 7.787 * $T + 16 / 116
}

# --- CIEDE2000 (Sharma et al. 2005) ------------------------------------------------
function Get-Ciede2000 {
    <#
    .SYNOPSIS
        Computes the CIEDE2000 color difference between two Lab colors.
    .DESCRIPTION
        Implementation follows Sharma, Wu & Dalal (2005). Each Lab argument is
        [double[]]@(L, a, b).
    .EXAMPLE
        Get-Ciede2000 -Lab1 @(50, 2.5, 0) -Lab2 @(50, 0, 0)
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory)][double[]]$Lab1,
        [Parameter(Mandatory)][double[]]$Lab2
    )
    $L1 = $Lab1[0]; $a1 = $Lab1[1]; $b1 = $Lab1[2]
    $L2 = $Lab2[0]; $a2 = $Lab2[1]; $b2 = $Lab2[2]
    $C1 = [Math]::Sqrt($a1 * $a1 + $b1 * $b1)
    $C2 = [Math]::Sqrt($a2 * $a2 + $b2 * $b2)
    $Cb = ($C1 + $C2) / 2
    $G = if ($Cb -gt 0) { 0.5 * (1 - [Math]::Sqrt(([Math]::Pow($Cb, 7)) / ([Math]::Pow($Cb, 7) + [Math]::Pow(25, 7)))) } else { 0.0 }
    $a1p = (1 + $G) * $a1
    $a2p = (1 + $G) * $a2
    $C1p = [Math]::Sqrt($a1p * $a1p + $b1 * $b1)
    $C2p = [Math]::Sqrt($a2p * $a2p + $b2 * $b2)
    $h1p = Get-HueAngle $a1p $b1
    $h2p = Get-HueAngle $a2p $b2
    $dLp = $L2 - $L1
    $dCp = $C2p - $C1p
    if ($C1p * $C2p -eq 0) {
        $dhp = 0.0
    } else {
        $dh = $h2p - $h1p
        if ($dh -gt 180) { $dh -= 360 }
        elseif ($dh -lt -180) { $dh += 360 }
        $dhp = $dh
    }
    $dHp = 2 * [Math]::Sqrt($C1p * $C2p) * [Math]::Sin(($dhp / 2) * [Math]::PI / 180)
    $Lbp = ($L1 + $L2) / 2
    $Cbp = ($C1p + $C2p) / 2
    if ($C1p * $C2p -eq 0) {
        $hbp = $h1p + $h2p
    } else {
        $dh = [Math]::Abs($h1p - $h2p)
        if ($dh -le 180) { $hbp = ($h1p + $h2p) / 2 }
        elseif ($h1p + $h2p -lt 360) { $hbp = ($h1p + $h2p + 360) / 2 }
        else { $hbp = ($h1p + $h2p - 360) / 2 }
    }
    $T = (1 - 0.17 * [Math]::Cos(($hbp - 30) * [Math]::PI / 180) + 0.24 * [Math]::Cos(2 * $hbp * [Math]::PI / 180) +
          0.32 * [Math]::Cos((3 * $hbp + 6) * [Math]::PI / 180) - 0.20 * [Math]::Cos((4 * $hbp - 63) * [Math]::PI / 180))
    $dtheta = 30 * [Math]::Exp(-([Math]::Pow(($hbp - 275) / 25, 2)))
    $Rc = if ($Cbp -gt 0) { 2 * [Math]::Sqrt(([Math]::Pow($Cbp, 7)) / ([Math]::Pow($Cbp, 7) + [Math]::Pow(25, 7))) } else { 0.0 }
    $Sl = 1 + ((0.015 * [Math]::Pow($Lbp - 50, 2)) / [Math]::Sqrt(20 + [Math]::Pow($Lbp - 50, 2)))
    $Sc = 1 + 0.045 * $Cbp
    $Sh = 1 + 0.015 * $Cbp * $T
    $Rt = -[Math]::Sin(2 * $dtheta * [Math]::PI / 180) * $Rc
    return [Math]::Sqrt([Math]::Pow($dLp / $Sl, 2) + [Math]::Pow($dCp / $Sc, 2) + [Math]::Pow($dHp / $Sh, 2) +
                        $Rt * ($dCp / $Sc) * ($dHp / $Sh))
}

function Get-HueAngle {
    <#
    .SYNOPSIS
        Hue angle in degrees for CIEDE2000, in [0, 360).
    .EXAMPLE
        Get-HueAngle 1.5 -2
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory)][double]$A,
        [Parameter(Mandatory)][double]$B
    )
    if ($A -eq 0 -and $B -eq 0) { return 0.0 }
    $h = [Math]::Atan2($B, $A) * 180 / [Math]::PI
    if ($h -lt 0) { return $h + 360 }
    return $h
}

function Get-MinPairDistance {
    <#
    .SYNOPSIS
        Minimum pairwise CIEDE2000 among a color strip under one dichromacy.
    .DESCRIPTION
        Simulates each color under $Cvd, converts to Lab, and returns a
        PSCustomObject with Distance and Pair (the two hex colors).
    .EXAMPLE
        Get-MinPairDistance -Colors @('#E69F00','#56B4E9') -Cvd deuteranopia
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)][string[]]$Colors,
        [Parameter(Mandatory)][string]$Cvd
    )
    $labs = [System.Collections.Generic.List[double[]]]::new()
    foreach ($c in $Colors) {
        $sim = Get-CvdSimulation -HexColor $c -Kind $Cvd
        $labs.Add((ConvertTo-Lab -Hex $sim))
    }
    $best = 1e9
    $bestPair = $null
    for ($i = 0; $i -lt $labs.Count; $i++) {
        for ($j = $i + 1; $j -lt $labs.Count; $j++) {
            $d = Get-Ciede2000 -Lab1 $labs[$i] -Lab2 $labs[$j]
            if ($d -lt $best) {
                $best = $d
                $bestPair = @($Colors[$i], $Colors[$j])
            }
        }
    }
    Write-Verbose "min pair under ${Cvd}: dE00=$([Math]::Round($best, 2)) ($($bestPair -join ' vs '))"
    return [PSCustomObject]@{ Distance = $best; Pair = $bestPair }
}

function Get-Verdict {
    <#
    .SYNOPSIS
        Maps the worst per-deficiency ΔE00 to a STRONG/OK/WEAK verdict.
    .DESCRIPTION
        STRONG when worst >= 8, OK when >= 3, otherwise WEAK.
    .EXAMPLE
        Get-Verdict -Results $res
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][hashtable]$Results)
    $worst = ($Results.Values | ForEach-Object { $_.Distance } | Measure-Object -Minimum).Minimum
    if ($worst -ge 8) { return 'STRONG' }
    if ($worst -ge 3) { return 'OK' }
    return 'WEAK'
}

# App/platform-level themes ship real semantic palettes (see .research/09, .research/10).
# Keyed: name -> {mode: [signal colors]} — the small good/bad/status set each app shows.
$script:AppThemes = [ordered]@{
    'Gitea' = [ordered]@{
        dark = [string[]]@('#58a6ff', '#f0883e', '#d29922', '#ab7df8')
        light = [string[]]@('#0860cc', '#a84400', '#9a6700', '#8250df')
    }
    'SimpleCov' = [ordered]@{
        dark = [string[]]@('#6cb6ff', '#f0883e', '#f0e05a')
        light = [string[]]@('#0060a8', '#c2410c', '#9a6700')
    }
    'plannotator' = [ordered]@{
        dark = [string[]]@('#4f83d1', '#c96e12', '#d9a839', '#35b6d9')
        light = [string[]]@('#216cab', '#a55c1e', '#8f6400', '#0e7d9e')
    }
    'GitButler' = [ordered]@{
        dark = [string[]]@('#99d9ff', '#ffbf66')
        light = [string[]]@('#0d59bf', '#bf590d')
    }
    'iamb (okabe-ito-dark)' = [ordered]@{
        dark = [string[]]@('#D55E00', '#E69F00', '#F0E442', '#0072B2', '#56B4E9', '#009E73', '#CC79A7')
    }
    'Cura Colorblind Assist' = [ordered]@{
        dark = [string[]]@('#ff4000', '#009c80', '#ffff56', '#00ffff', '#0064ff')
    }
    'OpenFront.io' = [ordered]@{
        dark = [string[]]@('#0072b2', '#56b4e9', '#d55e00', '#009e73', '#cc79a7', '#f0e442', '#e69f00')
    }
    'Talishar deuteranopia' = [ordered]@{
        dark = [string[]]@('#33aaee', '#cc5599', '#eeaa11', '#cc5522', '#55bb88', '#8855aa', '#aa2244')
    }
    'Talishar protanopia' = [ordered]@{
        dark = [string[]]@('#11bbff', '#ee1100', '#ff8811', '#118899', '#99ff11', '#bb22aa', '#aa1144')
    }
    'Talishar tritanopia' = [ordered]@{
        dark = [string[]]@('#22eeff', '#ee2200', '#eeaa44', '#aa88ff', '#22aa00', '#6666cc', '#992255')
    }
    'Insomnia' = [ordered]@{
        dark = [string[]]@('#0080FF', '#E8F086', '#A691AE', '#CC5500', '#FFC20A', '#58A6FF')
    }
    'narmi red-green' = [ordered]@{
        light = [string[]]@('#6F6BAD', '#1A56B0', '#6F004F', '#4B0200')
    }
    'Moira' = [ordered]@{
        light = [string[]]@('#00771e', '#ffc107', '#ff5722', '#9e9e9e')
    }
    'Jenkins Wall Display' = [ordered]@{
        light = [string[]]@('#BFD4FF', '#FF9180', '#FFF780', '#EEEEEE')
    }
    'deepinv (seaborn cb)' = [ordered]@{
        light = [string[]]@('#0173B2', '#DE8F05', '#029E73', '#D55E00', '#CC78BC')
    }
}

function Get-ThemesTable {
    <#
    .SYNOPSIS
        Loads the THEMES table from New-ColorblindThemeExamples.ps1.
    .DESCRIPTION
        Dot-sources the generator in a child scope would execute its build step,
        so instead the script text is parsed: everything up to the build section
        is executed in an isolated runspace-like scope via ScriptBlock, and the
        resulting [ordered]@{} literal is returned. The generator is the single
        source of truth for the catalog (same as the Python verifier reading
        THEMES out of the Python generator).
    .EXAMPLE
        $themes = Get-ThemesTable
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()
    $genPath = Join-Path $PSScriptRoot 'New-ColorblindThemeExamples.ps1'
    $src = [System.IO.File]::ReadAllText($genPath)
    # Evaluate only the data assignment: extract the [ordered]@{ ... } block for $script:Themes
    $m = [regex]::Match($src, '(?s)\$script:Themes = (\[ordered\]@\{.*?\n\})')
    if (-not $m.Success) { throw "Could not locate `$script:Themes table in $genPath" }
    $themes = [ScriptBlock]::Create($m.Groups[1].Value).Invoke()
    return $themes[0]
}

$recs = [System.Collections.Generic.List[object]]::new()
$themes = Get-ThemesTable
foreach ($key in $themes.Keys) {
    $t = $themes[$key]
    foreach ($mode in @('dark', 'light')) {
        $sk = "strip_$mode"
        if (-not $t.Contains($sk)) { continue }
        [string[]]$colors = $t[$sk]
        $res = @{}
        foreach ($c in @('deuteranopia', 'protanopia', 'tritanopia')) {
            $res[$c] = Get-MinPairDistance -Colors $colors -Cvd $c
        }
        $recs.Add([PSCustomObject]@{
            Name = [string]$t['name']; Mode = $mode; Results = $res; Verdict = (Get-Verdict -Results $res)
            Idx = $recs.Count   # Python's sort is stable; keep insertion order on ties
        })
    }
}

$order = @{ STRONG = 0; OK = 1; WEAK = 2 }
$sorted = $recs | Sort-Object { $order[$_.Verdict] }, { -($_.Results.Values | ForEach-Object Distance | Measure-Object -Minimum).Minimum }, { $_.Idx }

Write-Output ('{0,-28} {1,-6} {2,6} {3,6} {4,6}  verdict' -f 'theme', 'mode', 'deut', 'prot', 'trit')
foreach ($r in $sorted) {
    $name = $r.Name
    if ($name.Length -gt 28) { $name = $name.Substring(0, 28) }
    Write-Output ('{0,-28} {1,-6} {2,6:F1} {3,6:F1} {4,6:F1}  {5}' -f $name, $r.Mode,
        $r.Results['deuteranopia'].Distance, $r.Results['protanopia'].Distance, $r.Results['tritanopia'].Distance, $r.Verdict)
}
$s = @($recs | Where-Object Verdict -eq 'STRONG').Count
$o = @($recs | Where-Object Verdict -eq 'OK').Count
$w = @($recs | Where-Object Verdict -eq 'WEAK').Count
Write-Output ''
Write-Output "STRONG=$s  OK=$o  WEAK=$w   (thresholds: >=8 strong, >=3 OK, <3 weak)"

# --- app/platform-level themes ---
Write-Output ''
Write-Output '--- app/platform-level themes ---'
Write-Output ('{0,-28} {1,-6} {2,6} {3,6} {4,6}  verdict' -f 'app theme', 'mode', 'deut', 'prot', 'trit')
$arecs = [System.Collections.Generic.List[object]]::new()
foreach ($name in $script:AppThemes.Keys) {
    $modes = $script:AppThemes[$name]
    foreach ($mode in $modes.Keys) {
        [string[]]$colors = $modes[$mode]
        $res = @{}
        foreach ($c in @('deuteranopia', 'protanopia', 'tritanopia')) {
            $res[$c] = Get-MinPairDistance -Colors $colors -Cvd $c
        }
        $arecs.Add([PSCustomObject]@{
            Name = [string]$name; Mode = $mode; Results = $res; Verdict = (Get-Verdict -Results $res)
            Idx = $arecs.Count
        })
    }
}
$asorted = $arecs | Sort-Object { $order[$_.Verdict] }, { -($_.Results.Values | ForEach-Object Distance | Measure-Object -Minimum).Minimum }, { $_.Idx }
foreach ($r in $asorted) {
    $name = $r.Name
    if ($name.Length -gt 28) { $name = $name.Substring(0, 28) }
    Write-Output ('{0,-28} {1,-6} {2,6:F1} {3,6:F1} {4,6:F1}  {5}' -f $name, $r.Mode,
        $r.Results['deuteranopia'].Distance, $r.Results['protanopia'].Distance, $r.Results['tritanopia'].Distance, $r.Verdict)
}
$sa = @($arecs | Where-Object Verdict -eq 'STRONG').Count
$oa = @($arecs | Where-Object Verdict -eq 'OK').Count
$wa = @($arecs | Where-Object Verdict -eq 'WEAK').Count
Write-Output ''
Write-Output "app-level: STRONG=$sa  OK=$oa  WEAK=$wa"

# --- data-viz palettes ---
function Get-DataVizTable {
    [CmdletBinding()]
    [OutputType([object[]])]
    param()
    $genPath = Join-Path $PSScriptRoot 'New-ColorblindThemeExamples.ps1'
    $src = [System.IO.File]::ReadAllText($genPath)
    $m = [regex]::Match($src, '(?s)\$script:DataViz = (@\(.*?\n\))')
    if (-not $m.Success) { throw "Could not locate `$script:DataViz table in $genPath" }
    return [ScriptBlock]::Create($m.Groups[1].Value).Invoke()
}

Write-Output ''
Write-Output '--- data-viz palettes ---'
Write-Output ('{0,-28} {1,-6} {2,6} {3,6} {4,6}  verdict' -f 'palette', 'mode', 'deut', 'prot', 'trit')
foreach ($dv in (Get-DataVizTable)) {
    [string[]]$colors = $dv[1]
    $res = @{}
    foreach ($c in @('deuteranopia', 'protanopia', 'tritanopia')) {
        $res[$c] = Get-MinPairDistance -Colors $colors -Cvd $c
    }
    Write-Output ('{0,-28} {1,-6} {2,6:F1} {3,6:F1} {4,6:F1}  {5}' -f $dv[0], 'dark',
        $res['deuteranopia'].Distance, $res['protanopia'].Distance, $res['tritanopia'].Distance, (Get-Verdict -Results $res))
}
