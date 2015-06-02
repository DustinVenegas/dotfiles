param(
    [string]$dotfilesPath = (Resolve-Path "$PSScriptRoot\..").Path.Replace("$home",'~')
)

function Test-Application {
    param([string]$name)

    (Get-Command -Type Application | Where-Object { $_.Name -eq $name }) -ne $null
}

# TODO: fsutil any easier?

# Provision Choco
if (Test-Application choco) {
    Write-Host "Installing packages"
    # Add personal NuGet packages
    choco source add -n=myget -s https://www.myget.org/F/dustinvenegas/

    choco install "$dotfilesPath\provision\general-packages.config"
    choco install "$dotfilesPath\provision\development-packages.config"
} else {
    Write-Warning "choco not found"
}

# Provision VIM
if (Test-Application vim) {
    $vimrcPath = "$HOME\.vimrc"
    if (Test-Path $vimrcPath) {
        Write-Warning ".vimrc already exists at $vimrcPath"
    } else {
        Write-Host "Creating default .vimrc at $vimrcPath"

        Get-Content "$dotfilesPath\provision\.vimrc.template" | %{
            $_  -replace '{{date}}',(Get-Date) `
                -replace '{{vimrtp}}',"$($dotfilesPath.Replace('\','/'))/.vim" `
                -replace '{{vimrc}}',"$dotfilesPath\.vimrc"
        } | Out-File -FilePath $vimrcPath -Encoding utf8
    } 

    Write-Host "Updating vim plugins..."
    vim +PlugInstall +qall
} else {
    Write-Warning "vim not found"
}

# PS All Hosts Profile
if (Test-Path $PROFILE.CurrentUserAllHosts) {
    Write-Warning "Profile already exists at $($PROFILE.CurrentUserAllHosts)"
} else {
    Write-Host "Creating PS profile at $($PROFILE.CurrentUserAllHosts)"

    New-Item -type file -force $PROFILE.CurrentUserAllHosts | Out-Null

    ". $dotfilesPath\WindowsPowershell\profile.ps1" | 
        Out-File -FilePath $PROFILE.CurrentUserAllHosts -Encoding utf8 -Force
}

# PS Windows Powershell Profile
if (Test-Path $PROFILE.CurrentUserCurrentHost) {
    Write-Warning "Profile already exists at $($PROFILE.CurrentUserCurrentHost)"
} else {
    Write-Host "Creating PS profile at $($PROFILE.CurrentUserCurrentHost)"

    New-Item -type file -force $PROFILE.CurrentUserCurrentHost | Out-Null

    ". $dotfilesPath\WindowsPowershell\Microsoft.PowerShell_profile.ps1" | 
        Out-File -FilePath $PROFILE.CurrentUserCurrentHost -Encoding utf8 -Force
}
