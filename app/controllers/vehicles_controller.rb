class VehiclesController < ApplicationController
  def categories
    @categories = Category.main_categories.order(:name)
    render json: @categories
  end

  def subcategories
    @category = Category.find(params[:category_id])
    @subcategories = @category.subcategories.order(:name)
    render json: @subcategories
  end
  
  def vehicle_types
    render json: Vehicle.vehicle_types
  end
  
  def specific_fields
    @category = params[:category]
    if @category.present? && Vehicle.specific_fields.key?(@category.to_sym)
      render json: { fields: Vehicle.specific_fields[@category.to_sym] }
    else
      render json: { fields: [] }
    end
  end
  
  def equipment_categories
    render json: Vehicle.equipment_categories
  end
end
