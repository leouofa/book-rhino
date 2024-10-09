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
#
class Book < ApplicationRecord
  belongs_to :writing_style
  belongs_to :perspective
  belongs_to :narrative_structure

  validates :title, presence: true
end
