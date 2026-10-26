require 'rails_helper'

RSpec.describe "Patients", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /patients" do
    it "lists the patients" do
      ana = create(:patient, first_name: "Ana", last_name: "López")

      get patients_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana", "López", patient_path(ana))
    end

    it "filters by first or last name, case insensitive" do
      create(:patient, first_name: "Ana", last_name: "López")
      create(:patient, first_name: "Berta", last_name: "Anaya")
      create(:patient, first_name: "Carmen", last_name: "Ruiz")

      get patients_path, params: { term: "ana" }

      expect(response.body).to include("López", "Anaya")
      expect(response.body).not_to include("Carmen")
    end

    it "treats LIKE wildcards in the search term literally" do
      create(:patient, first_name: "Ana")

      get patients_path, params: { term: "%" }

      expect(response.body).not_to include("Ana")
    end

    it "submits the search form to the patients list" do
      get patients_path

      expect(response.body).to include(%(action="#{patients_path}"))
    end

    it "paginates the results" do
      per_page = Patient.default_per_page
      Patient.insert_all(Array.new(per_page + 1) { |i|
        { first_name: "Patient#{i}", last_name: "Test", created_at: i.minutes.ago, updated_at: Time.current }
      })

      get patients_path

      last = "<td data-label=\"First Name\">Patient#{per_page}</td>"
      expect(response.body).to include("Patient0")
      expect(response.body).not_to include(last)

      get patients_path, params: { page: 2 }
      expect(response.body).to include(last)
    end

    it "keeps the search term in the pagination links" do
      create_list(:patient, Patient.default_per_page + 1, first_name: "Ana")

      get patients_path, params: { term: "ana" }

      expect(response.body).to include(%(href="#{ERB::Util.h(patients_path(page: 2, term: "ana"))}"))
    end

    it "answers turbo frame requests for the search box without the layout" do
      create(:patient, first_name: "Ana")

      get patients_path, params: { term: "ana" }, headers: { "Turbo-Frame" => "patients" }

      expect(response.body).to match(/<turbo-frame [^>]*id="patients"/).and include("Ana")
      expect(response.body).not_to include("side-menu")
    end
  end

  describe "GET /patients/:id" do
    it "shows the patient and their consultations" do
      patient = create(:patient, first_name: "Ana", phone: "600111222")

      get patient_path(patient)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana", "600111222")
      patient.consultations.each do |consultation|
        expect(response.body).to include(edit_patient_consultation_path(patient, consultation))
      end
    end

    it "returns 404 for an unknown patient" do
      get patient_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /patients/new" do
    it "shows the form" do
      get new_patient_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /patients" do
    let(:params) do
      { patient: { first_name: "Ana", last_name: "López", birth_date: "1990-05-01", phone: "600111222", address: "Calle Mayor 1" } }
    end

    it "creates the patient and shows it" do
      expect { post patients_path, params: params }.to change(Patient, :count).by(1)

      patient = Patient.last
      expect(response).to redirect_to(patient_path(patient))
      expect(patient).to have_attributes(params[:patient])
    end

    it "re-renders the form when invalid" do
      params[:patient][:first_name] = ""

      expect { post patients_path, params: params }.not_to change(Patient, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "editing in place" do
    let(:patient) { create(:patient, first_name: "Ana") }

    it "shows the edit form" do
      get edit_patient_path(patient), as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('target="patient-details"', 'id="edit-patient"')
    end

    it "updates the patient" do
      patch patient_path(patient), params: { patient: { first_name: "Anabel" } }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(patient.reload.first_name).to eq("Anabel")
      expect(response.body).to include('target="edit-patient"', "Anabel")
    end

    it "keeps the form open when invalid" do
      patch patient_path(patient), params: { patient: { first_name: "" } }, as: :turbo_stream

      expect(patient.reload.first_name).to eq("Ana")
      expect(response.body).to include('id="edit-patient"')
    end

    it "cancels the edit" do
      get cancel_edit_patient_path(patient), as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana")
      expect(response.body).not_to include('id="edit-patient"')
    end
  end
end
