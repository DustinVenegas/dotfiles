scratch


#Invoke-DotfilesProcessor @(
#
#    New-InstallPackages
#)

function WithWhatIf {
    param([ScriptBlock]$sb)

    &$sb @args @optWhatIf
}

function WithWhatIf {
    param([ScriptBlock]$sb)
    $sb @args
    #Invoke-Expression
    # $ExecutionContext.InvokeCommand.GetCmdlet('Set-Item') | gm

    # Check the output type of a command.
    # (Get-Command Install-Packages).OutputType -eq [System.String]
}

function maybe {
    param(
        [parameter(mandatory, position=0)]
        [string]$cmdlet,
        [parameter(position=1, ValueFromRemainingArguments=$true)]
        $RemainingArgs
    )
    Write-Verbose "cmdlet is $cmdlet"
    Write-Verbose "Remaining args are $RemainingArgs"

    $cmd = Get-Command $cmdlet

    &$cmdlet @RemainingArgs
}


function Invoke-DotfilesProcessor {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param (
        [ScriptBlock]$script
    )

    $optWhatIf = $PSCmdlet.ShouldProcess('Without -whatif option')
    &$script -WhatIf:$optWhatIf
}

# Does nothing except wrap everyting in a script and flip the variables.
# Invoke-DotfilesProcessor {
#     param ([switch]$WhatIf)

#     $optWhatIf = $whatIf.IsPresent -and ($true -eq $whatIf)
#     Write-Verbose "Commands with '-whatif' parameter? $optWhatIf"

#     Install-Packages $PSScriptRoot -whatif:$optWhatIf
#     Set-NSSMService -ServiceName 'rclone-gdrive' -CommandPath (Join-Path -Path $PSScriptRoot -ChildPath 'mount-gdrive.cmd') -whatif:$optWhatIf
# }

param ([switch]$WhatIf)

function Task {
    param(
        [Parameter(mandatory, position=0)]
        [string]$Cmdlet,
        [Parameter(position=1, ValueFromRemainingArguments=$true)]
        $RemainingArgs
    )

    $SupportsWhatIf = $false

    $cmd = Get-Command -ParameterName $Cmdlet
    if ($cmd | Where-Object -Property CommandType -EQ 'Cmdlet') {
        Write-Verbose "Command is a Cmdlet: $Cmdlet"
        if ($cmd.Parameters.Keys -eq 'WhatIf') {
            $SupportsWhatIf = $true
        }
    }

    # ScriptBlock = {
    #     &$Cmdlet @RemainingArgs @MaybeWhatIf
    # }.GetNewClosure()

    return @{
        Cmdlet = $Cmdlet
        RemainingArgs = $RemainingArgs
        SupportsWhatIf = $SupportsWhatIf
    }
}

$tasks = @{
    "Install Packages" = Task Install-Packages
}

Config |
    Register { Install-Packages $PSScriptRoot }
    Register Register-NSSMService 'rclone-gdrive' (Join-Path -Path $PSScriptRoot -ChildPath 'mount-gdrive.cmd') @optWhatIf

$optWhatIf = @{
    '-whatif' = $whatIf.IsPresent -and ($true -eq $whatIf)
}

InstallPackages = Install-packages $PSScriptRoot @optWhatIf
NSSMServices = Register-NSSMService 'rclone-gdrive' (Join-Path -Path $PSScriptRoot -ChildPath 'mount-gdrive.cmd') @optWhatIf
