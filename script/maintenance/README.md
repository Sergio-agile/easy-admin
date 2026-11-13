# Scheduled maintenance

## Access-log purge

`easy-admin-purge-access-logs.timer` runs `bin/rails access_logs:purge` inside the `web`
container every Sunday at 04:00 UTC (after the 03:00 backup). It deletes access-log rows
older than `AccessLog::RETENTION` (three years, LOPDGDD art. 72). Output goes to the journal:

```
journalctl -u easy-admin-purge-access-logs
```

Install (server, once):

```
cp script/maintenance/easy-admin-purge-access-logs.{service,timer} /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now easy-admin-purge-access-logs.timer
systemctl start easy-admin-purge-access-logs.service   # run once now to check it works
```
