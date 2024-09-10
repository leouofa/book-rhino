class SettingsController < ApplicationController
  def index
    @settings = Setting.instance
  end

  def edit
    @settings = Setting.instance
  end

  def update
    return unless current_user.admin?

    @settings = Setting.instance

    if @settings.update(settings_params)
      redirect_to settings_path, notice: 'Settings were successfully updated.'
    else
      render :edit
    end
  end

  private

  def settings_params
    params.require(:setting).permit(:prompts, :tunings, :publish_start_time, :publish_end_time)
  end

  def valid_time_format?(time)
    time_format = /\A([01]\d|2[0-3]):([0-5]\d)\z/
    time_format.match?(time)
  end
end
