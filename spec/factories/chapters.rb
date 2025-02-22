FactoryBot.define do
  factory :chapter do
    number { rand(1..100) }
    summary { Faker::Lorem.paragraph }
    content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    association :book

    trait :sequential do
      sequence(:number) { |n| n }
    end
  end
end
