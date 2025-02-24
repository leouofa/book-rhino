class AddRenderingToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :rendering, :boolean, default: false, null: false
  end
end
