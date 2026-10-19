require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  def update_password(challenge:, password: "new-secret-password", confirmation: password)
    patch password_path, params: { user: { password_challenge: challenge, password: password, password_confirmation: confirmation } }
  end

  it "shows the form" do
    get edit_password_path

    expect(response).to have_http_status(:ok)
  end

  it "changes the password when the current one is correct" do
    update_password(challenge: "secret-password")

    expect(response).to redirect_to(edit_password_path)
    expect(user.reload.authenticate("new-secret-password")).to be_truthy
  end

  it "requires the current password" do
    update_password(challenge: "wrong-password")

    expect(response).to have_http_status(:unprocessable_content)
    expect(user.reload.authenticate("secret-password")).to be_truthy
  end

  it "requires the current password even if the field is missing" do
    patch password_path, params: { user: { password: "new-secret-password", password_confirmation: "new-secret-password" } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(user.reload.authenticate("secret-password")).to be_truthy
  end

  it "rejects a mismatched confirmation" do
    update_password(challenge: "secret-password", confirmation: "something-else-long")

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rejects a short password" do
    update_password(challenge: "secret-password", password: "short")

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("too short")
  end
end
