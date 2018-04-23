#Requires -Version 4
#Requires -RunAsAdministrator

if ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted')
{
    # Trust scripts (remove warnings) when downloading from PSGallery
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
}

# Install modules
$expectedModules = @( 'posh-git', 'PSFzf' )
$expectedModules | %{
    if (Get-Module -Name $_)
    {
        Update-Module $_
    }
    else
    {
        Install-Module -Repository PSGallery $_ -Scope CurrentUser
    }
}

# Download the latest help files
# HACK: Ignore errors due to 'Failed to update Help for the module(s)' errors
Update-Help -ErrorAction SilentlyContinue
