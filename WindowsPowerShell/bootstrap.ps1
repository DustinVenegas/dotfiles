#Requires -Version 4
#Requires -RunAsAdministrator

# As an end-user, we trust the PSGallery
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted')
{
    # Trust PSGallery
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
}

# Install modules
Install-Module -Repository PSGallery posh-git -Scope CurrentUser
Install-Module -Repository PSGallery PSFzf -Scope CurrentUser

# Download the latest help files
Update-Help
