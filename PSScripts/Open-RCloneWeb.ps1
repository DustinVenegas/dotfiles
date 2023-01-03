#Requires -RunAsAdministrator

$name = 'rclonerc'
$RC_USER = 'rclone'
$RC_PASS = (Get-Content "C:\WINDOWS\System32\config\systemprofile\AppData\Local\$name\.rclonercp")

Start-Process "http://$RC_USER`:$RC_PASS@localhost:5572/"
