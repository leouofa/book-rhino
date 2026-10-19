class CreateCinematicStyles < ActiveRecord::Migration[7.2]
  def change
    create_table :cinematic_styles do |t|
      t.string :name, null: false
      t.text :description
      t.text :aesthetic_tags, null: false
      t.text :lighting
      t.text :example

      t.timestamps
    end

    add_index :cinematic_styles, :name, unique: true
  end
end
