class ChangeAgeToBigintInCharacters < ActiveRecord::Migration[7.2]
  def change
    change_column :characters, :age, :bigint
  end
end
