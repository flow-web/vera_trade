class VehiclesController < ApplicationController
  def fetch_info
    service = VehicleInfoService.new
    vehicle_info = nil
    
    if params[:license_plate].present?
      vehicle_info = service.fetch_by_license_plate(params[:license_plate])
    elsif params[:vin].present?
      vehicle_info = service.fetch_by_vin(params[:vin])
    end
    
    if vehicle_info
      render json: vehicle_info
    else
      render json: { error: "Impossible de trouver les informations du véhicule" }, status: :not_found
    end
  end
end
