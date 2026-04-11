class CarBrandsController < ApplicationController
  def search
    brands = CarBrandsService.search(params[:query])
    render json: brands
  end
end
