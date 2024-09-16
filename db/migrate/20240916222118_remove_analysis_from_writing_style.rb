class RemoveAnalysisFromWritingStyle < ActiveRecord::Migration[7.2]
  def change
    remove_column :writing_styles, :analysis
  end
end
