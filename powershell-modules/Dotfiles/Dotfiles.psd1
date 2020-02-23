@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'Dotfiles.psm1'

    # Version number of this module.
    ModuleVersion = '0.0.0.1'

    # ID used to uniquely identify this module
    GUID = '8142cdfc-738b-4036-af21-433830503fdb'

    # Author of this module
    Author = 'Dustin Venegas'

    # Copyright statement for this module
    Copyright = '(c) 2018 Dustin Venegas'

    # Description of the functionality provided by this module
    Description = 'Modules and tools to create and manage dotfiles'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Test-DotfilesLinkTarget',
        'Set-DotfilesSymbolicLink'
    )

    # Cmdlets to export from this module
    #CmdletsToExport = @()

    # Variables to export from this module
    #VariablesToExport = @()

    # Aliases to export from this module
    #AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('dotfiles', 'meta')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/DustinVenegas/dotfiles/blob/master/LICENSE.md'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/dustinvenegas/dotfiles'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/dustinvenegas/dotfiles/blob/master/CHANGELOG.md'

            # TODO: REMOVE BEFOE RELEASE
            PreReleaseVersion = 'pre0'
        }
    }
}
