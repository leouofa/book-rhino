# == Schema Information
#
# Table name: writing_styles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  prompt     :text
#  pending    :boolean          default(FALSE)
#
class WritingStyle < ApplicationRecord
  serialize :prompt, coder: JSON

  has_many :texts, dependent: :destroy
  has_many :books, dependent: :nullify

  validates :name, presence: true

  validate :prompt_is_valid_json

  has_paper_trail ignore: [:name, :pending], versions: {
    scope: -> { order('id desc') }
  }

  private

  def prompt_is_valid_json
    return if prompt.blank?

    begin
      JSON.parse(prompt.is_a?(String) ? prompt : prompt.to_json)
    rescue JSON::ParserError
      errors.add(:prompt, 'must be a valid JSON object')
    end
  end
end
