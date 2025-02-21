FactoryBot.define do
  factory :region do
    name { Faker::Address.community }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }
    description { Faker::Lorem.paragraphs(number: 2).join("\n\n") }

    trait :with_locations do
      after(:create) do |region|
        create_list(:location, 3, region: region)
      end
    end
  end
end
