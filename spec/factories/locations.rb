FactoryBot.define do
  factory :location do
    name { "The #{Faker::Address.unique.community} #{Faker::Lorem.word}" }
    description { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
    lighting { Faker::Lorem.paragraph }
    time { %w[Morning Afternoon Evening Night].sample }
    noise_level { ["Silent", "Quiet", "Moderate", "Loud", "Very Loud"].sample }
    comfort { ["Very Comfortable", "Comfortable", "Moderate", "Uncomfortable", "Very Uncomfortable"].sample }
    aesthetics { Faker::Lorem.paragraph }
    accessibility { ["Easily Accessible", "Moderately Accessible", "Difficult to Access", "Restricted Access"].sample }
    personalization { Faker::Lorem.paragraph }
    pending { false }

    association :region

    trait :with_characters do
      after(:create) do |location|
        location.characters << create_list(:character, 2)
      end
    end
  end
end
