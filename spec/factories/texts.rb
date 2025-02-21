FactoryBot.define do
  factory :text do
    name { Faker::Book.title }
    corpus { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    association :writing_style
  end
end
