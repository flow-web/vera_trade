require "cgi"

class VehicleInfoService
  TIMEOUT = 10

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
    plate = license_plate.to_s.strip.upcase.gsub(/[^A-Z0-9\-]/, "")
    return nil unless plate.match?(/\A[A-Z0-9\-]{5,10}\z/)

    uri = URI("#{@api_base_url}/vehicle/plate/#{CGI.escape(plate)}")
    parse_response(make_request(uri))
  end

  def fetch_by_vin(vin)
    return nil unless @configured
    return nil if vin.blank?
    clean_vin = vin.to_s.strip.upcase.gsub(/[^A-Z0-9]/, "")
    return nil unless clean_vin.match?(/\A[A-Z0-9]{17}\z/)

    uri = URI("#{@api_base_url}/vehicle/vin/#{CGI.escape(clean_vin)}")
    parse_response(make_request(uri))
  end

  private

  def make_request(uri)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Accept"] = "application/json"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https",
                    open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      response = http.request(request)
      return response.body if response.is_a?(Net::HTTPSuccess)
    end
    nil
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("Vehicle API timeout: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Vehicle API request failed: #{e.message}")
    nil
  end

  def parse_response(body)
    return nil if body.nil?

    data = JSON.parse(body)
    {
      make: data["make"],
      model: data["model"],
      year: data["year"],
      fuel_type: data["fuel_type"],
      transmission: data["transmission"],
      fiscal_power: data["fiscal_power"],
      average_consumption: data["average_consumption"],
      co2_emissions: data["co2_emissions"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse vehicle API response: #{e.message}")
    nil
  end
end
