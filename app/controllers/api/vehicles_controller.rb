module Api
  class VehiclesController < ApplicationController
    def lookup
      service = VehicleApiService.new
      
      if params[:registration].present?
        vehicle_data = service.get_vehicle_by_registration(params[:registration])
      elsif params[:vin].present?
        vehicle_data = service.get_vehicle_by_vin(params[:vin])
      else
        return render json: { error: "Registration or VIN required" }, status: :bad_request
      end

      if vehicle_data
        render json: vehicle_data
      else
        render json: { error: "Vehicle not found" }, status: :not_found
      end
    end
  end
end 