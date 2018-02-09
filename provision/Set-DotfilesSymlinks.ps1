<#
Creates symbolic links for some dotfiles. Just a proof of concept.
#>

$hyperConfigFileName = '.hyper.js'
$homeConfigPath = Join-Path -Path $HOME -ChildPath $hyperConfigFileName
$dotfilesConfigPath = Resolve-Path "$PSScriptRoot/../hyper.js/$hyperConfigFileName"

if (Test-Path $homeConfigPath)
{
    Write-Verbose "FOUND: existing $homeConfigPath"

    $homeConfigFileInfo = Get-Item $homeConfigPath
    $verboseMessage = "is a $($homeConfigFileInfo.LinkType) pointed at $($homeConfigFileInfo.Target)"

    if (($homeConfigFileInfo.LinkType -eq 'HardLink') -and (($homeConfigFileInfo.Target.ToLower() -eq $dotfilesConfigPath.Path.ToLower())))
    {
        # Hardlink points to _this_ dotfiles config! (case normalized for Windows)
        Write-Verbose "OK: .hyper.js $verboseMessage"
    }
    else
    {
        Write-Warning "WARN: .hyper.js SHOULD BE a HardLink pointed at $dotfilesConfigPath, BUT $verboseMessage"
    }
}
else
{
    # First run, create a new one
    $hyperJsFileInfo = New-Item -Type HardLink -Path $HOME -Name $hyperConfigFileName -Value $dotfilesConfigPath.Path
    Write-Verbose "CREATED: .hyper.js, a $($hyperJsFileInfo.LinkType), pointed at $($hyperJsFileInfo.Target)"
}
