# Database backups

- **Server**: `easy-admin-backup.timer` runs `backup.sh` every day at 03:00 UTC.
  Backups go to `/var/backups/easy-admin` (last 7 days).
- **Mac**: launchd agent `com.easy-admin.backup-pull` runs `pull.sh` every day at 10:00
  (or on wake if the Mac was asleep). Backups go to `~/Backups/easy-admin` (last 7 days).
  Log: `/tmp/easy-admin-backup-pull.log`.

Backups contain patient data: never copy them into the repo.

## Restore

On the server:

```
cd /opt/easy-admin
ls -lt /var/backups/easy-admin
script/backup/restore.sh /var/backups/easy-admin/easy_admin_YYYYMMDD_HHMMSS.sql.gz
```

To restore from a Mac copy, upload it first:

```
scp ~/Backups/easy-admin/easy_admin_YYYYMMDD_HHMMSS.sql.gz digitalocean:/var/backups/easy-admin/
```

## Install

Server:

```
cp script/backup/easy-admin-backup.{service,timer} /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now easy-admin-backup.timer
```

Mac:

```
cp script/backup/com.easy-admin.backup-pull.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.easy-admin.backup-pull.plist
```
