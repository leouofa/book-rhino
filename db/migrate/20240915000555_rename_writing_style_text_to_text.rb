class RenameWritingStyleTextToText < ActiveRecord::Migration[7.2]
  def change
    rename_table :writing_style_texts, :texts
  end
end
