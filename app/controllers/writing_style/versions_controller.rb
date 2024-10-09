class WritingStyle::VersionsController < ApplicationController
  before_action :set_writing_style
  before_action :set_version, only: %i[revert merge]

  def index
    # @writing_style = WritingStyle.find_by!(id: params[:writing_style_id])
    @versions_with_prompt_changes = @writing_style.versions.map do |version|
      changes = parse_object_changes(version)
      found = changes.any? { |property, (old_value, _new_value)| property == 'prompt' && old_value }

      next unless found

      {
        id: version.id,
        updated_at: changes['updated_at']&.last,
        old_prompt: parse_version_json(changes['prompt']&.first)
      }
    end.compact
  end

  def revert
    # Logic to revert to the specific version
    version_to_revert = @version.reify
    version_to_revert.pending = false
    version_to_revert.save

    redirect_to writing_style_texts_path, notice: "Version reverted successfully."
  end

  def merge
    version_to_merge = @version.reify
    MergeWritingStylesJob.perform_later(@writing_style, version_to_merge)

    redirect_to writing_style_texts_path
  end

  private

  def set_writing_style
    @writing_style = WritingStyle.find_by!(id: params[:writing_style_id])
  end

  def set_version
    @version = @writing_style.versions.find_by!(id: params[:id])
  end

  def parse_object_changes(version)
    permitted_classes = [Time, Date, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    YAML.safe_load(version.object_changes, permitted_classes:, aliases: true)
  end

  def parse_version_json(json)
    JSON.parse(JSON.parse(json))
  end
end
