class CreateChapters < ActiveRecord::Migration[7.2]
  def change
    create_table :chapters do |t|
      t.integer :number, null: false
      t.text :summary, null: false
      t.text :content, null: false
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :chapters, [:book_id, :number], unique: true
  end
end
