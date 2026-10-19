# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  first_name      :string
#  last_name       :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new(email: "user@example.com", password: "a-long-password") }

  it { is_expected.to validate_presence_of(:email) }

  it "requires passwords of at least 12 characters" do
    expect(User.new(email: "short@example.com", password: "elevenchars")).not_to be_valid
    expect(User.new(email: "long@example.com", password: "twelve-chars")).to be_valid
  end

  it "rejects duplicated emails regardless of case and spaces" do
    subject.save!

    duplicate = User.new(email: " USER@example.com ", password: "another-long-password")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end
end
