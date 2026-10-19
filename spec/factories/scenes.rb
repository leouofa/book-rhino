FactoryBot.define do
  factory :scene do
    association :chapter
    sequence(:number) { |n| n }
    outline { Faker::Lorem.paragraph }
  end
end
