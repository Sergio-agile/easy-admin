FactoryBot.define do
  factory :patient do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65).to_s }
    phone      { Faker::PhoneNumber.phone_number }
    address    { Faker::Address.full_address }

    after(:create) do |patient|
      create_list(:consultation, 3, patient: patient)
    end
  end
end
