class VehicleApiService
  def initialize(api_key = Rails.application.credentials.vehicle_api_key)
    @api_key = api_key
    @base_url = "https://api.vehicle-data.com/v1" # URL fictive, à remplacer par l'URL réelle de l'API
  end

  def get_vehicle_by_registration(registration)
    response = HTTParty.get(
      "#{@base_url}/vehicles/registration/#{registration}",
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      }
    )

    if response.success?
      parse_vehicle_data(response.parsed_response)
    else
      nil
    end
  end

  def get_vehicle_by_vin(vin)
    response = HTTParty.get(
      "#{@base_url}/vehicles/vin/#{vin}",
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      }
    )

    if response.success?
      parse_vehicle_data(response.parsed_response)
    else
      nil
    end
  end

  private

  def parse_vehicle_data(data)
    {
      make: data['make'],
      model: data['model'],
      year: data['year'],
      registration: data['registration'],
      vin: data['vin'],
      color: data['color'],
      fuel_type: data['fuel_type'],
      transmission: data['transmission'],
      engine_size: data['engine_size'],
      doors: data['doors'],
      seats: data['seats'],
      first_registration_date: data['first_registration_date']
    }
  end
end 