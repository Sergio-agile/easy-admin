namespace :access_logs do
  desc "Delete access-log rows older than AccessLog::RETENTION (run weekly by a systemd timer)"
  task purge: :environment do
    deleted = AccessLog.purge_expired
    puts "Deleted #{deleted} access-log rows older than #{AccessLog::RETENTION.inspect}"
  end
end
