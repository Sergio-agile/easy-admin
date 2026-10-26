module QueryCounter
  IGNORED = %w[SCHEMA TRANSACTION].freeze

  # Counts the SQL queries the block sends to the database (cache hits excluded).
  def count_queries(&)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:cached] || IGNORED.include?(payload[:name]) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter, type: :request
end
