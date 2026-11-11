#!/bin/bash
# Runs on the Mac (launchd): copies new encrypted server backups locally, checks that each
# new one decrypts with the local key, and keeps the last 7 days.
set -euo pipefail

SERVER=${SERVER:-digitalocean}
REMOTE_DIR=${REMOTE_DIR:-/var/backups/easy-admin}
LOCAL_DIR=${LOCAL_DIR:-$HOME/Backups/easy-admin}
KEEP_DAYS=${KEEP_DAYS:-7}
AGE_IDENTITY=${AGE_IDENTITY:-$HOME/.config/easy-admin/backup-age-key.txt}
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

mkdir -p "$LOCAL_DIR"
chmod 700 "$LOCAL_DIR"

new_files=$(rsync -a --ignore-existing --out-format='%n' -e "ssh -o BatchMode=yes" \
  "$SERVER:$REMOTE_DIR/" "$LOCAL_DIR/")

for name in $new_files; do
  case "$name" in
    *.age)
      if ! age -d -i "$AGE_IDENTITY" "$LOCAL_DIR/$name" | gzip -t; then
        echo "$(date '+%F %T') ERROR: $name does not decrypt with $AGE_IDENTITY" >&2
        exit 1
      fi
      ;;
  esac
done

find "$LOCAL_DIR" -name 'easy_admin_*.sql.gz*' -mtime +$((KEEP_DAYS - 1)) -delete

echo "$(date '+%F %T') Backups in $LOCAL_DIR: $(ls "$LOCAL_DIR" | wc -l | tr -d ' ')"
