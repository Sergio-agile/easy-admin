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
class Patient < ApplicationRecord
  has_many :consultations, dependent: :destroy

  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false

  scope :search, ->(term) {
    if term.present?
      pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"
      where(arel_table[:first_name].matches(pattern).or(arel_table[:last_name].matches(pattern)))
    end
  }
end
