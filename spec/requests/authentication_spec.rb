require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:patient) { create(:patient) }
  let(:consultation) { patient.consultations.first }

  # Every page with patient data must require a logged in user.
  {
    "home"                 => -> { [ :get, home_path ] },
    "patients index"       => -> { [ :get, patients_path ] },
    "patient"              => -> { [ :get, patient_path(patient) ] },
    "new patient"          => -> { [ :get, new_patient_path ] },
    "create patient"       => -> { [ :post, patients_path ] },
    "edit patient"         => -> { [ :get, edit_patient_path(patient) ] },
    "update patient"       => -> { [ :patch, patient_path(patient) ] },
    "consultations index"  => -> { [ :get, consultations_path ] },
    "new consultation"     => -> { [ :get, new_patient_consultation_path(patient) ] },
    "create consultation"  => -> { [ :post, patient_consultations_path(patient) ] },
    "edit consultation"    => -> { [ :get, edit_patient_consultation_path(patient, consultation) ] },
    "update consultation"  => -> { [ :patch, patient_consultation_path(patient, consultation) ] },
    "download consultation" => -> { [ :get, download_consultation_path(consultation, format: :pdf) ] },
    "patient history"      => -> { [ :get, patient_history_path(patient) ] },
    "history entry"        => -> { [ :get, patient_history_entry_path(patient, consultation) ] },
    "edit history entry"   => -> { [ :get, edit_patient_history_entry_path(patient, consultation) ] },
    "update history entry" => -> { [ :patch, patient_history_entry_path(patient, consultation) ] },
    "today consultation"   => -> { [ :get, patient_today_consultation_path(patient) ] },
    "save today consultation" => -> { [ :patch, patient_today_consultation_path(patient) ] },
    "edit password"        => -> { [ :get, edit_password_path ] },
    "update password"      => -> { [ :patch, password_path ] }
  }.each do |name, route|
    it "redirects to the login page on #{name}" do
      verb, path = instance_exec(&route)

      public_send(verb, path)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You must be logged in")
    end
  end
end
