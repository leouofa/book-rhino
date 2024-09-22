class CreateArchetypes < ActiveRecord::Migration[7.2]
  def change
    create_table :archetypes do |t|
      t.string :name
      t.text :traits
      t.text :examples

      t.timestamps
    end
  end
end
