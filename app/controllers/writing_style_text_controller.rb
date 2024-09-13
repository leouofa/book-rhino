class WritingStyleTextController < ApplicationController
  before_action :set_component
  def index
    scope = set_scope
    @component_list = @component_klass.where(writing_style: params[:id]).send(scope).order(created_at: :desc).page params[:page]
    @component_count = @component_klass.where(writing_style: params[:id]).send(scope).count
  end

  private

  def set_component
    @component_klass = 'WritingStyleText'.constantize
    @component_name = 'Writing Style Text'
    @component_list_path = 'writing_styles_path'
    @component_path = 'writing_style_path'
    @component_new_path = 'new_writing_style_path'
  end

  def component_params
    params.require(:writing_style).permit(:name)
  end

  def set_scope
    'all'
  end
end
