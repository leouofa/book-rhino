# == Schema Information
#
# Table name: regions
#
#  id          :bigint           not null, primary key
#  name        :string
#  city        :string
#  country     :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Region < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :city, presence: true
  validates :country, presence: true
  validates :description, presence: true
end
