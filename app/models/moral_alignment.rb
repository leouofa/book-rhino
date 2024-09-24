# == Schema Information
#
# Table name: moral_alignments
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  examples    :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class MoralAlignment < ApplicationRecord
  serialize :examples, coder: YAML

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  paginates_per 100
end
