class CreateCharacters < ActiveRecord::Migration[7.2]
  def change
    create_table :characters do |t|
      t.string :name
      t.string :gender
      t.integer :age
      t.string :ethnicity
      t.string :nationality
      t.text :appearance
      t.text :health
      t.text :fears
      t.text :desires
      t.text :backstory
      t.text :skills
      t.text :values

      t.timestamps
    end
  end
end
