class CreateJoinTableBooksLocations < ActiveRecord::Migration[8.0]
  def change
    create_join_table :books, :locations do |t|
      # t.index [:book_id, :location_id]
      # t.index [:location_id, :book_id]
    end
  end
end
