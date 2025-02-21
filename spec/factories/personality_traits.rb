FactoryBot.define do
  factory :personality_trait do
    name { %w[Ambitious Introverted Loyal Creative Analytical Empathetic].sample }
    description { Faker::Lorem.paragraph }
  end
end
