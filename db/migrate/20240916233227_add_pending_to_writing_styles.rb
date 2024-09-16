class AddPendingToWritingStyles < ActiveRecord::Migration[7.2]
  def change
    add_column :writing_styles, :pending, :boolean, default: false
  end
end
