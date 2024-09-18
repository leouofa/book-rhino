class WritingStyle::VersionsController < ApplicationController
  def index
    @writing_style = WritingStyle.find_by!(id: params[:writing_style_id])
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

  private

  def parse_object_changes(version)
    permitted_classes = [Time, Date, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    YAML.safe_load(version.object_changes, permitted_classes: permitted_classes, aliases: true)
  end

  def parse_version_json(json)
    JSON.parse(JSON.parse(json))
  end
end
