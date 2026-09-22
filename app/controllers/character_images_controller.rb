class CharacterImagesController < ApplicationController
  include RestrictedAccess

  before_action :set_character
  before_action :set_character_image, only: %i[update destroy]

  def create
    uploaded_files = Array(params[:images] || params[:image] || params.dig(:character_image, :images) || params.dig(:character_image, :image)).compact_blank
    @created_images = []

    uploaded_files.each do |file|
      title = params[:title].presence || File.basename(file.original_filename, '.*').humanize.titleize
      character_image = @character.character_images.build(title: title)
      character_image.image.attach(file)
      if character_image.save
        @created_images << character_image
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { status: :ok, images: @created_images.map { |img| { id: img.id, title: img.title } } } }
      format.html { redirect_to character_path(@character), notice: 'Images uploaded successfully.' }
    end
  end

  def update
    if @character_image.update(character_image_params)
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { status: :ok, id: @character_image.id, title: @character_image.title } }
        format.html { redirect_to character_path(@character), notice: 'Image title updated.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.json { render json: { errors: @character_image.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to character_path(@character), alert: 'Failed to update image title.' }
      end
    end
  end

  def destroy
    @character_image.destroy
    respond_to do |format|
      format.turbo_stream
      format.json { render json: { status: :ok, id: @character_image.id } }
      format.html { redirect_to character_path(@character), notice: 'Image removed.' }
    end
  end

  private

  def set_character
    @character = Character.find(params[:character_id])
  end

  def set_character_image
    @character_image = @character.character_images.find(params[:id])
  end

  def character_image_params
    if params[:character_image].present?
      params.require(:character_image).permit(:title)
    else
      params.permit(:title)
    end
  end
end
