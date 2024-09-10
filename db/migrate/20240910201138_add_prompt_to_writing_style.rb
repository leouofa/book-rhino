class AddPromptToWritingStyle < ActiveRecord::Migration[7.2]
  def change
    add_column :writing_styles, :prompt, :text
  end
end
