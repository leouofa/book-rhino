# == Schema Information
#
# Table name: characters
#
#  id          :bigint           not null, primary key
#  name        :string
#  gender      :string
#  age         :integer
#  ethnicity   :string
#  nationality :string
#  appearance  :text
#  health      :text
#  fears       :text
#  desires     :text
#  backstory   :text
#  skills      :text
#  values      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Character < ApplicationRecord
  validates :name, presence: true
  validates :age, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
