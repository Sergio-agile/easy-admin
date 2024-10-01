# spec/models/patient_spec.rb
require 'rails_helper'

RSpec.describe Patient, type: :model do

  let(:patient) { build(:patient) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(patient).to be_valid
    end

    it 'is not valid without a first_name' do
      patient.first_name = nil
      expect(patient).not_to be_valid
      expect(patient.errors[:first_name]).to include("can't be blank")
    end

    it 'is not valid without a last_name' do
      patient.last_name = nil
      expect(patient).not_to be_valid
      expect(patient.errors[:last_name]).to include("can't be blank")
    end

    it 'is not valid with a blank first_name' do
      patient.first_name = ''
      expect(patient).not_to be_valid
      expect(patient.errors[:first_name]).to include("can't be blank")
    end

    it 'is not valid with a blank last_name' do
      patient.last_name = ''
      expect(patient).not_to be_valid
      expect(patient.errors[:last_name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { should have_many(:consultations).dependent(:destroy) }
  end
end
