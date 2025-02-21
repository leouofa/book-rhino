# == Schema Information
#
# Table name: book_antagonists
#
#  id           :bigint           not null, primary key
#  book_id      :bigint           not null
#  character_id :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class BookAntagonist < ApplicationRecord
  belongs_to :book
  belongs_to :character

  validates :book_id, uniqueness: { scope: :character_id }
end
