class VehiclesController < ApplicationController
  before_action :authenticate_user!

  FETCH_RATE_LIMIT = 10 # max requests per minute per user

  def fetch_info
    if rate_limited?
      return render json: { error: "Trop de requêtes, réessayez dans une minute" }, status: :too_many_requests
    end

    service = VehicleInfoService.new
    unless service.configured?
      return render json: { error: "Service de recherche véhicule non configuré" }, status: :service_unavailable
    end

    vehicle_info = if params[:license_plate].present?
      service.fetch_by_license_plate(params[:license_plate])
    elsif params[:vin].present?
      service.fetch_by_vin(params[:vin])
    end

    if vehicle_info
      render json: vehicle_info
    else
      render json: { error: "Impossible de trouver les informations du véhicule" }, status: :not_found
    end
  end

  private

  def rate_limited?
    key = "vehicle_fetch:#{current_user.id}"
    count = Rails.cache.read(key).to_i
    if count >= FETCH_RATE_LIMIT
      true
    else
      Rails.cache.write(key, count + 1, expires_in: 1.minute)
      false
    end
  end
end
