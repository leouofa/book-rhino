# == Schema Information
#
# Table name: books
#
#  id                     :bigint           not null, primary key
#  title                  :text
#  writing_style_id       :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  perspective_id         :bigint
#  moral                  :text
#  plot                   :text
#  chapters               :integer
#  pages                  :integer
#  narrative_structure_id :bigint
#  protagonist_id         :bigint
#
class Book < ApplicationRecord
  belongs_to :writing_style
  belongs_to :perspective
  belongs_to :narrative_structure
  belongs_to :protagonist, class_name: 'Character', optional: true

  has_many :book_antagonists
  has_many :antagonists, through: :book_antagonists, source: :character
  has_and_belongs_to_many :characters

  validates :title, presence: true
  validate :character_role_uniqueness

  private

  def character_role_uniqueness
    return unless protagonist_id

    errors.add(:protagonist_id, "can't be both protagonist and antagonist") if antagonists.exists?(id: protagonist_id)

    errors.add(:protagonist_id, "can't be both protagonist and regular character") if characters.exists?(id: protagonist_id)

    antagonist_ids = antagonists.pluck(:id)
    return unless characters.exists?(id: antagonist_ids)

    errors.add(:antagonists, "can't be both antagonists and regular characters")
  end
end
