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
#  chapter_count          :integer
#  pages                  :integer
#  narrative_structure_id :bigint
#  protagonist_id         :bigint
#  rendering             :boolean          default(false), not null
#
class Book < ApplicationRecord
  belongs_to :writing_style
  belongs_to :perspective
  belongs_to :narrative_structure
  belongs_to :protagonist, class_name: 'Character', optional: true

  has_many :book_antagonists, dependent: :destroy
  has_many :antagonists, through: :book_antagonists, source: :character
  has_and_belongs_to_many :characters
  has_and_belongs_to_many :locations
  has_many :chapters, dependent: :destroy

  validates :title, presence: true
  validate :character_role_uniqueness

  has_paper_trail ignore: %i[title moral chapter_count pages rendering], versions: {
    scope: -> { order('id desc') }
  }

  def as_json(options = {})
    super(options.merge(
      except: [:id, :created_at, :updated_at],
      include: {
        writing_style: { only: [:name, :prompt] },
        perspective: { only: [:name, :narrator, :pronouns, :effect] },
        narrative_structure: { only: [:name, :description, :parts] },
        protagonist: { only: [:name, :prompt] },
        antagonists: { only: [:name, :prompt] },
        characters: { only: [:name, :prompt] },
        locations: { only: [:name, :prompt] }
      }
    ))
  end

  private

  def character_role_uniqueness
    return unless changes_to_character_roles?

    validate_protagonist_roles if protagonist
    validate_antagonist_roles
  end

  def changes_to_character_roles?
    protagonist_id_changed? ||
      association(:book_antagonists).loaded? ||
      association(:characters).loaded? ||
      antagonist_changes? ||
      characters.any?(&:new_record?)
  end

  def antagonist_changes?
    book_antagonists.any? { |ba| ba.changed? || ba.new_record? }
  end

  def validate_protagonist_roles
    if antagonists.to_a.any? { |a| a.id == protagonist.id }
      errors.add(:protagonist_id, "can't be both protagonist and antagonist")
    end

    return unless characters.to_a.any? { |c| c.id == protagonist.id }

    errors.add(:protagonist_id, "can't be both protagonist and regular character")
  end

  def validate_antagonist_roles
    antagonist_ids = antagonists.map(&:id)
    return unless characters.to_a.any? { |c| antagonist_ids.include?(c.id) }

    errors.add(:antagonists, "can't be both antagonists and regular characters")
  end
end
