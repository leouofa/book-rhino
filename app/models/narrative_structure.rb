# == Schema Information
#
# Table name: narrative_structures
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  parts       :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class NarrativeStructure < ApplicationRecord
  serialize :parts, coder: YAML
  has_many :books, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
