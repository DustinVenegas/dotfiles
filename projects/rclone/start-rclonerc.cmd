@ECHO OFF
REM Starts eclone with the rc or 'remote control' web service enabled.

REM Ensure password file exists.
if not exist %USERPROFILE%\AppData\Local\rclonerc\.rclonercp (
    Echo Need to create a password at %USERPROFILE%\AppData\Local\rclonerc\.rclonercp
    Exit /b 2
)

REM Read credentials.
set RCLONE_RC_USER=rclone
set /p RCLONE_RC_PASS=<%USERPROFILE%\AppData\Local\rclonerc\.rclonercp

REM Validate credentials are not empty.
if [%RCLONE_RC_PASS%]==[] (
    Exit /b 3
)

REM Run rclone rcd, with...
REM    --rc-web-gui                     Enbale the web GUI at http://127.0.0.1:5572/
REM    --rc-web-gui-update              Update to the latest GUI on start
REM    --rc-web-gui-no-open-browser     Don't try to open a browser upon starting
rclone rcd --rc-web-gui --rc-web-gui-update --rc-web-gui-no-open-browser

REM Handle rclone exit code.
IF %ERRORLEVEL% NEQ 0 (Echo start-rclinlerc: 'rclone rcd' exited with an error. &Exit /b 1)
