FactoryBot.define do
  factory :perspective do
    sequence(:name) { |n| "#{['First Person', 'Third Person Limited', 'Third Person Omniscient'].sample} #{n}" }
    narrator { Faker::Lorem.paragraph }
    effect { Faker::Lorem.paragraph }
    pronouns { ['I/me/my', 'he/him/his', 'she/her/hers', 'they/them/their'].sample }
    example { Faker::Lorem.paragraph }
  end
end
