class WritingStylesController < ApplicationController
  def index
    scope = set_scope
    @writing_styles = WritingStyle.send(scope).order(id: :desc).page params[:page]
    @total_writing_styles = WritingStyle.send(scope).count
  end

  private

  def set_scope
    'all'
  end
end
