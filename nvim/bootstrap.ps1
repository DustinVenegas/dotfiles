<#
    .Synopsis
    Configure Neovim for this Dotfiles configuration
    .Description
    Bootstraps the Neovim portion of the Dotfiles repository
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    function Get-PipEnvPython {
        param
        (
            [Parameter(Mandatory, Position = 0)]
            [string]$Path
        )
        Push-Location $Path | Out-Null
        try {
            if (Get-Command 'pipenv' -ErrorAction SilentlyContinue) {
                $result = &pipenv --py --bare | Where-Object { $_ }

                if (-Not $result) {
                    'pipenv-output-empty-or-errored'
                } else {
                    $result
                }
            } else {
                'pipenv-missing-or-not-installed'
            }
        } catch {
            Write-Error "Error Getting pipenv Python Version: $_"
        } finally {
            Pop-Location | Out-Null
        }
    }

    function Install-PipEnv {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param()

        $pipenvMissing = $null -eq (Get-Command 'pipenv' -ErrorAction SilentlyContinue)
        if ($pipenvMissing) {
            if ($PSCmdlet.ShouldProcess("pip", "install pipenv")) {
                &pip3 install --quiet --upgrade pipenv | Out-Null
                &pip2 install --quiet --upgrade pipenv | Out-Null
            }
        }

        [PSCustomObject] @{
            Name = 'Install-PipEnv'
            NeedsUpdate = $pipenvMissing
            Entity = "pipenv"
            Properties = @{
                PipenvMissing = $pipenvMissing
            }
        }
    }

    function Set-PipEnvWorkspace {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param
        (
            [Parameter(Mandatory, Position = 0)]
            [string]$Path
        )

        # Install dependencies into virtual environment.
        Push-Location $Path
        $pipenvPythonPath = $null
        try {
            if ($PSCmdlet.ShouldProcess('PipEnv', $path)) {
                Write-Verbose "Running pipenv update in $path"
                $result = &pipenv install
                Write-Verbose "pipenv update output: $result"
            }
        }
        catch {
            Write-Error "Error updating pipenv workspace: $_"
        }
        finally {
            Pop-Location | Out-Null
        }

        [PSCustomObject] @{
            Name = 'Invoke-PipEnv'
            NeedsUpdate = $true
            Entity = "$Path"
            Properties = @{
                Location = $pipenvPythonPath
            }
        }
    }

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }

    $pythonVenvPath = Join-Path -Path $PSScriptRoot -ChildPath 'python-venvs'
    $pythonVersions = @{
        '2.7' = Join-Path -Path $pythonVenvPath -ChildPath '2.7'
        '3.8' = Join-Path -Path $pythonVenvPath -ChildPath '3.8'
    }
}
process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') `
        -Value $PSScriptRoot `
        -whatif:$optWhatIf

    Set-UserEnvVar -Name EDITOR -Value 'nvim-qt' -whatif:$optWhatIf

    Install-PipEnv -whatif:$optWhatIf
    Set-PipEnvWorkspace -Path $pythonVersions['2.7'] -whatif:$optWhatIf
    Set-PipEnvWorkspace -Path $pythonVersions['3.8'] -whatif:$optWhatIf

    Set-JsonValue -Path (Join-Path -Path $PSScriptRoot -ChildPath 'local.dotfiles.json') -InputObject @{
        'g:python3_host_prog' = "$(Get-PipEnvPython -Path $pythonVersions['3.8'])"
        'g:python_host_prog' = "$(Get-PipEnvPython -Path $pythonVersions['2.7'])"
        'g:ripgrep_config' = "$(Join-Path -Path "$HOME" -ChildPath '.ripgreprc')"
    } -whatif:$optWhatIf

    Write-Verbose "Done"
}
