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
#
class Location < ApplicationRecord
end
