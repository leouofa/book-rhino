# == Schema Information
#
# Table name: characters
#
#  id          :bigint           not null, primary key
#  name        :string
#  gender      :string
#  age         :integer
#  ethnicity   :string
#  nationality :string
#  appearance  :text
#  health      :text
#  fears       :text
#  desires     :text
#  backstory   :text
#  skills      :text
#  values      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  prompt      :text
#  pending     :boolean
#
class Character < ApplicationRecord
  has_and_belongs_to_many :character_types
  has_and_belongs_to_many :moral_alignments
  has_and_belongs_to_many :personality_traits
  has_and_belongs_to_many :archetypes
  has_and_belongs_to_many :locations

  validates :name, presence: true
  validates :age, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  has_paper_trail ignore: %i[name gender age ethnicity nationality appearance
                             health fears desires backstory skills values], versions: {
                               scope: -> { order('id desc') }
                             }

  def as_json(options = {})
    super(options.merge(
      except: [:id, :prompt, :pending, :created_at, :updated_at],
      include: {
        character_types: { only: [:name, :definition, :purpose, :example] },
        moral_alignments: { only: [:name, :description, :examples] },
        personality_traits: { only: [:name, :description] },
        archetypes: { only: [:name, :traits, :examples] }
      }
    ))
  end
end
