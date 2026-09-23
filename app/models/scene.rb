class Scene < ApplicationRecord
  belongs_to :chapter
  
  validates :number, presence: true, uniqueness: { scope: :chapter_id }
end
