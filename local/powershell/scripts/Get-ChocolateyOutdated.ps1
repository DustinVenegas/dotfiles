choco outdated --limit-output | ConvertFrom-Csv -Delimiter '|' -Header 'name', 'v-old', 'v-new', 'pin' | Where-Object { $PSItem.pin -ne 'true' } | Format-Table -AutoSize
