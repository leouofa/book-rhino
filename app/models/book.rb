# == Schema Information
#
# Table name: books
#
#  id               :bigint           not null, primary key
#  title            :text
#  writing_style_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Book < ApplicationRecord
  belongs_to :writing_style

  validates :title, presence: true
end
