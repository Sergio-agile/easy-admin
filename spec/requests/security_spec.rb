require 'rails_helper'

RSpec.describe "Security", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "secret-password") }

  before { Rack::Attack.reset! }

  def log_in
    post session_path, params: { user: { email: user.email, password: "secret-password" } }
  end

  describe "Active Storage" do
    let(:blob_params) do
      { blob: { filename: "notes.txt", byte_size: 5, checksum: "XUFAKrxLKna5cZ2REBfFkg==", content_type: "text/plain" } }
    end

    it "rejects direct uploads without a session" do
      post rails_direct_uploads_path, params: blob_params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(ActiveStorage::Blob.count).to eq(0)
    end

    it "allows direct uploads for signed in users" do
      log_in

      post rails_direct_uploads_path, params: blob_params, as: :json

      expect(response).to have_http_status(:ok)
    end

    it "does not serve attachments without a session" do
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("hello"), filename: "notes.txt")

      get rails_blob_path(blob)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "idle session timeout" do
    it "keeps the session while the user is active" do
      log_in

      travel 1.hour
      get home_path
      travel 1.hour + 30.minutes
      get home_path

      expect(response).to have_http_status(:ok)
    end

    it "logs the user out after 2 hours of inactivity" do
      log_in

      travel 2.hours + 1.minute
      get home_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/expired/)

      get home_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "Content Security Policy" do
    it "only allows the app's own scripts, with a nonce for inline ones" do
      get root_path

      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("script-src 'self' 'nonce-")
      expect(csp).to include("object-src 'none'")
      expect(csp).to include("frame-ancestors 'none'")
      expect(response.body).not_to include("ga.jspm.io")
    end
  end

  describe "log filtering" do
    it "filters personal and health data from logged params" do
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      params = {
        patient: { first_name: "Ana", last_name: "López", dni: "12345678Z", phone: "600000000",
                   address: "Calle 1", birth_date: "1990-01-01", email: "ana@example.com" },
        consultation: { notes_before: "dolor lumbar", notes_after: "mejora", notes_to_send: "ejercicios" }
      }

      filtered = filter.filter(params)

      expect(filtered[:patient].values).to all(eq("[FILTERED]"))
      expect(filtered[:consultation].values).to all(eq("[FILTERED]"))
    end
  end
end
