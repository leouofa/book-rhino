class AddMoralToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :moral, :text
  end
end
