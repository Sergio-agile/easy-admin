# frozen_string_literal: true

if Rails.env.development? && ENV['RACK_PROFILER'] == 'true'
  require "rack-mini-profiler"

  Rack::MiniProfiler.config.position = 'bottom-left'
  Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = true
  Rack::MiniProfiler.config.show_total_sql_count = true

  # The initializer was required late, so initialize it manually.
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
