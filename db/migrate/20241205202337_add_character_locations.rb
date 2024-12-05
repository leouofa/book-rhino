class AddCharacterLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :characters_locations do |t|
      t.belongs_to :character
      t.belongs_to :location
      t.timestamps
    end
    end
end
