# == Schema Information
#
# Table name: chapters
#
#  id           :bigint           not null, primary key
#  number       :integer          not null
#  summary      :text             not null
#  content      :text
#  book_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string
#  outline      :text
#

## Functionality
## For chapter generation workflow, see: docs/chapter_generation_flow.md

class Chapter < ApplicationRecord
  belongs_to :book
  has_many :scenes, dependent: :destroy

  scope :rendered, -> { where.not(content: nil) }
  scope :unrendered, -> { where(content: nil) }

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true
  validates :outline, presence: true
  validates :number, uniqueness: { scope: :book_id, message: "should be unique within the book" }
  validates :scene_count, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

  def previous_chapter
    book.chapters.where("number < ?", number).order(number: :desc).first
  end

  def can_render?
    return true if previous_chapter.nil?

    previous_chapter.content.present?
  end
end
