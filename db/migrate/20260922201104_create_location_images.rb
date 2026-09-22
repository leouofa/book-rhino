class CreateLocationImages < ActiveRecord::Migration[8.0]
  def change
    create_table :location_images do |t|
      t.references :location, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
