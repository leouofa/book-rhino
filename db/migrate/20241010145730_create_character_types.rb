class CreateCharacterTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :character_types do |t|
      t.string :name
      t.text :definition
      t.text :purpose
      t.text :example

      t.timestamps
    end
  end
end
