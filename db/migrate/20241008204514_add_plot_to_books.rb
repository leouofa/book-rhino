class AddPlotToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :plot, :text
    add_column :books, :chapters, :integer
    add_column :books, :pages, :integer
  end
end
