class Book::VersionsController < MetaVersionController
  private

  def parent_class
    Book
  end

  def merge_job
    MergeBookPlotsJob
  end

  def parent_path
    "book_path"
  end
end
