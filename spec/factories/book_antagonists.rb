FactoryBot.define do
  factory :book_antagonist do
    association :book
    association :character
  end
end
