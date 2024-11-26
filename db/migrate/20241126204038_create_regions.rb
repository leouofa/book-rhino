class CreateRegions < ActiveRecord::Migration[7.2]
  def change
    create_table :regions do |t|
      t.string :name
      t.string :city
      t.string :country
      t.text :description

      t.timestamps
    end
  end
end
