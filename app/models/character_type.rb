# == Schema Information
#
# Table name: character_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  definition :text
#  purpose    :text
#  example    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CharacterType < ApplicationRecord
  has_and_belongs_to_many :characters

  validates :name, presence: true
  validates :definition, :purpose, :example, presence: true
end
