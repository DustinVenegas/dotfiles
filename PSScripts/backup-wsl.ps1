<#
.SYNOPSIS
Create a backup of all WSL distributions in exportDir.
.NOTES
ExportDir defaults to $HOME\Backups\wsl\ by default.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$exportDir = (Join-Path $HOME Backups wsl)
)
begin {
    if (-not (Test-Path $exportDir)) {
        Write-Verbose "Created wsl export directory: $exportDir"

        if ($PSCmdlet.ShouldProcess($exportDir, "create backup export dir at $exportDir")) {
            New-Item -Type Directory -Path $exportDir | Out-Null
        }
    }
}
process {
    wsl --list --quiet | Where-Object { $_ -ne '' } |
        ForEach-Object {
            $_ -replace "`0", ''
        } |
        ForEach-Object {
            $source = $_
            $dest = "$(Join-Path $exportDir $_`.tar)"
            if ($PSCmdlet.ShouldProcess($_, "export $source to $dest")) {
                wsl --export "$_" "$(Join-Path $exportDir $_`.tar)"
            }
        }
}
