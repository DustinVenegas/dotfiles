#requires -modules PowerShellForGitHub

function Checkout-PersonalGitHubRepos() {
    [CmdletBinding()]
    param()
    begin {
        $SourceDir = Resolve-Path -Path '~\Source'
        $owner = 'DustinVenegas'
    }
    process {
        Get-GitHubRepository -OwnerName $owner |
            Select-Object -ExpandProperty name |
            ForEach-Object {
                New-SourceCheckout "git@github.com:$owner/$PSItem.git"
            }
    }
}
