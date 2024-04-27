# rclone todo

- Turn off hash fingerprinting for cached files when using local, s3, or swift backends with: `--vfs-fast-fingerprint`
- Turn off modtime checks for S3 since they can be slow AND require a transaction to check. `--no-modtime`. Use `--use-server-modtime` instead?
- Set an explicit --cache-dir to prevent vfs file collisions in cache.
- Read on finer [VFS caching details](https://rclone.org/commands/rclone_mount/#vfs-file-caching)
- Create a systemd [service](https://github.com/rclone/rclone/wiki/Systemd-rclone-mount). See alternative at [systemd service](https://github.com/animosity22/homescripts/blob/master/systemd/rclone-drive.service)
- Create a PowerShell module with your newfound knowledge
- Setup powershell completion: `rclone completion powershell | Out-String | Invoke-Expression`
- Encrypt file on disk with [PowerShell and DPAPI](https://github.com/rclone/rclone/wiki/Windows-PowerShell-use-rclone-password-command-for-config-file-password)
