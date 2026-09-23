class AllowNullSummaryInChapters < ActiveRecord::Migration[8.0]
  def change
    change_column_null :chapters, :summary, true
  end
end
