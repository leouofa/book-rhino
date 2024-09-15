class AddAnalysisToWritingStyles < ActiveRecord::Migration[7.2]
  def change
    add_column :writing_styles, :analysis, :text
  end
end
