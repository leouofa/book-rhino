class AddPerspectiveToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :perspective, foreign_key: true
  end
end
