require "rails_helper"

RSpec.describe "Importmap" do
  it "resolves every pinned package to an asset" do
    Rails.application.importmap.packages.each_value do |package|
      expect(Rails.application.assets.find_asset(package.path)).to be_present, "#{package.name} -> #{package.path}"
    end
  end

  it "serves Trix from the action_text-trix gem, not from node_modules" do
    trix = Rails.application.assets.find_asset("trix.js")

    expect(trix.filename).to include("/action_text-trix-")
  end
end
