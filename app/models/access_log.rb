# Who saw or changed which patient, and when. Required to account for access to
# health data (RGPD art. 5.2 and 32). Rows are append-only: they can be created
# but not edited or destroyed through the model. The only deletion is
# purge_expired, which drops rows older than RETENTION (LOPDGDD art. 72: the
# longest limitation period for data-protection infringements is three years).
# Stores no health data itself.
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
    access_log_viewed
  ].freeze

  RETENTION = 3.years

  belongs_to :user, optional: true
  belongs_to :patient, optional: true
  belongs_to :consultation, optional: true

  validates :action, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc, id: :desc) }
  scope :expired, ->(now = Time.current) { where(created_at: ...now - RETENTION) }

  # Filters for the admin page. Blank values are ignored; dates are inclusive.
  def self.filter(user_id: nil, patient: nil, action: nil, from: nil, to: nil)
    logs = all
    logs = logs.where(user_id:) if user_id.present?
    logs = logs.where(patient_id: Patient.search(patient).reorder(nil).select(:id)) if patient.present?
    logs = logs.where(action:) if action.present?
    logs = logs.where(created_at: Date.parse(from).beginning_of_day..) if from.present?
    logs = logs.where(created_at: ..Date.parse(to).end_of_day) if to.present?
    logs
  rescue Date::Error
    none
  end

  def self.record(action, user:, ip_address:, patient: nil, consultation: nil)
    create!(action: action.to_s, user:, ip_address:, consultation:, patient: patient || consultation&.patient)
  end

  # Returns the number of rows deleted. delete_all skips readonly? on purpose.
  def self.purge_expired(now = Time.current)
    expired(now).delete_all
  end

  def readonly?
    persisted?
  end
end
