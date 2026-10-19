class AddCinematicStyleToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :cinematic_style, foreign_key: true
  end
end
