# == Schema Information
#
# Table name: perspectives
#
#  id         :bigint           not null, primary key
#  name       :string
#  narrator   :text
#  pronouns   :text
#  effect     :text
#  example    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Perspective < ApplicationRecord
  validates :name, :narrator, :effect, :pronouns, :example, presence: true
end
