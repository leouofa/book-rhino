class CreateCharacterMoralAlignmentsJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :characters, :moral_alignments do |t|
      t.index [:character_id, :moral_alignment_id]
      t.index [:moral_alignment_id, :character_id]
    end
  end
end
