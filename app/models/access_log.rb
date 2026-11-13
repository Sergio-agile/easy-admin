# Who saw or changed which patient, and when. Required to account for access to
# health data (RGPD art. 5.2 and 32). Rows are append-only: they can be created
# but not edited or destroyed through the model. Stores no health data itself.
# == Schema Information
#
# Table name: access_logs
#
#  id              :bigint           not null, primary key
#  action          :string           not null
#  ip_address      :string
#  created_at      :datetime         not null
#  consultation_id :bigint
#  patient_id      :bigint
#  user_id         :bigint
#
# Indexes
#
#  index_access_logs_on_created_at                 (created_at)
#  index_access_logs_on_patient_id_and_created_at  (patient_id,created_at)
#  index_access_logs_on_user_id_and_created_at     (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AccessLog < ApplicationRecord
  ACTIONS = %w[
    login login_failed logout
    patient_viewed patient_created patient_updated history_viewed
    consultation_viewed consultation_created consultation_updated report_downloaded
  ].freeze

  belongs_to :user, optional: true
  belongs_to :patient, optional: true
  belongs_to :consultation, optional: true

  validates :action, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc, id: :desc) }

  def self.record(action, user:, ip_address:, patient: nil, consultation: nil)
    create!(action: action.to_s, user:, ip_address:, consultation:, patient: patient || consultation&.patient)
  end

  def readonly?
    persisted?
  end
end
