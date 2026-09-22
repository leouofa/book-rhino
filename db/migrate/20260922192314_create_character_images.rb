class CreateCharacterImages < ActiveRecord::Migration[8.0]
  def change
    create_table :character_images do |t|
      t.references :character, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
