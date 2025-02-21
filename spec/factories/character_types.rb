FactoryBot.define do
  factory :character_type do
    name { ['Protagonist', 'Antagonist', 'Deuteragonist', 'Tertiary Character', 'Foil', 'Mentor'].sample }
    definition { Faker::Lorem.paragraph }
    purpose { Faker::Lorem.paragraph }
    example { Faker::Lorem.paragraph }
  end
end
