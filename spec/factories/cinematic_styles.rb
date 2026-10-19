FactoryBot.define do
  factory :cinematic_style do
    sequence(:name) { |n| "Cinematic Style #{n}" }
    description { Faker::Lorem.paragraph }
    aesthetic_tags { "film noir, black and white, high contrast, dramatic shadows, monochrome" }
    lighting { "chiaroscuro, high contrast, moody" }
    example { Faker::Lorem.paragraph }
  end
end
