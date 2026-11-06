# frozen_string_literal: true

module Api
  module V1
    class SettingSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          prompts: record.prompts,
          tunings: record.tunings,
          publish_start_time: format_time(record.publish_start_time),
          publish_end_time: format_time(record.publish_end_time),
          character_image_prompt: record.character_image_prompt,
          character_pose_prompt: record.character_pose_prompt,
          scene_background_prompt: record.scene_background_prompt,
          location_background_prompt: record.location_background_prompt,
          within_publish_window: record.within_publish_window?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
