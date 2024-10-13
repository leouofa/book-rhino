class CreateCharacterArchetypesJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :characters, :archetypes do |t|
      t.index [:character_id, :archetype_id]
      t.index [:archetype_id, :character_id]
    end
  end
end
