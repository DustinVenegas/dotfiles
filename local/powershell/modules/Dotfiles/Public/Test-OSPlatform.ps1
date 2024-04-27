<#
    .Synopsis
        Determines whether the currnent OS/Platform match one of the specified ones.
    .Description
        The 'Test-OSPlatform' cmdlet determines whether the currently running OS and
        Platform match one of the specified OS and Platforms.
    .Parameter Include
        A list of valid OS entries. The ScriptBlock will be run when the Include
        list contains the current OS.
    .Parameter ScriptBlock
        Code that should be executed if the Include list contains the current OS.
    .Example
        Test-OSPlatform -Include @('Windows','Darwin')
        Include Windows and Darwin but not Unix.
    .Notes
        OS entries are: Windows, Unix, Darwin.
#>
function Test-OSPlatform {
    param(
        [string[]]$Include
    )

    $simplifiedRunningOS = Get-DotfilesOSPlatform
    return $Include -Contains $simplifiedRunningOS
}
