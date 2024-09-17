# == Schema Information
#
# Table name: writing_styles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  prompt     :text
#  pending    :boolean          default(FALSE)
#
class WritingStyle < ApplicationRecord
  serialize :prompt, coder: JSON

  has_many :texts, dependent: :destroy
  validates :name, presence: true

  has_paper_trail ignore: [:name, :pending]
end
