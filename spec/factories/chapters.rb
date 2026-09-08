FactoryBot.define do
  factory :chapter do
    number { rand(1..100) }
    name { Faker::Book.unique.title }
    summary { Faker::Lorem.paragraph }
    plot_summary { Faker::Lorem.paragraph }
    content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    association :book

    trait :sequential do
      sequence(:number) { |n| n }
    end

    trait :rendered do
      content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    end

    trait :unrendered do
      content { nil }
    end
  end
end
