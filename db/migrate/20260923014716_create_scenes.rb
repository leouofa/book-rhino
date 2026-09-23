class CreateScenes < ActiveRecord::Migration[8.0]
  def change
    create_table :scenes do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :number
      t.text :outline
      t.text :content
      t.text :summary

      t.timestamps
    end
  end
end
