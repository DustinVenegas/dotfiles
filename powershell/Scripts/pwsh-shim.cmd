@REM Runs the associated PowerShell script (.ps1) with the same
@REM root file name and directory as this batch file. For example:
@REM     foo.cmd --executes--> foo.ps1
@REM ----------------------------------------------------------------------------
@REM %~dpn0 expands to full path minus file extension of the batch file. 
@pwsh -NoLogo -NonInteractive -NoProfile -File %~dpn0.ps1