@REM Runs the associated PowerShell script (.ps1) with the same
@REM root file name and directory as this batch file. For example:
@REM     foo.cmd --executes--> foo.ps1
@REM ----------------------------------------------------------------------------
@REM   %~dpn0     expands to full path minus file extension of the batch file.
@REM   -TaskList  job.ps1 parameter
@REM   %*         expands all batchfile arguments.
@pwsh -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File "%~dpn0.ps1" %*
@REM ----------------------------------------------------------------------------
@REM Exit the batchfile with the last command exitcode.
@EXIT /B %ERRORLEVEL%
