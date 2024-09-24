class CreateMoralAlignments < ActiveRecord::Migration[7.2]
  def change
    create_table :moral_alignments do |t|
      t.string :name, null: false
      t.text :description
      t.text :examples

      t.timestamps
    end
    add_index :moral_alignments, :name, unique: true  # Ensure unique alignment names
  end
end
