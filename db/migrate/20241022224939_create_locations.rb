class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :lighting
      t.text :time
      t.text :noise_level
      t.text :comfort
      t.text :aesthetics
      t.text :accessibility
      t.text :personalization

      t.timestamps
    end
  end
end
