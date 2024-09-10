class DropStartEnddatesFromSettings < ActiveRecord::Migration[7.2]
  def change
    remove_column :settings, :publish_start_time
    remove_column :settings, :publish_end_time
  end
end
