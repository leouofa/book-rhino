class AddPendingToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :pending, :boolean
  end
end
