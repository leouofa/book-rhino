# == Schema Information
#
# Table name: locations
#
#  id              :bigint           not null, primary key
#  name            :string
#  lighting        :text
#  time            :text
#  noise_level     :text
#  comfort         :text
#  aesthetics      :text
#  accessibility   :text
#  personalization :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  region_id       :bigint
#  description     :text
#
class Location < ApplicationRecord
  belongs_to :region, optional: true
  has_and_belongs_to_many :characters

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
