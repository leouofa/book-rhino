class AddProtagonistToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :protagonist, null: true, foreign_key: { to_table: :characters }
  end
end
