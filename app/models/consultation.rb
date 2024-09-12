# == Schema Information
#
# Table name: consultations
#
#  id            :bigint           not null, primary key
#  date          :date
#  notes_after   :text
#  notes_before  :text
#  notes_to_send :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  patient_id    :bigint           not null
#
# Indexes
#
#  index_consultations_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
class Consultation < ApplicationRecord
  belongs_to :patient
  has_rich_text :notes_before
  has_rich_text :notes_after
  has_rich_text :notes_to_send
end
