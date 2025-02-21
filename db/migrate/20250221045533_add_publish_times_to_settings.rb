class AddPublishTimesToSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :settings, :publish_start_time, :datetime
    add_column :settings, :publish_end_time, :datetime
  end
end
