# == Schema Information
#
# Table name: texts
#
#  id               :bigint           not null, primary key
#  corpus           :text
#  writing_style_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  name             :string
#
class Text < ApplicationRecord
  belongs_to :writing_style

  validates :name, presence: true
  validates :corpus, presence: true
end
