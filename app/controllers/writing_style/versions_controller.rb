class WritingStyle::VersionsController < ApplicationController
  def index
    @writing_style = WritingStyle.find_by!(id: params[:writing_style_id])
    @versions = @writing_style.versions
  end
end
