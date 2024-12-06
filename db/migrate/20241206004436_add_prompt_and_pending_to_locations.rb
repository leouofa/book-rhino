class AddPromptAndPendingToLocations < ActiveRecord::Migration[7.2]
  def change
    add_column :locations, :prompt, :text
    add_column :locations, :pending, :boolean
  end
end
