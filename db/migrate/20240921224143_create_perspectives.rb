class CreatePerspectives < ActiveRecord::Migration[7.2]
  def change
    create_table :perspectives do |t|
      t.string :name
      t.text :narrator
      t.text :pronouns
      t.text :effect
      t.text :example

      t.timestamps
    end
  end
end
