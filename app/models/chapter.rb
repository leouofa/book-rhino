# == Schema Information
#
# Table name: chapters
#
#  id         :bigint           not null, primary key
#  number     :integer          not null
#  summary    :text            not null
#  content    :text            not null
#  book_id    :bigint          not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
class Chapter < ApplicationRecord
  belongs_to :book

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :summary, presence: true
  validates :content, presence: true
  validates :number, uniqueness: { scope: :book_id, message: "should be unique within the book" }
end
