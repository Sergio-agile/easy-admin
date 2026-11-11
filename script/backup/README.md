# Database backups

- **Server**: `easy-admin-backup.timer` runs `backup.sh` every day at 03:00 UTC.
  Backups go to `/var/backups/easy-admin` (last 7 days), encrypted with
  [age](https://age-encryption.org) as `easy_admin_YYYYMMDD_HHMMSS.sql.gz.age`.
- **Mac**: launchd agent `com.easy-admin.backup-pull` runs `pull.sh` every day at 10:00
  (or on wake if the Mac was asleep). Backups go to `~/Backups/easy-admin` (last 7 days).
  Each new backup is test-decrypted with the local key. Log: `/tmp/easy-admin-backup-pull.log`.

Backups contain patient data: never copy them into the repo.

## Encryption keys

- **Public key** (encrypts): on the server in `/etc/easy-admin/backup-recipients.txt`.
  `backup.sh` refuses to run without it.
- **Private key** (decrypts): only on the Mac, in `~/.config/easy-admin/backup-age-key.txt`
  (mode 600), plus a copy in the password manager. It is never on the server, so a server
  compromise does not expose old backups. **If both copies are lost, the backups cannot be
  restored.**

Create a key pair (Mac, once):

```
brew install age
age-keygen -o ~/.config/easy-admin/backup-age-key.txt
age-keygen -y ~/.config/easy-admin/backup-age-key.txt   # prints the public key
```

## Restore

Decrypt on the Mac and stream the dump to the server (the key never leaves the Mac):

```
ls -lt ~/Backups/easy-admin
age -d -i ~/.config/easy-admin/backup-age-key.txt ~/Backups/easy-admin/easy_admin_YYYYMMDD_HHMMSS.sql.gz.age \
  | ssh digitalocean 'RESTORE_CONFIRM=restore /opt/easy-admin/script/backup/restore.sh -'
```

A server copy is decrypted the same way after `scp digitalocean:/var/backups/easy-admin/<file> .`.

## Install

Server:

```
apt-get install age
mkdir -p /etc/easy-admin && echo '<public key>' > /etc/easy-admin/backup-recipients.txt
cp script/backup/easy-admin-backup.{service,timer} /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now easy-admin-backup.timer
```

Mac:

```
cp script/backup/com.easy-admin.backup-pull.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.easy-admin.backup-pull.plist
```
