<#
.SYNOPSIS
Bootstraps dotfiles configuration by creating symlinks from a set of directories targeting this dotfiles repository.
.DESCRIPTION
Root files and folders prefixed with a dot ('.') are generally symlinked to $HOME.
.config represents XDC_CONFIG_HOME
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [switch]$ShowUnchanged
)
begin {
    Set-StrictMode -Version Latest

    $dotfiles = Get-Item (Resolve-Path (Join-Path $PSScriptRoot ..)) -Force
    $exclude = @()
    if ($IsWindows) {
        $exclude += @(
            'dot_bash_profile',
            'dot_bashrc',
            'dot_vimrc' # _vimrc is recognized on Windows.
            'dot_zshrc'
        )
    }

    function New-Symlink {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
        param(
            [string]$Path,
            [string]$Target
        )

        if (Test-Path $Path) {
            $rv = [PSCustomObject]@{
                Type          = 'Placeholder'
                Path          = $Path
                Target        = $Target
            }

            $l = Get-Item -Path $Path -Force
            switch ($l) {
                { $_.Target -and ($_.Target -eq $Target) } { $rv.Type = 'Unchanged'; if ($ShowUnchanged.ToBool()) { Break } else { return } }
                { $_.Target -and ($_.Target -ne $Target) } { $rv.Type = 'Mismatched'; Write-Warning "Unexpected target at path: $_"; Break }
                { $null -ne $_ } { $rv.Type = 'Conflict'; Write-Warning "File or directory exists as non-symlink at path: $_"; Break }
                default { $rv.Type = 'Error'; Write-Warning 'File exists but the symlink status is unhandled.' }
            }

            return $rv
        } else {
            if ($PSCmdlet.ShouldProcess($Path, "Create a new SymbolicLink to $(Resolve-Path $Target -Relative)")) {
                New-Item -Type SymbolicLink -Path $Path -Value $Target -Force | Out-Null
                [PSCustomObject]@{
                    Type          = 'Created'
                    Path          = $Path
                    Target        = $Target
                }
            } else {
                [PSCustomObject]@{
                    Type          = 'Pending'
                    Path          = $Path
                    Target        = $Target
                }
            }
        }

    }

    function Set-UserEnvVar {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
        param($name, $value)

        $m = ""
        $current = [System.Environment]::GetEnvironmentVariable($name, 'User')
        if ($value -ne $current) {
            if ($PSCmdlet.ShouldProcess($Name, "Setting a user-level envvar")) {
                [Environment]::SetEnvironmentVariable($name, $value, 'User')
            } else {
                $m = "(whatif) "
            }
            Write-Verbose("$m`Setting envvar: $name") 
        }
    }

    function Stow { 
        param(
            [System.IO.DirectoryInfo]$Path,
            [System.IO.DirectoryInfo]$Target,
            [string[]]$Exclude,
            [string[]]$Include,
            [switch]$Recurse
        )

        # -Path that ends with \* searches files within that path for includes/excludes
        # -Include/-Exclude takes a generic wildcard
        $files = Get-ChildItem -File -Path $Target\* -Include $Include -Exclude $Exclude -Recurse:$($Recurse.ToBool()) -Force
        foreach ($f in $files) {
            Push-Location -Path $Target
            $slTarget = Resolve-Path $f
            $rel = $(Resolve-Path $f -Relative).Replace('dot_', '.')
            $slPath = (Join-Path $Path $rel).Replace('\.\', '\') # Removes non-noramlized segement from Join-Path without -resolve.
            Pop-Location

            New-Symlink -Path $slPath -Target $slTarget
        }

    }
}
process {
    if (-not $IsWindows) { Write-Error 'pwsh is cross platform, but this particular script is for Windows only. POSIX-compatible systems should use script/bootstrap.' }

    # Templates
    Copy-Item "$dotfiles/git/.gitconfig_local.template" "$dotfiles/dot_gitconfig_local" -Force
    Copy-Item "$dotfiles/.config/nvim/local.dotfiles.vim.template" "$dotfiles/.config/nvim/local.dotfiles.vim"
    Copy-Item "$dotfiles/dot_vim/.vimrc.local.template" "$dotfiles/dot_vimrc.local"
    New-Symlink -Path $HOME\.gitconfig_os -Target $dotfiles\git\.gitconfig_os_windows

    # Stow files in the dotfiles directory prefixed with 'dot_'.
    Stow -Path $HOME -Target $dotfiles -Include @('dot_*') -Exclude $exclude

    # Windows specific mapping.
    Stow -Path $env:LOCALAPPDATA\nvim -Target $dotfiles\.config\nvim -Recurse
    Stow -Path $env:LOCALAPPDATA -Target $dotfiles\AppData\Local\ -Recurse
    Stow -Path $HOME\Documents\PowerShell -Target $dotfiles\.config\powershell -Recurse
    Stow -Path $HOME\Documents -Target $dotfiles\Documents -Recurse
    Stow -Path $HOME\.vim -Target $dotfiles\dot_vim -Recurse

    New-Symlink -Path $HOME\.dotfiles -Target $dotfiles
    New-Symlink -Path $HOME\_vimrc -Target $dotfiles\.vimrc
    New-Symlink -Path $HOME\Documents\PowerShell\Scripts -Target $dotfiles\PSScripts

    Set-UserEnvVar -Name RIPGREP_CONFIG_PATH -Value $HOME\.ripgreprc
    Set-UserEnvVar -Name EDITOR -Value 'nvim-qt'
}
end {
}
