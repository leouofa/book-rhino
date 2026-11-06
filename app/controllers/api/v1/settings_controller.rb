# frozen_string_literal: true

module Api
  module V1
    class SettingsController < BaseController
      before_action :require_admin!, only: [:update]

      def show
        settings = Setting.instance
        render_data(Api::V1::SettingSerializer.render(settings))
      end

      def update
        settings = Setting.instance
        permitted = extract_params(
          :setting,
          :character_image_prompt,
          :character_pose_prompt,
          :scene_background_prompt,
          :location_background_prompt,
          :publish_start_time,
          :publish_end_time,
          tunings: {},
          prompts: {}
        )

        settings.update!(permitted)
        render_data(Api::V1::SettingSerializer.render(settings))
      end
    end
  end
end
