function Set-UserEnvVar {
    <#
    .Synopsis
        Sets user environment variable.
    .Description
        Set user environment variable to a value.
    .Parameter Name
        Environment variable name.
    .Parameter Value
        Environment variable value.
    .Example
        Set-EnvVar -Name MyVar -Value 'foo'
        Sets $env:MyVar to 'foo'.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $name,
        [Parameter(Mandatory, Position = 1)]
        [string]
        $value
    )
    process {
        $current = [System.Environment]::GetEnvironmentVariable($name, 'User')
        $needsUpdate = $current -ne $value

        if ($needsUpdate) {
            if ($PSCmdlet.ShouldProcess("Envvar: $name")) {
                [Environment]::SetEnvironmentVariable($name, $value, 'User')
            }

            Write-Verbose "Set User Environment variable $name to [$value] from [$current]"
        }

        [PSCustomObject] @{
            Name        = 'Set-UserEnvVar'
            NeedsUpdate = $needsUpdate
            Entity      = "$Name"
            Properties  = @{
                CurrentValue = $current
                New          = $value
            }
        }
    }
}
