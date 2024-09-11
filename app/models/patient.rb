# == Schema Information
#
# Table name: patients
#
#  id         :bigint           not null, primary key
#  first_name :string
#  last_name  :string
#  birth_date :string
#  phone      :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Patient < ApplicationRecord
  has_many :consultations, dependent: :destroy

  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false

end
