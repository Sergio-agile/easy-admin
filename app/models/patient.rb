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

  # Matches first or last name, ranking first name prefixes, then last name prefixes, then the rest.
  def self.search(term)
    return all if term.blank?

    term = sanitize_sql_like(term.to_s.strip)
    first_name, last_name = arel_table[:first_name], arel_table[:last_name]
    rank = Arel::Nodes::Case.new
      .when(first_name.matches("#{term}%")).then(0)
      .when(last_name.matches("#{term}%")).then(1)
      .else(2)

    where(first_name.matches("%#{term}%").or(last_name.matches("%#{term}%")))
      .order(rank, first_name, last_name)
  end
end
