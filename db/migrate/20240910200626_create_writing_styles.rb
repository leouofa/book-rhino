class CreateWritingStyles < ActiveRecord::Migration[7.2]
  def change
    create_table :writing_styles do |t|
      t.string :name

      t.timestamps
    end
  end
end
