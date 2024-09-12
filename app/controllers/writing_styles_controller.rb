class WritingStylesController < ApplicationController
  include RestrictedAccess

  before_action :set_component
  def index
    scope = set_scope
    @component_list = @component_klass.send(scope).order(created_at: :desc).page params[:page]
    @component_count = @component_klass.send(scope).count
  end

  def new
    @component = @component_klass.new
  end

  def create
    @component = @component_klass.new(component_params)
    if @component.save
      redirect_to writing_styles_path, notice: 'Writing style was successfully created.'
    else
      render :new
    end
  end

  private

  def set_component
    @component_klass = 'WritingStyle'.constantize
    @component_name = 'Writing Styles'
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
