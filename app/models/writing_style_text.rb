# == Schema Information
#
# Table name: writing_style_texts
#
#  id               :bigint           not null, primary key
#  corpus           :text
#  writing_style_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class WritingStyleText < ApplicationRecord
  belongs_to :writing_style
end
