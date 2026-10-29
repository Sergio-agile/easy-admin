require 'rails_helper'

RSpec.describe "Patient history", type: :request do
  let(:user) { create(:user) }
  let(:patient) { Patient.create!(first_name: "Ana", last_name: "López") }

  before { sign_in user }

  def consult(date, notes_before: "Antes #{date}")
    patient.consultations.create!(date: date, notes_before: notes_before, notes_after: "Durante #{date}", notes_to_send: "Enviar #{date}")
  end

  describe "GET /patients/:patient_id/history" do
    it "is linked from the patient page and links back to it" do
      get patient_path(patient)

      expect(response.body).to include(patient_history_path(patient))

      get patient_history_path(patient)

      expect(response.body).to include(%(href="#{patient_path(patient)}"), "Back to patient", %(data-action="history#toStart"))
    end

    it "shows every consultation's notes by date, newest at the bottom" do
      consult(Date.new(2026, 3, 1))
      consult(Date.new(2026, 1, 15), notes_before: "<p>Dolor <strong>lumbar</strong></p>")

      get patient_history_path(patient)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana", "López", "Dolor <strong>lumbar</strong>", "Durante 2026-03-01", "Enviar 2026-03-01")
      expect(response.body.index("15-01-2026")).to be < response.body.index("01-03-2026")
      expect(response.body.index("01-03-2026")).to be < response.body.index("Today's consultation")
    end

    it "loads older pages lazily into nested frames as the user scrolls up" do
      per_page = Patients::HistoriesController::PER_PAGE
      oldest = Date.new(2025, 1, 1)
      (per_page + 1).times { |i| consult(oldest + i.days) }

      get patient_history_path(patient)

      page_two = patient_history_path(patient, page: 2)
      expect(response.body).to include(%(<turbo-frame loading="lazy" id="history_page_2" src="#{page_two}">))
      expect(response.body).not_to include("Antes 2025-01-01")

      get page_two, headers: { "Turbo-Frame" => "history_page_2" }

      expect(response.body).to match(/<turbo-frame id="history_page_2">/).and include("Antes 2025-01-01")
      expect(response.body).not_to include("Antes 2025-01-02", "history_page_3")
    end

    it "loads the notes without one query per consultation" do
      consult(Date.new(2026, 1, 1))
      one = count_queries { get patient_history_path(patient) }
      consult(Date.new(2026, 1, 2))
      consult(Date.new(2026, 1, 3))

      expect(count_queries { get patient_history_path(patient) }).to eq(one)
    end
  end

  describe "editing a consultation in place" do
    let!(:consultation) { consult(Date.new(2026, 2, 1)) }

    it "replaces the consultation's frame with its form" do
      get edit_patient_history_entry_path(patient, consultation), headers: { "Turbo-Frame" => "consultation_#{consultation.id}" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/<turbo-frame id="consultation_#{consultation.id}">/)
      expect(response.body).to include(%(action="#{patient_history_entry_path(patient, consultation)}"), "Antes 2026-02-01")
    end

    it "saves the notes and shows the consultation again" do
      patch patient_history_entry_path(patient, consultation), params: { consultation: { notes_after: "Mejora" } }

      expect(response).to redirect_to(patient_history_entry_path(patient, consultation))
      expect(consultation.reload.notes_after.to_plain_text).to eq("Mejora")
      expect(consultation.notes_before.to_plain_text).to eq("Antes 2026-02-01")

      get response.location, headers: { "Turbo-Frame" => "consultation_#{consultation.id}" }
      expect(response.body).to match(/<turbo-frame id="consultation_#{consultation.id}">/).and include("Mejora")
    end

    it "only finds consultations of the patient in the URL" do
      other = Patient.create!(first_name: "Carmen", last_name: "Ruiz")

      get edit_patient_history_entry_path(other, consultation)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "today's consultation" do
    let(:params) { { consultation: { notes_before: "Antes", notes_after: "Durante", notes_to_send: "Enviar" } } }

    it "is an empty form below the history until it is saved" do
      get patient_history_path(patient)

      expect(response.body).to include(%(action="#{patient_today_consultation_path(patient)}"), "Today's consultation")
      expect(response.body).not_to include("/download")
    end

    it "is created on the first save, then updated, and the form stays open with the PDF" do
      expect { patch patient_today_consultation_path(patient), params: params }.to change { patient.consultations.count }.by(1)
      expect { patch patient_today_consultation_path(patient), params: { consultation: { notes_to_send: "Ejercicios" } } }
        .not_to change { patient.consultations.count }

      expect(response).to redirect_to(patient_today_consultation_path(patient))
      today = patient.consultations.last
      expect(today.date).to eq(Date.current)
      expect(today.notes_before.to_plain_text).to eq("Antes")
      expect(today.notes_to_send.to_plain_text).to eq("Ejercicios")

      get response.location, headers: { "Turbo-Frame" => "today_consultation" }
      expect(response.body).to match(/<turbo-frame id="today_consultation">/)
      expect(response.body).to include("Saved", "Ejercicios", download_consultation_path(today))
    end

    it "is left out of the list above the form" do
      consult(Date.current, notes_before: "Hoy")

      get patient_history_path(patient)

      expect(response.body.scan("Hoy").size).to eq(1)
      expect(response.body).not_to include(edit_patient_history_entry_path(patient, patient.consultations.last))
    end
  end
end
