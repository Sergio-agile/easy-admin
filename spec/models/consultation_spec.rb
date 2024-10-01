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
end
