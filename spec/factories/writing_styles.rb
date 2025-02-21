FactoryBot.define do
  factory :writing_style do
    name { Faker::Lorem.word }
    prompt { { style: Faker::Lorem.paragraph }.to_json }
    pending { false }
  end
end
