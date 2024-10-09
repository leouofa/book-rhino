class AddNarrativeStructureToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :narrative_structure, foreign_key: true
  end
end
