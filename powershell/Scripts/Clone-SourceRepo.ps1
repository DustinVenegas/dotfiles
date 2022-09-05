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
            '(?:https\://|git\@)github.com:(?<user>.+)/(?<proj>.+)\.git'  = {
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
    }
    process {
        $dest = ''
        $k = $matchDestFnMap.Keys | Where-Object { $remote -match $_ }

        $neededHelp = $false
        if ((-not ($k)) -and (-not ($remote.EndsWith('.git')))) {
            $neededHelp = $true
            $remote = $remote + '.git'
            $k = $matchDestFnMap.Keys | Where-Object { $remote -match $_ }
        }

        if (!$k) {
            Write-Error "Missing SourceDir path handler for remote: $remote"
            return
        }

        if ($neededHelp) {
            Write-Verbose "Did you mean to add .git? Gotcha!"
        }

        $fn = $matchDestFnMap[$k]
        $dest = Invoke-Command $fn

        if (Test-Path $dest) {
            Push-Location -Path $dest | Out-Null
            $l = git remote get-url --push origin
            Pop-Location | Out-Null

            Write-Verbose "Source repo already exists at destination $dest"
            if ($l -ne $remote) {
                Write-Verbose "Remotes locations differ - input:$remote, existing checkout:$l"
            }
        } else {
            Write-Verbose "Checked out remote $remote to destination $dest"
            #git checkout $remote $dest
        }

        Write-Output $dest
    }
}

New-SourceCheckout -remote @args
