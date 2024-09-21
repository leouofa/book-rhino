class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.text :title
      t.references :writing_style, null: false, foreign_key: true

      t.timestamps
    end
  end
end
