class AddDescriptionToLocations < ActiveRecord::Migration[7.2]
  def change
    add_column :locations, :description, :text
  end
end
