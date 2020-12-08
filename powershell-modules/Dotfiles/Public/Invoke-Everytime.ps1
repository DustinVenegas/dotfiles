function Invoke-Everytime {
    <#
    .Synopsis
        Runs a ScriptBlock on every dotfiles invocation
    .Description
        Provides consistent logging, -whatif support, and status output for a ScriptBlock.
    .Parameter ScriptBlock
        Code to invoke.
    .Example
        Invoke-Everytime -Name 'WritesVerbose' -ScriptBlock { Write-Verbose "In the SB." }
        Invokes a script block with a verbose statement.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,
        [Parameter(Mandatory, Position = 1)]
        [ScriptBlock]$ScriptBlock
    )

    process {
        if ($PSCmdlet.ShouldProcess("ScriptBlock: $ScriptBlock")) {
            & $ScriptBlock
        } else {
            Write-Verbose "Would have run ScriptBlock $ScriptBlock"
        }

        [PSCustomObject]@{
            Name        = 'Invoke-Everytime'
            NeedsUpdate = $true
            Entity      = $Name
            Properties  = @{
                ScriptBlock = $ScriptBlock
            }
        }
    }
}
