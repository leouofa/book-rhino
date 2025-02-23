class AddNameAndPlotSummaryToChapters < ActiveRecord::Migration[7.2]
  def change
    add_column :chapters, :name, :string
    add_column :chapters, :plot_summary, :text
  end
end
