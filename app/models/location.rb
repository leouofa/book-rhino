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
#  prompt          :text
#  pending         :boolean
#
class Location < ApplicationRecord
  belongs_to :region, optional: true
  has_and_belongs_to_many :characters
  has_and_belongs_to_many :books

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  has_paper_trail ignore: %i[name lighting time noise_level comfort aesthetics
                             accessibility personalization description], versions: {
                               scope: -> { order('id desc') }
                             }

  def location_details
    as_json(
      except: [:id, :prompt, :pending],
      include: {
        characters: { only: [:name, :prompt] },
        books: { only: [:title] }
      }
    )
  end
end
