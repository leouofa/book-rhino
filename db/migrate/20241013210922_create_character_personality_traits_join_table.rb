class CreateCharacterPersonalityTraitsJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :characters, :personality_traits do |t|
      t.index [:character_id, :personality_trait_id]
      t.index [:personality_trait_id, :character_id]
    end
  end
end
