require 'rails_helper'

RSpec.describe "Password resets", type: :request do
  include ActiveJob::TestHelper

  let!(:user) { create(:user, email: "user@example.com") }
  let(:token) { user.generate_token_for(:password_reset) }

  def reset_password(token:, password: "new-secret-password", confirmation: password)
    patch password_reset_path, params: { token: token, user: { password: password, password_confirmation: confirmation } }
  end

  describe "requesting a reset" do
    it "shows the form" do
      get new_password_reset_path

      expect(response).to have_http_status(:ok)
    end

    it "emails a reset link to a known user" do
      expect {
        post password_reset_path, params: { user: { email: user.email } }
      }.to have_enqueued_mail(PasswordMailer, :password_reset)

      expect(response).to redirect_to(root_path)
    end

    it "gives the same answer for unknown emails" do
      expect {
        post password_reset_path, params: { user: { email: "nobody@example.com" } }
      }.not_to have_enqueued_mail

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Check your email to reset your password")
    end
  end

  describe "using the link" do
    it "shows the form with a valid token" do
      get edit_password_reset_path(token: token)

      expect(response).to have_http_status(:ok)
    end

    it "sets the new password" do
      reset_password(token: token)

      expect(response).to redirect_to(home_path)
      expect(user.reload.authenticate("new-secret-password")).to be_truthy
    end

    it "rejects an invalid token" do
      get edit_password_reset_path(token: "invalid")

      expect(response).to redirect_to(new_password_reset_path)
      expect(flash[:alert]).to match(/Invalid token/)
    end

    it "rejects an expired token" do
      token

      travel 16.minutes
      reset_password(token: token)

      expect(response).to redirect_to(new_password_reset_path)
      expect(user.reload.authenticate("secret-password")).to be_truthy
    end

    it "only works once" do
      used_token = token
      reset_password(token: used_token)

      reset_password(token: used_token, password: "another-secret-password")

      expect(response).to redirect_to(new_password_reset_path)
      expect(user.reload.authenticate("new-secret-password")).to be_truthy
    end

    it "rejects a short password" do
      reset_password(token: token, password: "short")

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.authenticate("secret-password")).to be_truthy
    end
  end
end
