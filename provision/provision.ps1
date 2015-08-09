param(
    [string]$dotfilesPath = (Resolve-Path "$PSScriptRoot\..")
)

Write-Host "Provisiong against dotfiles located at $dotfilesPath"

function Test-Application {
    <#
    .SYNOPSIS
    Test if the full application name exists in the current environment

    .DESCRIPTION
    Test if any applications available through Get-Command match the parameter exactly

    .PARAMETER $name
    The full name of the application to test

    .RETURNS
    A boolean if the application exists

    .EXAMPLE
    # Returns $false

    Test-Application 'choco'

    .EXAMPLE
    # Returns $true
    Test-Application 'choco.exe'
    #>
    param([string]$name)

    (Get-Command -Type Application | Where-Object { $_.Name -eq $name }) -ne $null
}

# TODO: fsutil any easier?

# Provision Choco
if (Test-Application 'choco.exe') {
    Write-Host "Installing packages"
    # Add personal NuGet packages
    choco source add -n=myget -s https://www.myget.org/F/dustinvenegas/

    # TODO: conditionally install environments based on dev, ossvsdev, comvsdev, etc
    choco install "$dotfilesPath\provision\general-packages.config"
    choco install "$dotfilesPath\provision\development-packages.config"
} else {
    Write-Warning "choco not found"
}

# Pin any non-pinned app that's installed and auto-updates NOTE: Choco doesn't support pin on install
$autoUpdates = @('google-chrome-x64','github');
$pinned = choco pin -r | %{ $_ -Split '\|' | Select-Object -First 1 } 
choco list -lo -r | %{ 
        $_ -Split '\|' | Select-Object -First 1 
    } | Where-Object { 
        ($autoUpdates -contains $_) -and ($pinned -NotContains $_)
    } | Foreach-Object {
        choco pin add -n="$_" -r
    }

# Provision VIM
if (Test-Application gvim.exe) {
    $vimrcPath = "$HOME\.vimrc"
    if (Test-Path $vimrcPath) {
        Write-Warning ".vimrc already exists at $vimrcPath"
    } else {
        Write-Host "Creating default .vimrc at $vimrcPath"

        $dotfilesPathLinux = $dotfilesPath.Path.Replace("$home",'~')
        Get-Content "$dotfilesPathLinux\provision\.vimrc.template" | %{
            $_  -replace '{{date}}',(Get-Date) `
                -replace '{{vimrtp}}',"$($dotfilesPathLinux.Replace('\','/'))/.vim" `
                -replace '{{vimrc}}',"$dotfilesPathLinux\.vimrc"
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

# Mercurial
if (Test-Path "$HOME\.hgrc") {
    Write-Warning "HG config already exists at $HOME\.hgrc"
} else {
    Write-Host "Creating HG config at $HOME\.hgrc"
    "%include ~/dotfiles/.hgrc" | Out-File -FilePath $HOME\.hgrc -Encoding utf8 -Force
}
