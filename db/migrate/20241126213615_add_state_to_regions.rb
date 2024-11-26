class AddStateToRegions < ActiveRecord::Migration[7.2]
  def change
    add_column :regions, :state, :string
  end
end
