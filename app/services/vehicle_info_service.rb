class VehicleInfoService
  require 'net/http'
  require 'json'
  
  def initialize
    @api_key = Rails.application.credentials.dig(:vehicle_api, :key) || ENV["VEHICLE_API_KEY"]
    @api_base_url = Rails.application.credentials.dig(:vehicle_api, :base_url) || ENV["VEHICLE_API_BASE_URL"]
    @configured = @api_key.present? && @api_base_url.present?
  end

  def configured?
    @configured
  end

  def fetch_by_license_plate(license_plate)
    return nil unless @configured
    return nil if license_plate.blank?

    uri = URI("#{@api_base_url}/vehicle/plate/#{license_plate}")
    response = make_request(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    parse_response(response.body)
  end

  def fetch_by_vin(vin)
    return nil unless @configured
    return nil if vin.blank?

    uri = URI("#{@api_base_url}/vehicle/vin/#{vin}")
    response = make_request(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    parse_response(response.body)
  end
  
  private
  
  def make_request(uri)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@api_key}"
    request['Accept'] = 'application/json'
    
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  rescue StandardError => e
    Rails.logger.error("Vehicle API request failed: #{e.message}")
    nil
  end
  
  def parse_response(body)
    data = JSON.parse(body)
    
    {
      make: data['make'],
      model: data['model'],
      year: data['year'],
      fuel_type: data['fuel_type'],
      transmission: data['transmission'],
      fiscal_power: data['fiscal_power'],
      average_consumption: data['average_consumption'],
      co2_emissions: data['co2_emissions']
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse vehicle API response: #{e.message}")
    nil
  end
end 