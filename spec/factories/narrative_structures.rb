FactoryBot.define do
  factory :narrative_structure do
    sequence(:name) { |n| "#{['Linear', 'Non-linear', 'Frame Story', 'Parallel Narratives'].sample} #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
