module AuthenticationHelpers
  PASSWORD = "secret-password".freeze

  def sign_in(user, password: PASSWORD)
    post session_path, params: { user: { email: user.email, password: password } }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.before(type: :request) { Rack::Attack.reset! }
end
