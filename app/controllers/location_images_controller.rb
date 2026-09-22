class LocationImagesController < ApplicationController
  include RestrictedAccess

  before_action :set_location
  before_action :set_location_image, only: %i[update destroy]

  def create
    uploaded_files = Array(params[:images] || params[:image] || params.dig(:location_image, :images) || params.dig(:location_image, :image)).compact_blank
    @created_images = []

    uploaded_files.each do |file|
      title = params[:title].presence || File.basename(file.original_filename, '.*').humanize.titleize
      location_image = @location.location_images.build(title: title)
      location_image.image.attach(file)
      if location_image.save
        @created_images << location_image
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { status: :ok, images: @created_images.map { |img| { id: img.id, title: img.title } } } }
      format.html { redirect_to location_path(@location), notice: 'Images uploaded successfully.' }
    end
  end

  def update
    if @location_image.update(location_image_params)
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { status: :ok, id: @location_image.id, title: @location_image.title } }
        format.html { redirect_to location_path(@location), notice: 'Image title updated.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.json { render json: { errors: @location_image.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to location_path(@location), alert: 'Failed to update image title.' }
      end
    end
  end

  def destroy
    @location_image.destroy
    respond_to do |format|
      format.turbo_stream
      format.json { render json: { status: :ok, id: @location_image.id } }
      format.html { redirect_to location_path(@location), notice: 'Image removed.' }
    end
  end

  private

  def set_location
    @location = Location.find(params[:location_id])
  end

  def set_location_image
    @location_image = @location.location_images.find(params[:id])
  end

  def location_image_params
    if params[:location_image].present?
      params.require(:location_image).permit(:title)
    else
      params.permit(:title)
    end
  end
end
