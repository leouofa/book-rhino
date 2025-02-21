FactoryBot.define do
  factory :character do
    name { Faker::Name.unique.name }
    gender { %w[Male Female Non-binary Other].sample }
    age { rand(1..100) }
    ethnicity { Faker::Demographic.race }
    nationality { Faker::Nation.nationality }
    appearance { Faker::Lorem.paragraph }
    health { Faker::Lorem.paragraph }
    fears { Faker::Lorem.sentences(number: 3).join("\n") }
    desires { Faker::Lorem.sentences(number: 3).join("\n") }
    backstory { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
    skills { Faker::Lorem.sentences(number: 3).join("\n") }
    values { Faker::Lorem.sentences(number: 3).join("\n") }
    pending { false }

    trait :with_associations do
      after(:create) do |character|
        character.character_types << create(:character_type)
        character.moral_alignments << create(:moral_alignment)
        character.personality_traits << create(:personality_trait)
        character.archetypes << create(:archetype)
      end
    end

    trait :as_protagonist do
      after(:create) do |character|
        create(:book, protagonist: character)
      end
    end

    trait :as_antagonist do
      after(:create) do |character|
        create(:book_antagonist, character: character)
      end
    end
  end
end
