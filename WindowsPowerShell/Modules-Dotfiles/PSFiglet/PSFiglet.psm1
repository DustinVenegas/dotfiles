# Module checks
if (Get-Module PSFiglet) { return }
if (Test-Figlet -ne $true) { return }

function Test-Figlet {
    <#
        .SYNOPSIS Returns if figlet.exe exists in $env:PATH
    #>

    $figletCommand = Get-Command 'figlet.exe' -ErrorAction SilentlyContinue
    if ($figletCommand) {
        Write-Verbose "Figlet located at $($figletCommand.Path)"
        return $true
    } else {
        Write-Warning "Figlet missing! `n  Write-Figlet commands will output text instead.`n  Install figlet and ensure it's available via your `$env:PATH"
        return $false
    }
}

function Write-Figlet {
    <#
        .SYNOPSIS
        Write Figlet output as PowerShell Host output
    #>
    figlet $args | Write-Output
}

<#
    .SYNOPSIS
    List available Figlet Fonts
#>
function List-FigletFonts {
    figlet
}


$exportModuleMemberParams = @{
    Function = @(
        'Write-Figlet'
    )
}

Export-ModuleMember @exportModuleMemberParams
