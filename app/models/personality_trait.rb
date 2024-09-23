# == Schema Information
#
# Table name: personality_traits
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PersonalityTrait < ApplicationRecord
  paginates_per 100
end
