function Set-JsonValue {
    <#
    .Synopsis
        Sets multiple JSON values in a file.
    .Description
        Create or update a JSON file by directly setting JSON values.
    .Parameter Path
        Path where the JSON file is located.
    .Parameter InputObject
        InputObject is a hashtable containing JSON keys to their updated values.
    .Example
        Set-JsonValue -Path foo.json -InputObject @{ FieldA = 'SomeValue' }
        Sets 'FieldA' to 'SomeValue' in 'foo.json'.
    .Example
        Set-JsonValue -Path foo.json -InputObject @{ FieldA = 'SomeValue' } -WhatIf
        WhatIf returns what would be written to 'foo'json'.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory, Position = 0)]
        $Path,
        [Parameter(Mandatory, Position = 1)]
        [Hashtable]
        $InputObject
    )
    begin {
        $data = '{}' | ConvertFrom-Json
        if (Test-Path $Path) {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
        }
    }
    process {
        $shouldWrite = $false

        foreach ($key in $InputObject.Keys) {
            $value = $InputObject[$key]
            $property = $data.PSobject.Properties | Where-Object -Property Name -EQ $key
            $valuesEquivalent = $false

            if ($property) {
                # Compare $value first when calculating valuesEquivlant so the cast is bound to $value.
                $valuesEquivalent = $value -eq $property.Value
                Write-Debug "Actual: $($property.Value) Expected: $value Equivilant: $valuesEquivalent"
            }

            if (!$valuesEquivalent) {
                Write-Verbose "Setting JSON Value of $key."

                if (Get-Member -InputObject $data -Name $key -MemberType Properties) {
                    $data.$key = $value
                } else {
                    $data | Add-Member -NotePropertyName $Key -NotePropertyValue $value
                }

                $shouldWrite = $true
                Write-Debug "Property data.key is $($data.$key)"
            }
        }

        $json = ConvertTo-Json -InputObject $data
        Write-Debug "Json: $json"

        if ($shouldWrite -and $PSCmdlet.ShouldProcess("Destination: $Path")) {
            Write-Verbose "Writing JSON to $Path"
            $json | Set-Content -Path $Path -Encoding UTF8
        }

        [PSCustomObject]@{
            Name        = 'Set-JsonValue'
            NeedsUpdate = $shouldWrite
            Entity      = "$Path, $key"
            Properties  = @{
                Json = $json
            }
        }
    }
}
