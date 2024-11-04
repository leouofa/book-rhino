class MetaController < ApplicationController
  include RestrictedAccess

  before_action :set_meta
  before_action :set_component, only: [:show, :edit, :edit_prompt, :update, :destroy, :iterate]
  before_action :set_parent, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :set_message, only: [:iterate]

  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :desc).page params[:page]
  end

  def new
    @component = @component_klass.new
  end

  def edit; end

  def show; end

  def edit_prompt; end

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
      if component_params[:prompt]
        redirect_to send(@component_detail_path, @component.id), notice: "#{@component_name} was successfully updated."
      else
        redirect_to send(@component_list_path), notice: "#{@component_name} was successfully updated."
      end
    else
      render component_params[:prompt] ? :edit_prompt : :edit
    end
  end

  def iterate
      iterate_job.perform_later(@component, @message)

      respond_to do |format|
        format.turbo_stream
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

  def iterate_job
    raise NotImplementedError, "#{self.class} must implement iterate_job"
  end

  def component_path
    @computer_name
  end

  def set_meta
    @component_name = component_name
    @component_klass = component_class
    @computer_name = @component_klass.name.underscore
    @component_list_path = "#{prefix}#{component_path.pluralize}_path"
    @component_detail_path = "#{prefix}#{component_path}_path"
    @component_path = "#{prefix}#{component_path}_path"
    @component_new_path = "new_#{prefix}#{component_path}_path"
    @component_edit_path = "edit_#{prefix}#{component_path}_path"
    @component_delete_path = "#{prefix}#{component_path}_path"
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

  def set_parent; end

  def set_message
    @message = params[:message]
  end
end
