function New-SymbolicLink
{
    <#
    .Synopsis
        Creates a symbolic link from one file or folder to another location.
    .Description
        Creates a consistent interface to create symbolic links by extending the built-in PowerShell symlink capabilities.
        Works consistently on Windows and Linux.
    .Parameter Path
        Path where the symbolic link should be created.
    .Parameter Value
        Path where the symbolic link should point to.
    .Example
        New-SymbolicLink -Path /foo -Value /bar
        Creates a symbolic link at /foo pointed to /bar.
    .Example
        New-SymbolicLink -Path c:\foo -Value c:\bar -WhatIf
        Creates a symbolic link at c:\foo pointed to c:\bar in whatif mode.
    .Example
        New-SymbolicLink -Path c:\a-link-to-pwd -Value .
        Creates a symbolic link at c:\a-link-to-pwd pointed at the present working directory ($pwd).
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory, Position = 1)]
        [string]$Value
    )

    process
    {
        if (-Not (Test-Path $Value))
        {
            Write-Error "Expected path to exist for value at: $Value"
        }

        $succeeded = $false
        $resolvedValue = Resolve-Path $value

        if (Test-Path $path) {
            # -Force includes hidden (.filename) files on Linux.
            $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue

            $succeeded = ($item.Target -and $item.Target -eq $resolvedValue.Path)
            if (-Not $succeeded) {
                Write-Error "A file, directory, or symlinklink already exists at $($item.FullName))"
            }
        } else {
            if ($PSCmdlet.ShouldProcess("Destination: $Path")) {
                $item = New-Item -Type SymbolicLink -Path $Path -Value $resolvedValue
                Write-Verbose "Created a SymbolicLink at $path pointed to $resolvedValue"
            } else {
                Write-Verbose "Would have created a SymbolicLink at $path pointed to $resolvedValue"
            }

            $succeeded = $true
        }

        [PSCustomObject]@{
            Name = 'New-SymbolicLink'
            NeedsUpdate = -Not $succeeded
            Entity = $Path
            Properties = @{
                Value = $Value
            }
        }
    }
}
