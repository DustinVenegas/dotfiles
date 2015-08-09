# Derived from http://www.tylerbutler.com/2012/05/how-to-install-python-pip-and-virtualenv-on-windows-with-powershell/

# Installs to c:\tools\python2. 
choco install python2 -y

# Installer makes $env:Path variable for c:\tools\python2, but not c:\tools\python2\scripts
$origPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$newPath = "$origPath;c:\tools\python2\scripts\"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

# Install VirtualEnv
pip install virtualenv

# Windows PowerShell VirtualEnv cmdlets
pip install virtualenvwrapper-powershell

# Make a VirtualEnv directory if it doesn't exist
New-Item '~\.virtualenvs' -type Directory

# PowerShell - Load 'em up
# Commands? Get-Command *virtualenv*
Import-Module virtualenvwrapper
