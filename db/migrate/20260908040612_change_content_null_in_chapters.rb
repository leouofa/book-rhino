class ChangeContentNullInChapters < ActiveRecord::Migration[8.0]
  def change
    change_column_null :chapters, :content, true
  end
end
