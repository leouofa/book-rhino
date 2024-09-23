# == Schema Information
#
# Table name: archetypes
#
#  id         :bigint           not null, primary key
#  name       :string
#  traits     :text
#  examples   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Archetype < ApplicationRecord
  paginates_per 100
end
