require "rails_helper"

# Every request that shows or changes a patient's data leaves an AccessLog row.
RSpec.describe "Access log", type: :request do
  let(:user) { create(:user) }
  let(:patient) { create(:patient) }
  let(:consultation) { patient.consultations.first }
  let(:notes) { { consultation: { notes_before: "Antes" } } }

  def last_log = AccessLog.order(:id).last

  describe "sessions" do
    it "logs logins, failed logins and logouts" do
      sign_in user
      expect(last_log).to have_attributes(action: "login", user:, ip_address: "127.0.0.1")

      delete session_path
      expect(last_log).to have_attributes(action: "logout", user:)

      sign_in user, password: "wrong-password"
      expect(last_log).to have_attributes(action: "login_failed", user: nil)
    end
  end

  context "when signed in" do
    before { sign_in user }

    it "logs viewing, creating and updating a patient" do
      get patient_path(patient)
      expect(last_log).to have_attributes(action: "patient_viewed", user:, patient:)

      post patients_path, params: { patient: { first_name: "Ana", last_name: "López" } }
      expect(last_log).to have_attributes(action: "patient_created", patient: Patient.find_by!(first_name: "Ana"))

      patch patient_path(patient), params: { patient: { first_name: "Anabel" } }, as: :turbo_stream
      expect(last_log).to have_attributes(action: "patient_updated", patient:)
    end

    it "does not log a patient update that fails validation" do
      expect {
        patch patient_path(patient), params: { patient: { first_name: "" } }, as: :turbo_stream
      }.not_to change(AccessLog, :count)
    end

    it "logs the history once per visit, not for each older page loaded on scroll" do
      expect { get patient_history_path(patient) }.to change(AccessLog, :count).by(1)
      expect(last_log).to have_attributes(action: "history_viewed", patient:)

      expect {
        get patient_history_path(patient, page: 2), headers: { "Turbo-Frame" => "history_page_2" }
      }.not_to change(AccessLog, :count)
    end

    it "logs viewing, creating and updating a consultation and downloading its report" do
      get edit_patient_consultation_path(patient, consultation)
      expect(last_log).to have_attributes(action: "consultation_viewed", consultation:, patient:)

      post patient_consultations_path(patient), params: notes
      expect(last_log).to have_attributes(action: "consultation_created", patient:)

      patch patient_consultation_path(patient, consultation), params: notes
      expect(last_log).to have_attributes(action: "consultation_updated", consultation:)

      get download_consultation_path(consultation)
      expect(last_log).to have_attributes(action: "report_downloaded", consultation:, patient:)
    end

    it "logs edits made from the patient history" do
      patch patient_history_entry_path(patient, consultation), params: notes
      expect(last_log).to have_attributes(action: "consultation_updated", consultation:)

      patch patient_today_consultation_path(patient), params: notes
      expect(last_log).to have_attributes(action: "consultation_created", consultation: patient.consultations.find_by!(date: Date.current))

      patch patient_today_consultation_path(patient), params: notes
      expect(last_log).to have_attributes(action: "consultation_updated")
    end
  end
end
