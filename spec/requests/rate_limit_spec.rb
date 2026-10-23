require 'rails_helper'

RSpec.describe "Rate limiting", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "secret-password") }

  # Throttles count per fixed window; freeze time at an hour boundary so no
  # example straddles two windows and sees its counter reset.
  before do
    Rack::Attack.reset!
    travel_to Time.current.beginning_of_hour
  end

  def attempt_login(email:, password: "wrong", ip: "1.2.3.4")
    post session_path, params: { user: { email: email, password: password } }, env: { "REMOTE_ADDR" => ip }
  end

  def request_password_reset(email:, ip: "1.2.3.4")
    post password_reset_path, params: { user: { email: email } }, env: { "REMOTE_ADDR" => ip }
  end

  describe "login" do
    it "allows a correct login" do
      attempt_login(email: user.email, password: "secret-password")

      expect(response).to redirect_to(home_path)
    end

    it "blocks an email after 5 failed attempts, even from different IPs" do
      5.times { |i| attempt_login(email: user.email, ip: "10.0.0.#{i}") }
      expect(response).to have_http_status(:unprocessable_content)

      attempt_login(email: user.email, password: "secret-password", ip: "10.0.0.99")

      expect(response).to have_http_status(:too_many_requests)
      expect(response.headers["retry-after"]).to eq(15.minutes.to_i.to_s)
    end

    it "treats email case and spaces as the same account" do
      5.times { attempt_login(email: "  USER@example.com ") }

      attempt_login(email: user.email)

      expect(response).to have_http_status(:too_many_requests)
    end

    it "blocks an IP after 10 attempts with different emails" do
      10.times { |i| attempt_login(email: "nobody#{i}@example.com") }
      expect(response).to have_http_status(:unprocessable_content)

      attempt_login(email: "another@example.com")

      expect(response).to have_http_status(:too_many_requests)
    end

    it "does not block other IPs or emails" do
      10.times { |i| attempt_login(email: "nobody#{i}@example.com") }

      attempt_login(email: user.email, password: "secret-password", ip: "5.6.7.8")

      expect(response).to redirect_to(home_path)
    end
  end

  describe "password reset" do
    it "blocks an email after 3 requests" do
      3.times { |i| request_password_reset(email: user.email, ip: "10.0.0.#{i}") }
      expect(response).to redirect_to(root_path)

      request_password_reset(email: user.email, ip: "10.0.0.99")

      expect(response).to have_http_status(:too_many_requests)
    end

    it "blocks an IP after 5 requests" do
      5.times { |i| request_password_reset(email: "nobody#{i}@example.com") }

      request_password_reset(email: "another@example.com")

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
