class SearchPresetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_preset, only: [ :show, :edit, :update, :destroy ]

  def index
    @presets = current_user.search_presets.order(created_at: :desc).limit(50)
  end

  def create
    @preset = current_user.search_presets.build(preset_params)

    if @preset.save
      render json: {
        success: true,
        preset: {
          id: @preset.id,
          name: @preset.name,
          filters: @preset.filters
        }
      }
    else
      render json: {
        success: false,
        errors: @preset.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @preset.update(preset_params)
      render json: {
        success: true,
        preset: {
          id: @preset.id,
          name: @preset.name,
          filters: @preset.filters
        }
      }
    else
      render json: {
        success: false,
        errors: @preset.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @preset.destroy
    render json: { success: true }
  end

  def toggle_notification
  end

  private

  def set_preset
    @preset = current_user.search_presets.find(params[:id])
  end

  def preset_params
    params.require(:search_preset).permit(:name, filters: {})
  end
end
