class CreateBookAntagonists < ActiveRecord::Migration[7.2]
  def change
    create_table :book_antagonists do |t|
      t.references :book, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.timestamps
    end

    add_index :book_antagonists, [:book_id, :character_id], unique: true
  end
end
