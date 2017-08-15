#$Requires -Version 3
<#

.SYNOPSIS
Restart all web applications in a resource group by slot

.DESCRIPTION
Gets a list of all web applications in a given subscription and resource group. It restarts a slot across all of them.
 - You must be logged in using `AzureRm-Login`.
 - You must have a subscription selected used Select-AzureRmSubscription or use the `SubscriptionName` variable

.PARAMETER ResourceGroupName
The resource group name to restart web applications in.

.PARAMETER SubscriptionName
(Optional) Specify the subscription to perform the action in, if not already set using `Set-AzureRmContext`

.PARAMETER Slot
(Defaulted) The slot to restart. Defaults to 'canary'.

#>
param(
    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName,
    [string]$SubscriptionName,
    [string]$Slot = 'canary'
)

Set-StrictMode -Version 1.0

$origSubscription = $null;
try
{
    # Set the subscription BS
    $origSubscription = Get-AzureRmContext

    if ($subscriptionName -ne $null)
    {
        Get-AzureRmSubscription | Where-Object { $_.SubscriptionName -eq $SubscriptionName } | Set-AzureRmContext | Out-Null
    }
}
catch
{
    Write-Error "Encountered an exception likely related to logging in. Probably run Login-AzureRmAccount and then use Select-AzureRmSubscription"
    Write-Verbose $_.Exception.Message
    Exit -1
}

# Get a list of web apps for the RG
$webApps = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName

# For each one of them, restart the dang slot
foreach($webApp in $webApps) 
{
    Write-Verbose "Restarting Web App...$($webApp.Name) slot $Slot"
    Restart-AzureRmWebAppSlot -ResourceGroupName $ResourceGroupName -Name $webApp.Name -Slot $Slot | Out-Null
}

if ($origSubscription -ne $null)
{
    Write-Verbose "Resetting subscription to $($origSubscription.Subscription.SubscriptionName)"
    # Set the subscription back to whatever the user was on
    $origSubscription | Set-AzureRmContext | Out-Null
}
