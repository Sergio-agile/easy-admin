require "rails_helper"

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
RSpec.describe AccessLog, type: :model do
  let(:user) { create(:user) }

  describe ".record" do
    it "takes the patient from the consultation" do
      consultation = create(:consultation)

      log = AccessLog.record(:consultation_viewed, user:, ip_address: "203.0.113.7", consultation:)

      expect(log).to have_attributes(action: "consultation_viewed", user:, ip_address: "203.0.113.7",
                                     consultation:, patient: consultation.patient)
    end

    it "rejects unknown actions" do
      expect { AccessLog.record(:peeked, user:, ip_address: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it "cannot be edited or destroyed once written" do
    log = AccessLog.record(:login, user:, ip_address: nil)

    expect { log.update!(action: "logout") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { log.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  describe ".purge_expired" do
    it "deletes rows older than three years and keeps the rest" do
      now = Time.zone.local(2029, 6, 1, 12)
      old = AccessLog.create!(action: "login", created_at: now - 3.years - 1.second)
      kept = AccessLog.create!(action: "login", created_at: now - 3.years + 1.second)

      expect(AccessLog.purge_expired(now)).to eq(1)
      expect(AccessLog.pluck(:id)).to eq([ kept.id ])
      expect(AccessLog.exists?(old.id)).to be(false)
    end
  end
end
