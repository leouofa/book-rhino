class CreateCharacterCharacterTypesJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :characters, :character_types do |t|
      t.index [:character_id, :character_type_id]
      t.index [:character_type_id, :character_id]
    end
  end
end
