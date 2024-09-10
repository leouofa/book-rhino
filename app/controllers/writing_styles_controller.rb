class WritingStylesController < ApplicationController
  include RestrictedAccess

  before_action :set_component
  def index
    scope = set_scope
    @component_list = @component_klass.send(scope).order(id: :desc).page params[:page]
    @component_count = @component_klass.send(scope).count
  end

  def new

  end

  private
  def set_component
    @component_klass = 'WritingStyle'.constantize
    @component_name = 'Writing Styles'
    @component_new_path = 'new_writing_style_path'
  end

  def set_scope
    'all'
  end
end
