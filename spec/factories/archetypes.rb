FactoryBot.define do
  factory :archetype do
    name { ['Hero', 'Mentor', 'Threshold Guardian', 'Herald', 'Shapeshifter', 'Shadow', 'Trickster'].sample }
    traits { Faker::Lorem.sentences(number: 3).join("\n") }
    examples { Faker::Lorem.sentences(number: 2).join("\n") }
  end
end
