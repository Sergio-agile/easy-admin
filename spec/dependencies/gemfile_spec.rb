require "rails_helper"

RSpec.describe "Gemfile" do
  # Gems only needed by development/test gems are not installed in production,
  # which then silently falls back to the version bundled with Ruby.
  it "installs json in production instead of Ruby's default gem" do
    json = Bundler.definition.dependencies.find { |dependency| dependency.name == "json" }

    expect(json&.groups).to include(:default)
  end
end
