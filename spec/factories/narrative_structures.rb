FactoryBot.define do
  factory :narrative_structure do
    name { ['Linear', 'Non-linear', 'Frame Story', 'Parallel Narratives'].sample }
    description { Faker::Lorem.paragraph }
  end
end
