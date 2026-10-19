class AddPoeticFormToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :poetic_form, foreign_key: true
  end
end
