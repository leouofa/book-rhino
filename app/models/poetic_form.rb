# == Schema Information
#
# Table name: poetic_forms
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  description  :text
#  meter        :text
#  rhyme_scheme :text
#  guidelines   :text
#  example      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class PoeticForm < ApplicationRecord
  has_many :books, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
