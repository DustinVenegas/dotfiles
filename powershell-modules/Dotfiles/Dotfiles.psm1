function Test-DotfilesLinkTarget
{
    <#
    .SYNOPSIS
    Determine if item at path is a link pointed at the resolved target link

    .DESCRIPTION
    Make sure the path passed in is a type of link. If so, see if target and
    link target resolve to the same path.

    #>
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$path,
        [Parameter(Mandatory = $true)]
        [string]$target
    )

    $resolvedTargetPath = Resolve-Path $target -ErrorAction SilentlyContinue
    $found = Get-Item $path -ErrorAction SilentlyContinue |
        Where-Object -Property LinkType |
        Where-Object {
            (Resolve-Path $_.Target -ErrorAction SilentlyContinue).Path -eq $resolvedTargetPath.Path
        }

    return ($null -ne $found)
}

function Set-DotfilesSymbolicLink
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$path,

        [Parameter(Mandatory = $true)]
        [string]$target
    )
    Begin
    {
        if (-Not (Test-Path $target))
        {
            Write-Error "Expected target to exist, but didn't at: $target"
        }
    }
    Process {
        if (Test-Path $path)
        {
            # A file exists where we expected a symlink
            if (-Not (Test-DotfilesLinkTarget $path $target))
            {
                Write-Error "Set-SymbolicLink failed. File already exists at $path, but may not be a symbolic link pointed to $target"
            }
        }
        else
        {
            if ($pscmdlet.ShouldProcess($path))
            {
                New-Item -Type SymbolicLink -Path $path -Value $target | Out-Null
            }
        }
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Test-DotfilesLinkTarget',
        'Set-DotfilesSymbolicLink'
    )
}

Export-ModuleMember @exportModuleMemberParams
