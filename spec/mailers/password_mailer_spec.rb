require "rails_helper"

RSpec.describe PasswordMailer, type: :mailer do
  describe "#password_reset" do
    let(:user) { create(:user, email: "user@example.com") }
    let(:token) { user.generate_token_for(:password_reset) }
    let(:mail) { described_class.with(user: user, token: token).password_reset }

    it "is sent to the user" do
      expect(mail.to).to eq([ "user@example.com" ])
    end

    it "contains the reset link with the token" do
      link = URI(mail.body.encoded[/href="([^"]+)"/, 1])

      expect(link.path).to eq("/password_reset/edit")
      expect(URI.decode_www_form(link.query).to_h["token"]).to eq(token)
    end
  end
end
