# == Schema Information
#
# Table name: cinematic_styles
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  description    :text
#  aesthetic_tags :text             not null
#  lighting       :text
#  example        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class CinematicStyle < ApplicationRecord
  has_many :books, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :aesthetic_tags, presence: true
end
