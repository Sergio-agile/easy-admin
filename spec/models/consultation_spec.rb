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
#  index_consultations_on_patient_id_and_date  (patient_id,date)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
require 'rails_helper'

RSpec.describe Consultation, type: :model do
  let(:consultation) { build(:consultation) }

  describe 'associations' do
    it { should belong_to(:patient) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(consultation).to be_valid
    end

    it 'is not valid without a patient' do
      consultation.patient = nil
      expect(consultation).not_to be_valid
      expect(consultation.errors[:patient]).to include("must exist")
    end
  end

  describe '.search' do
    it 'matches the patient name' do
      ana = Patient.create!(first_name: "Ana", last_name: "López")
      carmen = Patient.create!(first_name: "Carmen", last_name: "Ruiz")
      consultation = ana.consultations.create!
      carmen.consultations.create!

      expect(Consultation.search("lóp")).to contain_exactly(consultation)
      expect(Consultation.search("")).to contain_exactly(consultation, carmen.consultations.first)
    end

    it 'ranks consultations by how well the patient name matches' do
      maybell = Patient.create!(first_name: "Maybell", last_name: "Ruiz").consultations.create!
      belva = Patient.create!(first_name: "Belva", last_name: "Ortiz").consultations.create!

      expect(Consultation.search("bel")).to eq([ belva, maybell ])
    end
  end

  describe '.history' do
    it 'orders newest first, by date then creation' do
      patient = Patient.create!(first_name: "Ana", last_name: "López")
      old = patient.consultations.create!(date: Date.new(2026, 1, 1))
      first_same_day = patient.consultations.create!(date: Date.new(2026, 2, 1))
      second_same_day = patient.consultations.create!(date: Date.new(2026, 2, 1))

      expect(Consultation.history).to eq([ second_same_day, first_same_day, old ])
    end
  end
end
