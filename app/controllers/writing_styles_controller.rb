class WritingStylesController < ApplicationController
  include RestrictedAccess

  before_action :set_meta
  before_action :set_component, only: [:edit, :update, :destroy]
  def index
    scope = set_scope
    @component_list = @component_klass.send(scope).order(created_at: :desc).page params[:page]
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

  def destroy

    if @component.destroy
      redirect_to writing_styles_path, notice: 'Writing style was successfully deleted.'
    else
      redirect_to writing_styles_path, alert: 'Failed to delete writing style.'
    end
  end

  def edit
  end

  def update
    if @component.update(component_params)
      redirect_to writing_styles_path, notice: 'Writing style was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_meta
    @component_klass = 'WritingStyle'.constantize
    @component_name = 'Writing Style'
    @component_list_path = 'writing_styles_path'
    @component_path = 'writing_style_path'
    @component_new_path = 'new_writing_style_path'
  end

  def set_component
    @component = @component_klass.find(params[:id])
  end

  def component_params
    params.require(:writing_style).permit(:name)
  end

  def set_scope
    'all'
  end
end
