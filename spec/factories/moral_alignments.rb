FactoryBot.define do
  factory :moral_alignment do
    name do
      ['Lawful Good', 'Neutral Good', 'Chaotic Good', 'Lawful Neutral', 'True Neutral', 'Chaotic Neutral', 'Lawful Evil',
       'Neutral Evil', 'Chaotic Evil'].sample
    end
    description { Faker::Lorem.paragraph }
    examples { Faker::Lorem.sentences(number: 3).join("\n") }
  end
end
