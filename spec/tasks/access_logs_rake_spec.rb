require "rails_helper"
require "rake"

RSpec.describe "access_logs:purge" do
  before(:all) { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  it "deletes expired rows and reports how many" do
    AccessLog.create!(action: "login", created_at: 4.years.ago)
    AccessLog.create!(action: "login")

    expect { Rake::Task["access_logs:purge"].execute }
      .to output(/Deleted 1 access-log rows/).to_stdout
      .and change(AccessLog, :count).by(-1)
  end
end
