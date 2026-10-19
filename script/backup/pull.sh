#!/bin/bash
# Runs on the Mac (launchd): copies new server backups locally and keeps the last 7 days.
set -euo pipefail

SERVER=${SERVER:-digitalocean}
REMOTE_DIR=${REMOTE_DIR:-/var/backups/easy-admin}
LOCAL_DIR=${LOCAL_DIR:-$HOME/Backups/easy-admin}
KEEP_DAYS=${KEEP_DAYS:-7}

mkdir -p "$LOCAL_DIR"
chmod 700 "$LOCAL_DIR"

rsync -a --ignore-existing -e "ssh -o BatchMode=yes" "$SERVER:$REMOTE_DIR/" "$LOCAL_DIR/"

find "$LOCAL_DIR" -name 'easy_admin_*.sql.gz' -mtime +$((KEEP_DAYS - 1)) -delete

echo "$(date '+%F %T') Backups in $LOCAL_DIR: $(ls "$LOCAL_DIR" | wc -l | tr -d ' ')"
