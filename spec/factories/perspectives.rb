FactoryBot.define do
  factory :perspective do
    name { ['First Person', 'Third Person Limited', 'Third Person Omniscient'].sample }
    narrator { Faker::Lorem.paragraph }
    effect { Faker::Lorem.paragraph }
    pronouns { ['I/me/my', 'he/him/his', 'she/her/hers', 'they/them/their'].sample }
    example { Faker::Lorem.paragraph }
  end
end
