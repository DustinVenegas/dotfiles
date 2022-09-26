function New-SourceCheckout {
    param(
        <#
        Remote path for the repo
        #>
        [Parameter(Mandatory)]
        [string]$remote
    )
    begin {
        $SourceDir = Resolve-Path -Path '~\Source'

        $matchDestFnMap = @{
            '(?:https\://|git\@)github.com/(?<user>.+)/(?<proj>.+)\.git'  = {
                Join-Path $SourceDir 'github.com' $Matches.User $Matches.proj
            }
            'https://aur.archlinux.org/(?<proj>.+)\.git'                  = {
                Join-Path $SourceDir 'aur.archlinux.org' $Matches.proj
            }
            'ssh://git\@git.smkent.net:2202/(?<user>.+)/(?<proj>.+)\.git' = {
                Join-Path $SourceDir 'github.com' $Matches.User $Matches.proj
            }
            'https://go.googlesource.com/(?<proj>.+)$'                    = {
                Join-Path $SourceDir 'go.googlesource.com' $Matches.proj
            }
        }

        $k = $matchDestFnMap.Keys | Where-Object { $remote -match $PSItem }
        if ((-not ($k)) -and (-not ($remote.EndsWith('.git')))) {
            Write-Verbose "Did you mean to add .git? Gotcha!"
            $remote = $remote + '.git'
            $k = $matchDestFnMap.Keys | Where-Object { $remote -match $_ }
        }

        if (!$k) {
            Write-Error "Missing SourceDir path handler for remote: $remote"
            return
        }

        $fn = $matchDestFnMap[$k]
        $dest = Invoke-Command $fn
    }
    process {

        if (-not (Test-Path $dest)) {
            New-Item -Force -ItemType Directory -Path $dest | Out-Null
        }
        Push-Location -Path $dest | Out-Null

        if (-not (git rev-parse --git-dir 2>&1 | Out-Null)) {
            git clone $remote .
        }

        $l = git remote get-url --push origin
        if ($l -ne $remote) {
            Write-Verbose "Remotes locations differ - input:$remote, existing checkout:$l"
        }

        Pop-Location | Out-Null
        Write-Output $dest
    }
}

New-SourceCheckout -remote @args
