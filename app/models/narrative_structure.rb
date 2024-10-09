# == Schema Information
#
# Table name: narrative_structures
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  parts       :text             default([]), is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class NarrativeStructure < ApplicationRecord
  serialize :parts, coder: YAML
  validates :name, presence: true, uniqueness: true
end
