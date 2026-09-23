class AddRenderingToScenes < ActiveRecord::Migration[8.0]
  def change
    add_column :scenes, :rendering, :boolean, default: false, null: false
  end
end
