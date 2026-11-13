# Records an AccessLog row for the current user and request.
module AccessLogging
  private

  def log_access(action, patient: nil, consultation: nil, user: current_user)
    AccessLog.record(action, user:, ip_address: request.remote_ip, patient:, consultation:)
  end
end
