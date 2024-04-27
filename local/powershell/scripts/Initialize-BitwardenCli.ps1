#Requires -Modules Microsoft.Powershell.SecretManagement, Microsoft.Powershell.SecretStore

# TODO: Allow interactive unlock after PSILoveBackups is moved into its own job.
$secretStorePasswordPath = Join-Path -Path $HOME -ChildPath 'PSILoveBackups.blob'
Unlock-SecretStore -Password (Import-Clixml -Path $secretStorePasswordPath)

$env:BW_SESSION=$(Get-Secret -Name BW_SESSION -Vault 'dotfiles' -AsPlainText -ErrorAction Stop)
