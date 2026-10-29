# The patient history lists a patient's consultations by date.
class IndexConsultationsOnPatientIdAndDate < ActiveRecord::Migration[8.1]
  def change
    add_index :consultations, [ :patient_id, :date ]
    remove_index :consultations, :patient_id
  end
end
