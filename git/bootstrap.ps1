Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

function Test-HardLinkTo($path, $target)
{
    if (Test-Path $path)
    {
        $pathFileInfo = Get-Item $path

        if ($pathFileInfo.LinkType -eq 'HardLink')
        {
            $hardLinkTargetPath = Resolve-Path $pathFileInfo.Target;
            $targetPath = Resolve-Path $target;

            return $hardLinkTargetpath.Path -eq $targetpath.Path
        }
    }

    return $false
}

function Ensure-HardLinkTo($path, $target)
{
    if (-Not (Test-Path $target))
    {
        Write-Error "Expected HardLink target ($target) to exist, but it's misssing!"
    }

    # Does anything already exist?
    if (Test-Path $path)
    {
        if (Test-HardLinkTo -Path $path -Target $target)
        {
            Write-Verbose "OK $path is a HardLink pointed to $target"
        }
        else
        {
            Write-Warning @"
Expected $path to be a HardLink pointed at $target.
   Backup and delete, or move, $path then re-run this script.
"@
        }
    }
    else
    {
        # Nothing at $path, so just create it!
        $hardLinkFileInfo = New-Item -Type HardLink -Path $path -Value $target
        Write-Verbose "CREATED: $($hardLinkFileInfo.Name), a $($hardLinkFileInfo.LinkType), pointed at $($hardLinkFileInfo.Target)"
    }
}

function Ensure-PoshGit
{
    if ((Get-Module -Name posh-git -ListAvailable) -eq $null)
    {
        Write-Host "Installing posh-git"
        Install-Module -Name 'posh-git' -Scope "CurrentUser" -Confirm
    } else {
        Write-Host "Updating posh-git"
        Update-Module -Name 'posh-git' -Confirm
    }
}

$config = @{
    'PathHome' = Join-Path -Path $HOME -ChildPath '.gitconfig'
    'PathDotfiles' = Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig'
}

# Ensures $DOTFILES_BASE/git/gitconfig to $HOME/.gitconfig
Ensure-HardLinkTo -Path $config.PathHome -Target $config.PathDotfiles

# Install or update Posh-Git
Ensure-PoshGit
