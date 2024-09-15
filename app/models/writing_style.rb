# == Schema Information
#
# Table name: writing_styles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  prompt     :text
#  analysis   :text
#
class WritingStyle < ApplicationRecord
  has_many :texts, dependent: :destroy
  validates :name, presence: true
end
