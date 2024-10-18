class Character::VersionsController < ApplicationController
  before_action :set_character
  before_action :set_version, only: %i[revert merge]

  def index
    @versions_with_prompt_changes = @character.versions.map do |version|
      changes = parse_object_changes(version)
      found = changes.any? { |property, (old_value, _new_value)| property == 'prompt' && old_value }

      next unless found

      {
        id: version.id,
        updated_at: changes['updated_at']&.last,
        old_prompt: changes['prompt']&.first
      }
    end.compact
  end

  def revert
    version_to_revert = @version.reify
    version_to_revert.pending = false
    version_to_revert.save

    redirect_to character_path(@character), notice: "Version reverted successfully."
  end

  def merge
    version_to_merge = @version.reify
    MergeCharacterPromptsJob.perform_later(@character, version_to_merge)

    redirect_to character_path(@character)
  end

  private

  def set_character
    @character = Character.find_by!(id: params[:character_id])
  end

  def set_version
    @version = @character.versions.find_by!(id: params[:id])
  end

  def parse_object_changes(version)
    permitted_classes = [Time, Date, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    YAML.safe_load(version.object_changes, permitted_classes:, aliases: true)
  end
end
