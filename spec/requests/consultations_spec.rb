require 'rails_helper'

RSpec.describe "Consultations", type: :request do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, first_name: "Ana", last_name: "López") }
  let(:consultation) { patient.consultations.first }

  before { sign_in user }

  describe "GET /consultations" do
    it "lists the consultations" do
      consultation

      get consultations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("López", edit_patient_consultation_path(patient, consultation))
    end

    it "filters by patient name" do
      consultation
      create(:patient, first_name: "Carmen", last_name: "Ruiz")

      get consultations_path, params: { term: "lóp" }

      expect(response.body).to include("López")
      expect(response.body).not_to include("Carmen")
    end

    it "answers turbo stream requests for the search box" do
      consultation

      get consultations_path, params: { term: "ana" }, as: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include("López")
    end
  end

  describe "GET /patients/:patient_id/consultations/new" do
    it "shows the form for the patient" do
      get new_patient_consultation_path(patient)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana López")
    end
  end

  describe "POST /patients/:patient_id/consultations" do
    it "creates the consultation with today's date and rich text notes" do
      params = { consultation: { notes_before: "<p>Dolor <strong>lumbar</strong></p>", notes_after: "Mejora", notes_to_send: "Ejercicios" } }

      expect { post patient_consultations_path(patient), params: params }.to change { patient.consultations.count }.by(1)

      expect(response).to redirect_to(patient_path(patient))
      created = patient.consultations.order(:id).last
      expect(created.date).to eq(Date.current)
      expect(created.notes_before.body.to_html).to include("<strong>lumbar</strong>")
      expect(created.notes_to_send.to_plain_text).to eq("Ejercicios")
    end

    it "strips dangerous HTML when the notes are rendered" do
      params = { consultation: { notes_to_send: %(<p>ok</p><script>alert(1)</script><img src=x onerror="alert(1)">) } }

      post patient_consultations_path(patient), params: params

      get download_consultation_path(patient.consultations.order(:id).last)
      expect(response.body).to include("<p>ok</p>")
      expect(response.body).not_to include("<script>alert(1)", "onerror=")
    end
  end

  describe "GET /patients/:patient_id/consultations/:id/edit" do
    it "shows the consultation" do
      get edit_patient_consultation_path(patient, consultation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(consultation.notes_before.to_plain_text)
    end
  end

  describe "PATCH /patients/:patient_id/consultations/:id" do
    it "updates the notes" do
      patch patient_consultation_path(patient, consultation), params: { consultation: { notes_after: "Nueva nota" } }

      expect(response).to redirect_to(patient_path(patient))
      expect(consultation.reload.notes_after.to_plain_text).to eq("Nueva nota")
    end
  end

  describe "GET /consultations/:id/download" do
    before { consultation.update!(notes_to_send: "Hacer estiramientos") }

    it "previews the report as HTML" do
      get download_consultation_path(consultation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hacer estiramientos", "Ana", consultation.date.strftime("%d-%m-%Y"))
      expect(response.body).to include(download_consultation_path(consultation, format: :pdf))
    end

    it "downloads the report as a PDF" do
      get download_consultation_path(consultation, format: :pdf)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment", "report.pdf")
      expect(response.body).to start_with("%PDF")
    end
  end
end
