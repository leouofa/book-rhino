class Location::VersionsController < MetaVersionController
  private

  def parent_class
    Location
  end

  def merge_job
    MergeLocationPromptsJob
  end

  def parent_path
    "character_path"
  end
end
