#Requires -RunAsAdministrator

$name = 'rclonerc'
$env:RCLONE_RC_USER = 'rclone'
$env:RCLONE_RC_PASS = (Get-Content "C:\WINDOWS\System32\config\systemprofile\AppData\Local\$name\.rclonercp")

# NOTE: Escape double quotes with slahes (\") for vfsOpt, fs, and mountPoint when calling from PowerShell.
$want = @{
    'P:'                     = @{
        fs   = 'fannypack-backblaze-s3'
        path = '/fannypack'
        opts = @('vfsOpt={\"CacheMode\": 2, \"FastFingerprint\": true}')
    }
    "$HOME\KeePass\Fastmail" = @{
        fs   = 'fastmail'
        path = '/dustin.venegas.me/files/apps/keepass'
        opts = @('vfsOpt={\"CacheMode\": 2, \"FastFingerprint\": true}')
    }
}

$existing = rclone rc mount/listmounts | ConvertFrom-Json | Select-Object -ExpandProperty mountPoints
foreach ($w in $want.GetEnumerator()) {
    if (-not ($existing | Where-Object { ($_.MountPoint -eq $w.Key) -and ($_.Fs -eq $w.Value.fs) })) {
        Write-Host "Mounting $($w.Value.fs) to $($w.Key) with opts $($w.Value.opts)"
        $fsm = '{0}:{1}' -f $w.Value.fs, $w.Value.path
        $p = @(
            "fs=$fsm",
            "mountPoint=$($w.Key)"
        )
        $o = $w.Value.opts
        rclone rc mount/mount @p @o
        $LEC = $LASTEXITCODE
        if ($LEC) {
            Write-Error "rclone exited with an error code: $LEC"
        }
    }
}
