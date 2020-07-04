- Unify bootstrap.ps1 documentation
- Unify brackets (on same line)
- Unify README.md documentation
- Code Sample:
```ps1
    # Change preference from SilentlyContinue to Continue to increase verbosity.
    $VerbosePreference = Continue
    $InformationPreference = Continue
    $DebugPreference = Continue

    # Determine what would be done.
    ./bootstrap.ps1 -whatif

    # Do it, and save the results to a variable for inspection.
    $results = ./bootstrap.ps1
```
