# == Schema Information
#
# Table name: patients
#
#  id         :bigint           not null, primary key
#  address    :string
#  birth_date :string
#  first_name :string
#  last_name  :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
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

  describe '.search' do
    let!(:ana) { Patient.create!(first_name: "Ana", last_name: "López") }
    let!(:berta) { Patient.create!(first_name: "Berta", last_name: "Anaya") }
    let!(:underscore) { Patient.create!(first_name: "Car_men", last_name: "Ruiz") }

    it 'matches first or last name, case insensitive' do
      expect(Patient.search("ANA")).to contain_exactly(ana, berta)
    end

    it 'ignores surrounding whitespace' do
      expect(Patient.search(" lópez ")).to contain_exactly(ana)
    end

    it 'treats LIKE wildcards literally' do
      expect(Patient.search("_")).to contain_exactly(underscore)
      expect(Patient.search("%")).to be_empty
    end

    it 'ranks first name prefixes, then last name prefixes, then other matches, alphabetically within each' do
      maybell = Patient.create!(first_name: "Maybell", last_name: "Ruiz")
      belen = Patient.create!(first_name: "Belén", last_name: "Sanz")
      robles = Patient.create!(first_name: "Carmen", last_name: "Belmonte")
      belva = Patient.create!(first_name: "Belva", last_name: "Ortiz")

      expect(Patient.search("bel")).to eq([ belen, belva, robles, maybell ])
    end

    it 'returns every patient for a blank term' do
      expect(Patient.search(nil)).to contain_exactly(ana, berta, underscore)
      expect(Patient.search(" ")).to contain_exactly(ana, berta, underscore)
    end
  end
end
