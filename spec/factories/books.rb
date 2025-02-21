FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    moral { Faker::Lorem.paragraph }
    plot { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    chapters { rand(5..50) }
    pages { rand(100..1000) }

    association :writing_style
    association :perspective
    association :narrative_structure

    trait :with_protagonist do
      association :protagonist, factory: :character
    end

    trait :with_antagonists do
      transient do
        antagonists_count { 2 }
      end

      after(:create) do |book, evaluator|
        evaluator.antagonists_count.times do
          book.antagonists << create(:character)
        end
      end
    end

    trait :with_characters do
      transient do
        characters_count { 3 }
      end

      after(:create) do |book, evaluator|
        book.characters << create_list(:character, evaluator.characters_count)
      end
    end

    trait :complete do
      association :protagonist, factory: :character

      after(:create) do |book|
        book.antagonists = create_list(:character, 2)
        book.characters = create_list(:character, 3)
      end
    end
  end
end
