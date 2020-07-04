function Inner {
    param (
        $SomeParam
    )

    Write-Host "Inner called with $SomeParam"
}
function outer {
    $a = @{
        SomeParam = 'Foo'
    }

    Invoke-Command -ScriptBlock {
        param($SomeParam)
        & Inner @a
    }
}

outer
