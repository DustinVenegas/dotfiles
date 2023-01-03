#Requires -Version 7
<#
.SYNOPSIS
Download the KEXP Song of the Day.
.DESCRIPTION
Download music from the KEXP Sone of the Day RSS feed that does not
currently exist in the destination directory.
.NOTES
Song of the Day Podcast: <https://www.kexp.org/podcasts/song-of-the-day/>
#>
param(
    [string]$dest = (Join-Path $HOME Music KEXP),
    [string]$rssURI = 'https://www.omnycontent.com/d/playlist/bad5d079-8dcb-4630-8770-aa090049131d/32b2ac38-5a48-4300-9fa6-aa40002038b5/4ac1c451-4315-4096-ab9b-aa40002038c4/podcast.rss'
)
begin {
    Function Remove-InvalidFileNameChars {
        param(
            [Parameter(Mandatory = $true,
                Position = 0,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
            [String]$Name
        )

        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
        $re = '[{0}]' -f [RegEx]::Escape($invalidChars)
        return ($Name -replace $re)
    }

    Function Download-MissingSongsOfTheDay {
        param(
            [xml]$x
        )

        $x.rss.channel.item |
            Where-Object {
                $_.content -match '.*[\.omny\.fm\/].*[audio\.mp3].*'
            } | ForEach-Object {
                $e = $_.episode
                if (-not $e) { $e = '0' }
                [PSCustomObject]@{
                    Title     = $_.title[0];
                    Url       = "$(($_.content.url -match 'audio.mp3')[0]))";
                    EpisodeNo = $_.episode;
                    Published = [DateTime]$_.pubDate;
                    FileName  = "$e - $($_.title[0]).mp3" | Remove-InvalidFileNameChars;
                }
            } | Set-Variable res

        $i = 0
        $grp = $res | Where-Object { -not (Test-Path (Join-Path $dest $_.FileName)) } |
            Sort-Object -Property Published -Descending


        $grp | ForEach-Object {
            $Percent = $($i / $grp.Length) * 100
            Write-Progress -Id 1 -ParentId 0 -Activity 'Updating' -Status "Complete:" -CurrentOperation "$($_.Title) - Download URL" -PercentComplete $Percent

            $f = Join-Path $dest $_.FileName
            Write-Verbose "Downloading $($_.Title) to $($_.FileName) from $($_.Url)"

            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $_.Url -OutFile $f
            $ProgressPreference = 'Continue'

            $i++
        }
        Write-Progress -Id 1 -ParentId 0 -Activity 'Updating' -Status "Complete:" -CurrentOperation "$($_.Title) - Download URL" -Completed
    }

    New-Item -Type Directory -Path $dest -Force | Out-Null
}
process {
    $PSStyle.Progress.View = 'Classic'

    $next = $rssUri
    $tot = 13
    while ($next) {
        Write-Host "Processing KEXP RSS Page: $next"
        $p = 1
        if ($next -match '[page=](?<page>\d+)$') {
            $p = $matches.page
        }

        $Percent = $($p / $tot) * 100
        Write-Progress -Id 0 -Activity 'Updating' -Status "Downloading missing songs from page" -CurrentOperation "Page: $p of $tot" -PercentComplete $Percent

        $ProgressPreference = 'SilentlyContinue'
        $r = Invoke-WebRequest $next
        $ProgressPreference = 'Continue'

        $x = [xml]($r.Content)
        $self = $x.rss.channel.link | Where-Object rel -EQ self | Select-Object -ExpandProperty href
        $next = $x.rss.channel.link | Where-Object rel -EQ next | Select-Object -ExpandProperty href

        # $first = $x.rss.channel.link | Where-Object rel -EQ first | Select-Object -ExpandProperty href
        $last = $x.rss.channel.link | Where-Object rel -EQ last | Select-Object -ExpandProperty href

        Write-Verbose "Self: $self, Next: $next"
        Download-MissingSongsOfTheDay $x

    }

    Write-Progress -Id 0 -Activity 'Updating' -Status "Downloading missing songs from page" -Completed
}
