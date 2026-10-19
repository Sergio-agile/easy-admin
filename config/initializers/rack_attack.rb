# frozen_string_literal: true

# Throttle login and password reset attempts to slow down brute force attacks.
# Counters live in Redis when available so they survive restarts and are shared
# between Puma workers.
Rack::Attack.cache.store =
  if ENV["REDIS_URL"].present? && !Rails.env.test?
    ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_URL"], namespace: "rack_attack")
  else
    ActiveSupport::Cache::MemoryStore.new
  end

class Rack::Attack
  LOGIN_PATH = "/session"
  PASSWORD_RESET_PATH = "/password_reset"

  def self.submitted_email(req)
    req.params.dig("user", "email").to_s.strip.downcase.presence
  end

  throttle("logins/ip", limit: 10, period: 3.minutes) do |req|
    req.ip if req.post? && req.path == LOGIN_PATH
  end

  throttle("logins/email", limit: 5, period: 15.minutes) do |req|
    submitted_email(req) if req.post? && req.path == LOGIN_PATH
  end

  throttle("password_resets/ip", limit: 5, period: 15.minutes) do |req|
    req.ip if req.post? && req.path == PASSWORD_RESET_PATH
  end

  throttle("password_resets/email", limit: 3, period: 1.hour) do |req|
    submitted_email(req) if req.post? && req.path == PASSWORD_RESET_PATH
  end

  self.throttled_responder = lambda do |req|
    retry_after = req.env["rack.attack.match_data"][:period].to_i
    body = <<~HTML
      <!DOCTYPE html>
      <html>
        <head><meta charset="utf-8"><title>Too many attempts</title></head>
        <body style="font-family: sans-serif; text-align: center; padding-top: 4rem;">
          <h1>Too many attempts</h1>
          <p>Please wait a few minutes and try again.</p>
          <p><a href="/">Back to login</a></p>
        </body>
      </html>
    HTML

    [429, { "content-type" => "text/html", "retry-after" => retry_after.to_s }, [body]]
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn("[Rack::Attack] Throttled #{req.env['rack.attack.matched']} ip=#{req.ip} path=#{req.path}")
end
