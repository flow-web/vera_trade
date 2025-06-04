class Vehicle < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :users, through: :listings
  
  validates :make, :model, :year, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :kilometers, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Validations pour les nouveaux champs
  validates :license_plate, format: { with: /\A[A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2}\z/, message: "doit être au format AA-123-AA" }, allow_nil: true
  validates :vin, format: { with: /\A[A-HJ-NPR-Z0-9]{17}\z/, message: "doit contenir exactement 17 caractères alphanumériques" }, allow_nil: true
  validates :fiscal_power, numericality: { greater_than: 0 }, allow_nil: true
  validates :average_consumption, numericality: { greater_than: 0 }, allow_nil: true
  validates :co2_emissions, numericality: { greater_than: 0 }, allow_nil: true
  
  # Validations d'unicité
  validates :license_plate, uniqueness: true, allow_nil: true
  validates :vin, uniqueness: true, allow_nil: true
  
  # Validations pour les coordonnées GPS
  validates :latitude, numericality: { in: -90..90 }, allow_nil: true
  validates :longitude, numericality: { in: -180..180 }, allow_nil: true
  
  # Callbacks
  before_validation :normalize_license_plate
  before_validation :normalize_vin
  before_save :geocode_address, if: :should_geocode?
  
  # Scopes géographiques
  scope :near, ->(latitude, longitude, radius_km = 50) {
    where(
      "ST_DWithin(
        ST_Point(vehicles.longitude, vehicles.latitude)::geography,
        ST_Point(?, ?)::geography,
        ?
      )",
      longitude, latitude, radius_km * 1000
    )
  }
  
  scope :within_bounds, ->(north, south, east, west) {
    where(
      latitude: south..north,
      longitude: west..east
    )
  }
  
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
  
  # Méthodes géographiques
  def geocoded?
    latitude.present? && longitude.present?
  end
  
  def full_address
    [address, location].compact.join(', ')
  end
  
  def distance_to(other_lat, other_lng)
    return nil unless geocoded?
    
    calculate_distance(latitude, longitude, other_lat, other_lng)
  end
  
  def coordinates
    return nil unless geocoded?
    [longitude, latitude]
  end
  
  # Géocode une adresse donnée
  def self.geocode_address(address_string)
    return nil if address_string.blank?
    
    # Utilise l'API Mapbox pour le géocodage
    begin
      require 'net/http'
      require 'json'
      
      mapbox_token = Rails.application.credentials.mapbox&.access_token || ENV['MAPBOX_ACCESS_TOKEN']
      return nil if mapbox_token.blank?
      
      encoded_address = URI.encode_www_form_component(address_string)
      url = "https://api.mapbox.com/geocoding/v5/mapbox.places/#{encoded_address}.json?access_token=#{mapbox_token}&country=fr&language=fr"
      
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        if data['features'].any?
          coordinates = data['features'].first['center']
          place_name = data['features'].first['place_name']
          
          return {
            longitude: coordinates[0],
            latitude: coordinates[1],
            address: place_name
          }
        end
      end
    rescue => e
      Rails.logger.error "Erreur de géocodage: #{e.message}"
    end
    
    nil
  end
  
  private
  
  def normalize_license_plate
    return if license_plate.blank?
    self.license_plate = license_plate.upcase.gsub(/[^A-Z0-9]/, '')
  end
  
  def normalize_vin
    return if vin.blank?
    self.vin = vin.upcase
  end
  
  def should_geocode?
    # Géocode si l'adresse ou la localisation a changé et qu'on n'a pas encore de coordonnées
    (address_changed? || location_changed?) && !geocoded?
  end
  
  def geocode_address
    address_to_geocode = full_address
    return if address_to_geocode.blank?
    
    result = self.class.geocode_address(address_to_geocode)
    
    if result
      self.latitude = result[:latitude]
      self.longitude = result[:longitude]
      self.address = result[:address] if address.blank?
    end
  end
  
  def calculate_distance(lat1, lng1, lat2, lng2)
    rad_per_deg = Math::PI / 180  # PI / 180
    rkm = 6371                    # Earth radius in kilometers
    rm = rkm * 1000               # Radius in meters

    dlat_rad = (lat2 - lat1) * rad_per_deg  # Delta, converted to rad
    dlng_rad = (lng2 - lng1) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlng_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rkm * c # Distance in kilometers
  end
end
