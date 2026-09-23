class RenamePlotSummaryToOutlineOnChapters < ActiveRecord::Migration[8.0]
  def change
    rename_column :chapters, :plot_summary, :outline
  end
end
