require "rails_helper"

RSpec.describe "Admin access log", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:ana) { create(:patient, first_name: "Ana", last_name: "López") }
  let(:berta) { create(:patient, first_name: "Berta", last_name: "Ruiz") }

  def log(action, user: admin, patient: nil, at: Time.current)
    travel_to(at) { AccessLog.record(action, user:, ip_address: "203.0.113.7", patient:) }
  end

  it "is only for admins" do
    sign_in create(:user)

    get admin_access_logs_path

    expect(response).to redirect_to(home_path)
  end

  it "requires login" do
    get admin_access_logs_path

    expect(response).to redirect_to(root_path)
  end

  context "as an admin" do
    before { sign_in admin }

    it "is linked from the side menu" do
      get home_path

      expect(response.body).to include(admin_access_logs_path)
    end

    it "lists who did what to which patient, newest first" do
      log(:patient_viewed, patient: ana, at: 2.days.ago)
      log(:consultation_updated, patient: berta, at: 1.day.ago)

      get admin_access_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin.email, "203.0.113.7", patient_path(ana))
      rows = response.body[%r{<tbody>.*</tbody>}m]
      expect(rows.index("Consultation updated")).to be < rows.index("Patient viewed")
    end

    it "filters by patient name, user, action and date range" do
      other = create(:user)
      log(:patient_viewed, patient: ana, at: 10.days.ago)
      log(:patient_updated, patient: ana, at: 1.day.ago)
      log(:patient_viewed, patient: berta, user: other, at: 1.day.ago)

      get admin_access_logs_path, params: { patient: "ana", event: "patient_viewed" }
      expect(response.body).to include("Ana López").and include("Patient viewed")
      expect(response.body).not_to include("Berta Ruiz")
      expect(response.body).not_to include("Patient updated</td>")

      get admin_access_logs_path, params: { user_id: other.id }
      expect(response.body).to include("Berta Ruiz")
      expect(response.body).not_to include("Ana López")

      get admin_access_logs_path, params: { from: 2.days.ago.to_date.to_s, to: Date.current.to_s, patient: "ana" }
      expect(response.body).to include("Patient updated</td>")
      expect(response.body).not_to include("Patient viewed</td>")
    end

    it "shows nothing for an invalid date instead of failing" do
      log(:patient_viewed, patient: ana)

      get admin_access_logs_path, params: { from: "not-a-date" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No entries match these filters.")
    end

    it "logs that the access log was viewed" do
      expect { get admin_access_logs_path }.to change { AccessLog.where(action: "access_log_viewed", user: admin).count }.by(1)
    end

    it "loads users and patients without one query per row" do
      3.times { log(:patient_viewed, patient: create(:patient)) }
      queries = count_queries { get admin_access_logs_path }
      3.times { log(:patient_viewed, patient: create(:patient)) }

      expect(count_queries { get admin_access_logs_path }).to eq(queries)
    end
  end
end
