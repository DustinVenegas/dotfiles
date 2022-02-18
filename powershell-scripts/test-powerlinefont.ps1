<#
    .SYNOPSIS
        Output character sequences for the PowerLine font.
    .DESCRIPTION
        Outputs PowerLine Gliphs using ANSII Terminal sequences and Nerd Fonts unicode code points. Allows for visual verification of if and how a terminal renders the PowerLine font codepoints.
#>
param()

# PowerLine Gliphs in their Nerd Fonts unicode code point.
# https://github.com/ryanoasis/powerline-extra-symbols
$glyphs = @{
    branch                = "`u{e0a0}"
    lineNumber            = "`u{e0a1}"
    readOnly              = "`u{e0a2}"
    columnNumber          = "`u{e0a3}"

    rightAngleSolid       = "`u{E0B0}"
    rightAngleLine        = "`u{E0B1}"
    leftAngleSolid        = "`u{E0B2}"
    leftAngleLine         = "`u{E0B3}"

    rightRoundedSolid     = "`u{E0B4}"
    rightRoundedLine      = "`u{E0B5}"
    leftRoundedSolid      = "`u{E0B6}"
    leftRoundedLine       = "`u{E0B7}"

    bottomLeftAngleSolid  = "`u{E0B8}"
    bottomLeftAngleLine   = "`u{E0B9}"
    bottomRightAngleSolid = "`u{E0BA}"
    bottomRightAngleLine  = "`u{E0BB}"

    topLeftAngleSolid     = "`u{E0BC}"
    topLeftAngleLine      = "`u{E0BD}"
    topRightAngleSolid    = "`u{E0BE}"
    topRightAngleLine     = "`u{E0BF}"

    rightFlameSolid       = "`u{e0c0}"
    rightFlameLine        = "`u{e0c1}"
    leftFlameSolid        = "`u{e0c2}"
    leftFlameLine         = "`u{e0c3}"

    leftDigitalSmall      = "`u{e0c4}"
    rightDigitalSmall     = "`u{e0c5}"
    leftDigitalMedium     = "`u{e0c6}"
    rightDigitalMedium    = "`u{e0c7}"

    leftSpectrum          = "`u{e0c8}"
    rightSpectrum         = "`u{e0ca}"

    leftHoneycomb         = "`u{e0cc}"
    rightHoneycomb        = "`u{e0cd}"

    right3dBlock          = "`u{e0ce}"
    left3dBlock           = "`u{e0cf}"
    topBlock              = "`u{e0d0}"
    sideBlock             = "`u{e0d1}"

    leftSideHexagon       = "`u{e0d2}"
    rightSideHexagon      = "`u{e0d4}"
}

$glyphs.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        Name  = "$($_.Key)"
        Glyph = "$($_.Value)"
    }
} | Format-Table

# Example flames
Write-Host "Example Prompt:"
Write-Host "---"
Write-Host "`e[43m first `e[44m`e[33m$($glyphs.rightFlameSolid) `e[39m second `e[45m`e[34m$($glyphs.rightFlameSolid) `e[39m thi`e[39m$($glyphs.rightFlameLine)-rd `e[46m`e[35m$($glyphs.rightFlameSolid) `e[39m fourth `e[49m`e[36m$($glyphs.rightFlameSolid) `e[0m"
Write-Host ""
