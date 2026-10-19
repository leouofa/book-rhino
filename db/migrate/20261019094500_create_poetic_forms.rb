class CreatePoeticForms < ActiveRecord::Migration[7.2]
  def change
    create_table :poetic_forms do |t|
      t.string :name, null: false
      t.text :description
      t.text :meter
      t.text :rhyme_scheme
      t.text :guidelines
      t.text :example

      t.timestamps
    end

    add_index :poetic_forms, :name, unique: true
  end
end
