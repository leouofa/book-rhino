class AddRegionToLocations < ActiveRecord::Migration[7.2]
  def change
    add_reference :locations, :region, null: true, foreign_key: true
  end
end
