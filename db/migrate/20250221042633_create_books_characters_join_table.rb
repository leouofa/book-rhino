class CreateBooksCharactersJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :books, :characters do |t|
      t.index [:book_id, :character_id]
      t.index [:character_id, :book_id]
    end
  end
end
