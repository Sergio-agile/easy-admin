#!/bin/bash
# Runs on the server (systemd timer): dumps the production database, encrypts it with age
# and keeps the last 7 days. Only the public key lives on the server; the private key that
# decrypts the backups is kept off the server (see README.md).
set -euo pipefail

APP_DIR=${APP_DIR:-/opt/easy-admin}
BACKUP_DIR=${BACKUP_DIR:-/var/backups/easy-admin}
KEEP_DAYS=${KEEP_DAYS:-7}
AGE_RECIPIENTS=${AGE_RECIPIENTS:-/etc/easy-admin/backup-recipients.txt}

[ -s "$AGE_RECIPIENTS" ] || { echo "Missing age recipients file: $AGE_RECIPIENTS" >&2; exit 1; }

cd "$APP_DIR"
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

file="$BACKUP_DIR/easy_admin_$(date +%Y%m%d_%H%M%S).sql.gz.age"

docker compose -f docker-compose.prod.yml --env-file .env.production exec -T db \
  pg_dump -U easy_admin -d easy_admin_production --clean --if-exists --no-owner \
  | gzip | age -R "$AGE_RECIPIENTS" > "$file.tmp"
mv "$file.tmp" "$file"
chmod 600 "$file"

find "$BACKUP_DIR" -name 'easy_admin_*.sql.gz*' -mtime +$((KEEP_DAYS - 1)) -delete

echo "Backup created: $file ($(du -h "$file" | cut -f1))"
