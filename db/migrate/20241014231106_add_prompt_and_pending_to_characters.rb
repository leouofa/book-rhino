class AddPromptAndPendingToCharacters < ActiveRecord::Migration[7.2]
  def change
    add_column :characters, :prompt, :text
    add_column :characters, :pending, :boolean
  end
end
