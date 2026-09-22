class CharacterImage < ApplicationRecord
  belongs_to :character
  has_one_attached :image

  validates :title, presence: true
end
