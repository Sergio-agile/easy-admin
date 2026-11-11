#!/bin/bash
# Runs on the server: restores the production database from a gzipped SQL dump.
# Backups are encrypted and the key is not on the server, so decrypt on the Mac and pipe
# the dump in (see README.md):
#   age -d -i KEY backup.sql.gz.age | ssh digitalocean 'RESTORE_CONFIRM=restore /opt/easy-admin/script/backup/restore.sh -'
# A plain .sql.gz file on the server also works: script/backup/restore.sh file.sql.gz
set -euo pipefail

source=${1:?Usage: $0 <backup.sql.gz | ->}
APP_DIR=${APP_DIR:-/opt/easy-admin}

if [ "$source" = "-" ]; then
  [ "${RESTORE_CONFIRM:-}" = "restore" ] || { echo "Reading from stdin: set RESTORE_CONFIRM=restore"; exit 1; }
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' EXIT
  chmod 600 "$tmp"
  cat > "$tmp"
  file=$tmp
else
  file=$source
  [ -f "$file" ] || { echo "File not found: $file"; exit 1; }
fi
gzip -t "$file"

cd "$APP_DIR"
compose() { docker compose -f docker-compose.prod.yml --env-file .env.production "$@"; }

if [ "${RESTORE_CONFIRM:-}" != "restore" ]; then
  read -r -p "This will REPLACE the production database with $source. Type 'restore' to continue: " answer
  [ "$answer" = "restore" ] || { echo "Aborted"; exit 1; }
fi

compose stop web
gunzip -c "$file" | compose exec -T db psql -U easy_admin -d easy_admin_production -v ON_ERROR_STOP=1 -q
compose start web

echo "Database restored from $source"
