class CreateWritingStyleTexts < ActiveRecord::Migration[7.2]
  def change
    create_table :writing_style_texts do |t|
      t.text :corpus
      t.references :writing_style, null: false, foreign_key: true

      t.timestamps
    end
  end
end
