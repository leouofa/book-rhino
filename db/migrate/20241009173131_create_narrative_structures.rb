class CreateNarrativeStructures < ActiveRecord::Migration[7.2]
  def change
    create_table :narrative_structures do |t|
      t.string :name, null: false
      t.text :description
      t.text :parts

      t.timestamps
    end

    add_index :narrative_structures, :name, unique: true
  end
end
