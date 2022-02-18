@{
    # Script module or binary module file associated with this manifest.
    ModuleToProcess   = 'JunkDrawer.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.0.2'

    # ID used to uniquely identify this module
    GUID              = 'ffcc4cbd-3c95-4bdd-af1c-ce78adb9a447'

    # Author of this module
    Author            = 'Dustin Venegas'

    # Copyright statement for this module
    Copyright         = '(c) 2018 Dustin Venegas'

    # Description of the functionality provided by this module
    Description       = 'Dotfiles Junk Drawer for Dustin Venegas'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Edit-HostsFile',
        'New-Guid',
        'New-HttpBasicAuthValue',
        'New-HttpBasicAuthHeader',
        'Test-AdministratorRole',
        'Search-ForLines',
        'HandCraftedPromptForPowerShell1',
        'HandCraftedPromptForPowerShellCore'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags              = @('dotfiles', 'meta')

            # A URL to the license for this module.
            LicenseUri        = 'https://github.com/DustinVenegas/dotfiles/blob/master/LICENSE.md'

            # A URL to the main website for this project.
            ProjectUri        = 'https://github.com/dustinvenegas/dotfiles'

            # ReleaseNotes of this module
            ReleaseNotes      = 'https://github.com/dustinvenegas/dotfiles/blob/master/CHANGELOG.md'

            # TODO: REMOVE BEFOE RELEASE
            PreReleaseVersion = 'pre0'
        }
    }
}
