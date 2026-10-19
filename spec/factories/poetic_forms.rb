FactoryBot.define do
  factory :poetic_form do
    sequence(:name) { |n| "Poetic Form #{n}" }
    description { Faker::Lorem.paragraph }
    meter { 'Dactylic hexameter' }
    rhyme_scheme { 'Unrhymed' }
    guidelines { Faker::Lorem.paragraph }
    example { Faker::Lorem.paragraph }
  end
end
