require 'rails_helper'

# Users are created with `bin/rails users:create`; public sign up must stay disabled.
RSpec.describe "Public registration", type: :routing do
  it "is not routable" do
    expect(get: "/registrations/new").not_to be_routable
    expect(post: "/registrations").not_to be_routable
  end
end
