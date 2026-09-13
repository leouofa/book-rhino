class AddRenderingToChapters < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters, :rendering, :boolean, default: false, null: false
  end
end
