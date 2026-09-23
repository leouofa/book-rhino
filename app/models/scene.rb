class Scene < ApplicationRecord
  belongs_to :chapter
  
  validates :number, presence: true, uniqueness: { scope: :chapter_id }

  def can_render?
    true
  end
end
