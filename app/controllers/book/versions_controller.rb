class Book::VersionsController < MetaVersionController
  def index
    @versions_with_prompt_changes = @parent.versions.map do |version|
      changes = parse_object_changes(version)
      found = changes.any? { |property, (old_value, _new_value)| property == 'plot' && old_value }

      next unless found

      {
        id: version.id,
        updated_at: changes['updated_at']&.last,
        old_plot: changes['plot']&.first
      }
    end.compact
  end

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
