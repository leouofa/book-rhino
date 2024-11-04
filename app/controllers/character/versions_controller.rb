class Character::VersionsController < MetaVersionController
  private

  def parent_class
    Character
  end

  def merge_job
    MergeCharacterPromptsJob
  end

  def parent_path
    "character_path"
  end
end
