@{

    # Script module or binary module file associated with this manifest.
    ModuleToProcess = 'PSFiglet.psm1'

    # Version number of this module.
    ModuleVersion = '0.0.0.1'

    # ID used to uniquely identify this module
    GUID = '5df0fbef-68bc-4669-82c6-33d510266de8'

    # Author of this module
    Author = 'Dustin Venegas'

    # Copyright statement for this module
    Copyright = '(c) 2018 Dustin Venegas'

    # Description of the functionality provided by this module
    Description = 'Adds PSBindings for Figlet-Go'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '2.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Write-Figlet'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('figlet', 'go', 'text', 'ascii', 'art')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/dustinvenegas/PSFiglet/blob/master/LICENSE.txt'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/dustinvenegas/PSFiglet'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/dustinvenegas/PSFiglet/blob/master/CHANGELOG.md'

            # TODO: REMOVE BEFOE RELEASE
            PreReleaseVersion = 'pre0'
        }
    }
}
