class RenameChaptersToChapterCountInBooks < ActiveRecord::Migration[7.2]
  def change
    rename_column :books, :chapters, :chapter_count
  end
end
