
function Get-GitBranchesAheadBehind {
    git fetch --all
    git remote prune origin
    git branch -r | ?{ 
            $_ -ne 'master' 
        } | %{
            $aheadBehind = git rev-list --left-right --count master...$($_.Trim())
            $aheadBehind = $aheadBehind -split '\t'
            $lastAuthor = git log -n 1 $_ --format='%an'

            if ($aheadBehind[1] -eq 0) {
                Write-Host "$lastAuthor $_ behind $($aheadBehind[0]) ahead $($aheadBehind[1])"
            }
        }
}
