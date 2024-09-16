class AddNameToTexts < ActiveRecord::Migration[7.2]
  def change
    add_column :texts, :name, :string
  end
end
