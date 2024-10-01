FactoryBot.define do
  factory :consultation do
    date          { Faker::Date.backward(days: 14) }
    notes_before  { Faker::Lorem.paragraph }
    notes_after   { Faker::Lorem.paragraph }
    notes_to_send { Faker::Lorem.paragraph }
    association   :patient
  end
end
