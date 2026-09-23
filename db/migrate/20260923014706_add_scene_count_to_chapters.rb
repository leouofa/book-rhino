class AddSceneCountToChapters < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters, :scene_count, :integer
  end
end
