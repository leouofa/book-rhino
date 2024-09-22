# == Schema Information
#
# Table name: books
#
#  id               :bigint           not null, primary key
#  title            :text
#  writing_style_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  perspective_id   :bigint
#  moral            :text
#
class Book < ApplicationRecord
  belongs_to :writing_style
  belongs_to :perspective

  validates :title, presence: true
end
