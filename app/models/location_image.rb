class LocationImage < ApplicationRecord
  belongs_to :location
  has_one_attached :image

  validates :title, presence: true
end
