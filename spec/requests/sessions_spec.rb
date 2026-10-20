require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, email: "user@example.com") }

  describe "GET /" do
    it "shows the login form" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(session_path)
    end
  end

  describe "POST /session" do
    it "logs the user in with valid credentials" do
      sign_in user

      expect(response).to redirect_to(home_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "accepts the email with different case and spaces" do
      post session_path, params: { user: { email: " USER@Example.com ", password: "secret-password" } }

      expect(response).to redirect_to(home_path)
    end

    it "rejects a wrong password" do
      sign_in user, password: "wrong-password"

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Invalid email / password")

      get home_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects an unknown email" do
      post session_path, params: { user: { email: "nobody@example.com", password: "secret-password" } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "issues a new session id on login" do
      get root_path
      old_cookie = cookies["_easy_admin_session"]

      sign_in user

      expect(cookies["_easy_admin_session"]).to be_present
      expect(cookies["_easy_admin_session"]).not_to eq(old_cookie)
    end
  end

  describe "DELETE /session" do
    it "logs the user out" do
      sign_in user

      delete session_path

      expect(response).to redirect_to(root_path)
      get home_path
      expect(response).to redirect_to(root_path)
    end
  end
end
