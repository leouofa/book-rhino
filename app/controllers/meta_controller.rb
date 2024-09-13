class MetaController < ApplicationController
  include RestrictedAccess

  before_action :set_meta
  before_action :set_component, only: [:edit, :update, :destroy]

  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :desc).page params[:page]
  end

  def new
    @component = @component_klass.new
  end

  def create
    @component = @component_klass.new(component_params)
    if @component.save
      redirect_to send(@component_list_path), notice: "#{@component_name} was successfully created."
    else
      render :new
    end
  end

  def destroy
    if @component.destroy
      redirect_to send(@component_list_path), notice: "#{@component_name} was successfully deleted."
    else
      redirect_to send(@component_list_path), alert: "Failed to delete #{@component_name}."
    end
  end

  def update
    if @component.update(component_params)
      redirect_to send(@component_list_path), notice: "#{@component_name} was successfully updated."
    else
      render :edit
    end
  end

  private

  def component_name
    raise NotImplementedError
  end

  def component_class
    raise NotImplementedError
  end

  def component_params
    raise NotImplementedError
  end

  def set_meta
    @component_name = component_name
    @component_klass = component_class
    @computer_name = @component_klass.name.underscore
    @component_list_path = "#{prefix}#{@computer_name.pluralize}_path"
    @component_path = "#{prefix}#{@computer_name}_path"
    @component_new_path = "new_#{prefix}#{@computer_name}_path"
    @component_edit_path = "edit_#{prefix}#{@computer_name}_path"
  end

  def set_component
    @component = @component_klass.find(params[:id])
  end

  def set_scope
    'all'
  end

  def prefix
    ''
  end

  def set_where
    ''
  end
end
