class Character::VersionsController < MetaVersionController
  private

  def parent_class
    Character
  end

  def merge_job
    MergeCharacterPromptsJob
  end

  def redirect_path
    character_path(@parent)
  end
end
