class MapController < ApplicationController
  before_action :set_mapbox_token

  def index
    @listings = Listing.includes(:vehicle, :user, photos_attachments: :blob)
                      .joins(:vehicle)
                      .where(status: 'active')
                      .where.not(vehicles: { latitude: nil, longitude: nil })
    
    # Applique les filtres de recherche si présents
    apply_filters if params[:search].present?
    
    # Formate les données pour la carte
    @listings_data = format_listings_for_map(@listings)
    
    # Charge les prestataires de services avec leurs coordonnées
    @service_providers = load_service_providers
    
    # Options de la carte
    @map_options = {
      auto_center: params[:auto_center] != 'false',
      show_route: params[:show_route] == 'true',
      enable_drawing: params[:enable_drawing] == 'true'
    }
    
    respond_to do |format|
      format.html
      format.json { render json: { listings: @listings_data, services: @service_providers } }
    end
  end

  def search
    @listings = Listing.includes(:vehicle, :user, photos_attachments: :blob)
                      .joins(:vehicle)
                      .where(status: 'active')
                      .where.not(vehicles: { latitude: nil, longitude: nil })
    
    apply_filters
    @listings_data = format_listings_for_map(@listings)
    
    render json: { 
      listings: @listings_data,
      count: @listings.count,
      bounds: calculate_bounds(@listings_data)
    }
  end

  def geocode_address
    address = params[:address]
    return render json: { error: 'Adresse requise' }, status: 400 if address.blank?

    begin
      # Utilise un service de géocodage (ici on simule avec l'API Mapbox)
      coordinates = geocode_with_mapbox(address)
      render json: { coordinates: coordinates, address: address }
    rescue => e
      render json: { error: 'Impossible de géocoder cette adresse' }, status: 422
    end
  end

  private

  def set_mapbox_token
    @mapbox_token = 'pk.eyJ1IjoiZmxvdzY5ODMiLCJhIjoiY21iZ2Y2NDZxMm5qcDJscDl5aTdtNmtuMyJ9.8Mjv50_lwztHZHTBNwtnIw'
    
    if @mapbox_token.blank?
      flash[:alert] = "Token Mapbox manquant. Veuillez configurer MAPBOX_ACCESS_TOKEN dans les credentials ou variables d'environnement."
    end
  end

  def apply_filters
    search_params = params[:search] || {}
    
    # Filtre par marque
    if search_params[:make].present?
      @listings = @listings.where("vehicles.make ILIKE ?", "%#{search_params[:make]}%")
    end
    
    # Filtre par modèle
    if search_params[:model].present?
      @listings = @listings.where("vehicles.model ILIKE ?", "%#{search_params[:model]}%")
    end
    
    # Filtre par prix
    if search_params[:min_price].present?
      @listings = @listings.where("vehicles.price >= ?", search_params[:min_price])
    end
    
    if search_params[:max_price].present?
      @listings = @listings.where("vehicles.price <= ?", search_params[:max_price])
    end
    
    # Filtre par année
    if search_params[:min_year].present?
      @listings = @listings.where("vehicles.year >= ?", search_params[:min_year])
    end
    
    if search_params[:max_year].present?
      @listings = @listings.where("vehicles.year <= ?", search_params[:max_year])
    end
    
    # Filtre par type de carburant
    if search_params[:fuel_type].present?
      @listings = @listings.where("vehicles.fuel_type = ?", search_params[:fuel_type])
    end
    
    # Filtre par transmission
    if search_params[:transmission].present?
      @listings = @listings.where("vehicles.transmission = ?", search_params[:transmission])
    end
    
    # Filtre par kilométrage
    if search_params[:max_kilometers].present?
      @listings = @listings.where("vehicles.kilometers <= ?", search_params[:max_kilometers])
    end
    
    # Filtre géographique par zone dessinée
    if search_params[:polygon].present?
      apply_polygon_filter(search_params[:polygon])
    end
    
    # Filtre par distance depuis une position
    if search_params[:center_lat].present? && search_params[:center_lng].present? && search_params[:radius].present?
      apply_distance_filter(
        search_params[:center_lat].to_f,
        search_params[:center_lng].to_f,
        search_params[:radius].to_f
      )
    end
  end

  def apply_polygon_filter(polygon_coords)
    # Convertit les coordonnées du polygone en format SQL PostGIS
    coordinates = JSON.parse(polygon_coords).map { |coord| "#{coord[0]} #{coord[1]}" }.join(',')
    polygon_wkt = "POLYGON((#{coordinates}))"
    
    @listings = @listings.where(
      "ST_Within(ST_Point(vehicles.longitude, vehicles.latitude), ST_GeomFromText(?, 4326))",
      polygon_wkt
    )
  rescue JSON::ParserError
    # Ignore si le format du polygone est incorrect
  end

  def apply_distance_filter(center_lat, center_lng, radius_km)
    # Utilise la formule haversine pour filtrer par distance
    @listings = @listings.where(
      "ST_DWithin(
        ST_Point(vehicles.longitude, vehicles.latitude)::geography,
        ST_Point(?, ?)::geography,
        ?
      )",
      center_lng, center_lat, radius_km * 1000 # Convertit km en mètres
    )
  end

  def format_listings_for_map(listings)
    listings.map do |listing|
      vehicle = listing.vehicle
      main_photo = listing.photos.attached? ? listing.photos.first : nil
      
      {
        id: listing.id,
        title: listing.title,
        price: vehicle.price,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        kilometers: vehicle.kilometers,
        fuel_type: vehicle.fuel_type,
        transmission: vehicle.transmission,
        latitude: vehicle.latitude.to_f,
        longitude: vehicle.longitude.to_f,
        address: vehicle.address,
        location: vehicle.location,
        type: 'vehicle',
        image_url: main_photo ? url_for(main_photo.variant(resize_to_limit: [300, 200])) : nil,
        url: listing_path(listing),
        user: {
          id: listing.user.id,
          name: listing.user.main_profile&.name || listing.user.email.split('@').first
        },
        created_at: listing.created_at.iso8601
      }
    end
  end

  def load_service_providers
    # Charge les prestataires de services qui ont des coordonnées
    service_providers = ServiceProvider.joins(:user)
                                     .where.not(latitude: nil, longitude: nil)
                                     .includes(:service_categories, :user)
    
    service_providers.map do |provider|
      {
        id: provider.id,
        name: provider.company_name.presence || provider.user.email.split('@').first,
        latitude: provider.latitude.to_f,
        longitude: provider.longitude.to_f,
        address: provider.address,
        service_type: provider.service_categories.pluck(:name).join(', '),
        rating: provider.average_rating || 0,
        phone: provider.phone,
        email: provider.contact_email.presence || provider.user.email,
        url: service_provider_path(provider)
      }
    end
  rescue NameError
    # Retourne un tableau vide si ServiceProvider n'existe pas encore
    []
  end

  def calculate_bounds(listings_data)
    return nil if listings_data.empty?
    
    lats = listings_data.map { |listing| listing[:latitude] }
    lngs = listings_data.map { |listing| listing[:longitude] }
    
    {
      north: lats.max,
      south: lats.min,
      east: lngs.max,
      west: lngs.min
    }
  end

  def geocode_with_mapbox(address)
    require 'net/http'
    require 'json'
    
    encoded_address = URI.encode_www_form_component(address)
    url = "https://api.mapbox.com/geocoding/v5/mapbox.places/#{encoded_address}.json?access_token=#{@mapbox_token}&country=fr&language=fr"
    
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      if data['features'].any?
        coordinates = data['features'].first['center']
        return { longitude: coordinates[0], latitude: coordinates[1] }
      end
    end
    
    raise "Aucun résultat trouvé"
  end
end
