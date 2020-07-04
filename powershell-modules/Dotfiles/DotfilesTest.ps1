Get-Module Dotfiles | Remove-Module -Force
Import-Module $PSScriptRoot\Dotfiles.psm1 -Force

InModuleScope Dotfiles {
    Describe 'SymbolicLink' {
        It 'Returns a value when a symbolic link exists' {

        }
    }
}
