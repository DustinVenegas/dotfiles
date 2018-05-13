<#
    .Synopsis
        Configure Neovim and necessary modules for Dotfiles

    .Description
        Bootstraps the Neovim portion of the Dotfiles Repository by performing
        actions such as installing plugins, neovim tools, setting up python,
        etc.

    .Parameter Uninstall
        Removes appropriate installed files outside of the Dotfiles repository.


    .Parameter Confirm
        Approves all prompts

    .Example
        # Run bootstrapper, approving everything
        .\bootstrap.ps1 -Confirm

    .Example
        # Uninstall
        .\bootstrap.ps1 -Uninstall

    .Notes
        Some neovim files are Symlinked into $HOME/AppData/Roaming/nvim.
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [switch]$confirm,
    [switch]$uninstall
)
Begin
{
    $dotfilesModulePath = Resolve-Path (Join-Path $PSScriptRoot ../WindowsPowerShell/Modules-Dotfiles/Dotfiles/Dotfiles.psm1)
    Import-Module -Name $dotfilesModulePath
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    # ====== Functions ======

    function Get-UserInputYesNo
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Literally the PowerShell Host", Scope="Function")]
        param
        (
            $message
        )

        if (($PSCmdlet.MyInvocation.BoundParameters["confirm"]) `
            -and ($PSCmdlet.MyInvocation.BoundParameters["confirm"].IsPresent -eq $true))
        {
            # Confirms all actions
            return $true
        }

        while($true)
        {
            $input = Read-Host "$message (Y/N)?"

            switch ($input.ToUpper())
            {
                'Y' { return $true }
                ''  { return $false }
                'N' { return $false }

                default { Write-Host "Invalid input: $input"; continue; }
            }
        }
    }

    function Set-UserEnvVar
    {
        param
        (
            $name,
            $value
        )

        $current = [System.Environment]::GetEnvironmentVariable($name, "User")

        if ($current -ne $value)
        {
            Write-Verbose "Setting User Environment variable $name to [$value] from [$current]"
            [Environment]::SetEnvironmentVariable($name, $value, "User")
        }
    }

    function Test-EnvVarPath
    {
        param
        (
            [string]$Path
        )

        $entries = [System.Environment]::GetEnvironmentVariable("PATH") -Split ';' | `
            Where-Object { (Join-Path $_ '') -eq (Join-Path $Path '') }

        return $null -ne $entries
    }

    function Install-PipenvDependencies
    {
        param
        (
            $virtualEnv,
            $pythonVersion
        )

        # Use pip to install/update the virtualenv dependencies
        Push-Location $virtualEnv
        &pipenv update
        Pop-Location
    }

    function Get-PipenvPythonVersion
    {
        param
        (
            $virtualEnv
        )

        Push-Location $virtualEnv
        $pythonPath = &pipenv --py
        Pop-Location | Out-Null

        return $pythonPath
    }

    function Install-Pipenv
    {
        &pip3 install --upgrade pipenv | Out-Null
        &pip2 install --upgrade pipenv | Out-Null
    }

    function Install-ChocolateyPackages
    {
        if (Get-Command choco -ErrorAction SilentlyContinue)
        {
            $chocolateyPackages = Join-path $PSScriptRoot 'chocolatey-packages.config'
            &choco install $chocolateyPackages --Confirm
        }
        else
        {
            Write-Warning "Chocolatey is missing! Uh, that means the packages couldn't be installed. You'll need to look into this."
        }
    }
}
Process
{
    # Maps: $Home/AppData/Local/nvim/ -> $dotfiles/nvim/
    $symlinks = @{
        (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim/') = $PSScriptRoot;
    }

    $pythonVirtualEnvs = @{
        "$PSScriptRoot/python-venvs/2.7/" = 2;
        "$PSScriptRoot/python-venvs/3.6/" = 3;
    }

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Install all our prerequisite applications
        Install-ChocolateyPackages

        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] -ErrorAction Stop }

        # Assert nvim-qt exists in the PATH
        $nvimqtCommandSource = (Get-Command 'nvim-qt' -ErrorAction Stop).Source
        if (-Not (Get-Command 'nvim-qt' -ErrorAction SilentlyContinue)) { Write-Error "It seems nvim-qt is missing from the PATH. If you just used Chocolatey to install it, try closing and reopening your shell. If using ConEmu, you'll have to close/reopen the entire multiplexer!" }

        # Set EDITOR to nvim-qt
        Set-UserEnvVar -Name EDITOR -Value 'nvim-qt'

        # Python VEnvs
        Install-Pipenv
        $pipenvExeLocationByVersion = @{}
        foreach ($venvDir in $pythonVirtualEnvs.Keys)
        {
            $pythonVersion = $pythonVirtualEnvs[$venvDir]
            Write-Output "Installing Pipenv Dependencies for [$venvDir] python [$pythonVersion]"
            Install-PipenvDependencies $venvDir $pythonVersion

            # Set the python executable location
            $pipenvExeLocationByVersion[$pythonVersion] = Get-PipenvPythonVersion $venvDir
        }

        $neovimSettings = @{
            'g:python3_host_prog'=$pipenvExeLocationByVersion[3];
            'g:python_host_prog'=$pipenvExeLocationByVersion[2]
        }

        $localhostNeovimSettings = Join-Path $PSScriptRoot 'local.dotfiles.json'
        if (Test-Path $localhostNeovimSettings)
        {
            $existingJson = Get-Content $localhostNeovimSettings | ConvertFrom-Json

            foreach ($expectedKey in $neovimSettings.Keys)
            {
                $existingValue = $null
                if (($existingJson | Get-Member -MemberType NoteProperty).Name -Contains $expectedKey)
                {
                    $existingValue = $existingJson."$expectedKey"
                }

                if ($existingValue -ne $neovimSettings[$expectedKey])
                {
                    Write-Warning "Expected key ($expectedKey) missing in $localhostNeovimSettings! Expected $($neovimSettings[$expectedKey]) but saw ($existingValue). Manual investigation necessary!"
                }
            }
        }
        else
        {
            $json = $neovimSettings | ConvertTo-Json
            [System.IO.File]::WriteAllLines($localhostNeovimSettings, $json)
        }
    }
}
