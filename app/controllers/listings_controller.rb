class ListingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @listings = Listing.includes(:vehicle, :user).where(status: 'active')
    
    # Filtres généraux
    @listings = @listings.joins(:vehicle)
    
    # Filtres de base
    @listings = @listings.where('vehicles.make ILIKE ?', "%#{params[:make]}%") if params[:make].present?
    @listings = @listings.where('vehicles.model ILIKE ?', "%#{params[:model]}%") if params[:model].present?
    @listings = @listings.where('vehicles.year >= ?', params[:year_min]) if params[:year_min].present?
    @listings = @listings.where('vehicles.year <= ?', params[:year_max]) if params[:year_max].present?
    @listings = @listings.where('vehicles.price >= ?', params[:price_min]) if params[:price_min].present?
    @listings = @listings.where('vehicles.price <= ?', params[:price_max]) if params[:price_max].present?
    @listings = @listings.where('vehicles.kilometers >= ?', params[:km_min]) if params[:km_min].present?
    @listings = @listings.where('vehicles.kilometers <= ?', params[:km_max]) if params[:km_max].present?
    @listings = @listings.where('vehicles.fuel_type = ?', params[:fuel_type]) if params[:fuel_type].present?
    @listings = @listings.where('vehicles.transmission = ?', params[:transmission]) if params[:transmission].present?
    
    # Filtre par catégorie
    @listings = @listings.where('vehicles.category_id = ?', params[:category_id]) if params[:category_id].present?
    
    # Filtre par sous-catégorie
    @listings = @listings.where('vehicles.subcategory = ?', params[:subcategory]) if params[:subcategory].present?
    
    # Filtres spécifiques aux équipements
    if params[:equipment].present?
      equipment_filters = params[:equipment].is_a?(Array) ? params[:equipment] : [params[:equipment]]
      
      equipment_filters.each do |equipment|
        @listings = @listings.where('vehicles.safety_features ILIKE ? OR vehicles.comfort_features ILIKE ? OR vehicles.multimedia_features ILIKE ? OR vehicles.exterior_features ILIKE ? OR vehicles.other_features ILIKE ?', 
                                   "%#{equipment}%", "%#{equipment}%", "%#{equipment}%", "%#{equipment}%", "%#{equipment}%")
      end
    end
    
    # Filtres spécifiques pour différentes catégories
    if params[:category_id].present?
      case Category.find_by(id: params[:category_id])&.name
      when "Voiture"
        @listings = @listings.where('vehicles.doors = ?', params[:doors]) if params[:doors].present?
        @listings = @listings.where('vehicles.interior_material = ?', params[:interior_material]) if params[:interior_material].present?
      when "Moto"
        @listings = @listings.where('vehicles.cylinder_capacity >= ?', params[:cylinder_capacity_min]) if params[:cylinder_capacity_min].present?
        @listings = @listings.where('vehicles.cylinder_capacity <= ?', params[:cylinder_capacity_max]) if params[:cylinder_capacity_max].present?
        @listings = @listings.where('vehicles.engine_type = ?', params[:engine_type]) if params[:engine_type].present?
        @listings = @listings.where('vehicles.license_type = ?', params[:license_type]) if params[:license_type].present?
      when "Bateau"
        @listings = @listings.where('vehicles.length >= ?', params[:length_min]) if params[:length_min].present?
        @listings = @listings.where('vehicles.length <= ?', params[:length_max]) if params[:length_max].present?
        @listings = @listings.where('vehicles.hull_material = ?', params[:hull_material]) if params[:hull_material].present?
        @listings = @listings.where('vehicles.number_of_cabins >= ?', params[:number_of_cabins_min]) if params[:number_of_cabins_min].present?
      when "Avion"
        @listings = @listings.where('vehicles.flight_hours <= ?', params[:flight_hours_max]) if params[:flight_hours_max].present?
        @listings = @listings.where('vehicles.number_of_seats >= ?', params[:number_of_seats_min]) if params[:number_of_seats_min].present?
      when "Véhicule de chantier"
        @listings = @listings.where('vehicles.operating_hours <= ?', params[:operating_hours_max]) if params[:operating_hours_max].present?
      end
    end
    
    # Tri
    case params[:sort]
    when 'price_asc'
      @listings = @listings.order('vehicles.price ASC')
    when 'price_desc'
      @listings = @listings.order('vehicles.price DESC')
    when 'date_desc'
      @listings = @listings.order('listings.created_at DESC')
    when 'date_asc'
      @listings = @listings.order('listings.created_at ASC')
    when 'km_asc'
      @listings = @listings.order('vehicles.kilometers ASC')
    when 'year_desc'
      @listings = @listings.order('vehicles.year DESC')
    when 'year_asc'
      @listings = @listings.order('vehicles.year ASC')
    else
      @listings = @listings.order('listings.created_at DESC')
    end
    
    # Préparation des données pour les filtres
    @categories = Category.main_categories.order(:name)
    @subcategories = params[:category_id].present? ? 
                    Category.find(params[:category_id]).subcategories.order(:name) : []
    
    # Chargement des équipements pour le formulaire de filtrage
    @equipment_categories = Vehicle.equipment_categories
  end

  def my_listings
    @listings = current_user.listings.includes(:vehicle, :media_items).order(created_at: :desc)
  end

  def show
    @public_media = @listing.media_items.public_items.where(media_folder: nil).includes(media_attachment: :blob)
    @media_folders = @listing.media_folders if current_user && @listing.user_id == current_user.id
  end

  def new
    @listing = Listing.new
    @vehicle = Vehicle.new
    @categories = Category.main_categories.order(:name)
    @contexts = MediaItem::CONTEXTS
    @folder_types = MediaFolder::FOLDER_TYPES
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    
    if @vehicle.save
      @listing = current_user.listings.new(listing_params)
      @listing.vehicle = @vehicle
      
      if @listing.save
        # Gérer les photos après la sauvegarde de l'annonce
        if params[:listing][:media_items_attributes].present?
          handle_media_items(params[:listing][:media_items_attributes], @listing)
        end
        
        # Gérer les dossiers médias
        if params[:listing][:media_folders_attributes].present?
          handle_media_folders(params[:listing][:media_folders_attributes], @listing)
        end
        
        redirect_to @listing, notice: 'Votre annonce a été créée avec succès.'
      else
        @categories = Category.main_categories.order(:name)
        @contexts = MediaItem::CONTEXTS
        @folder_types = MediaFolder::FOLDER_TYPES
        render :new, status: :unprocessable_entity
      end
    else
      @listing = Listing.new(listing_params)
      @categories = Category.main_categories.order(:name)
      @contexts = MediaItem::CONTEXTS
      @folder_types = MediaFolder::FOLDER_TYPES
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicle = @listing.vehicle
    @categories = Category.main_categories.order(:name)
    @subcategories = @listing.vehicle.category ? 
                    @listing.vehicle.category.subcategories.order(:name) : []
    @contexts = MediaItem::CONTEXTS
    @folder_types = MediaFolder::FOLDER_TYPES
    @public_media = @listing.media_items.public_items.where(media_folder: nil).includes(media_attachment: :blob)
    @media_folders = @listing.media_folders.includes(media_items: { media_attachment: :blob })
  end

  def update
    # Gérer la suppression des médias existants
    if params[:delete_media_items].present?
      params[:delete_media_items].each do |item_id|
        media = @listing.media_items.find_by(id: item_id)
        media&.destroy
      end
    end
    
    # Gérer la suppression des dossiers médias
    if params[:delete_media_folders].present?
      params[:delete_media_folders].each do |folder_id|
        folder = @listing.media_folders.find_by(id: folder_id)
        folder&.destroy
      end
    end
    
    # Gérer l'ajout de nouveaux médias
    if params[:listing][:media_items_attributes].present?
      handle_media_items(params[:listing][:media_items_attributes], @listing)
    end
    
    # Gérer l'ajout de nouveaux dossiers médias
    if params[:listing][:media_folders_attributes].present?
      handle_media_folders(params[:listing][:media_folders_attributes], @listing)
    end
    
    if @listing.vehicle.update(vehicle_params) && @listing.update(listing_params)
      redirect_to @listing, notice: 'Votre annonce a été mise à jour avec succès.'
    else
      @vehicle = @listing.vehicle
      @categories = Category.main_categories.order(:name)
      @subcategories = @listing.vehicle.category ? 
                      @listing.vehicle.category.subcategories.order(:name) : []
      @contexts = MediaItem::CONTEXTS
      @folder_types = MediaFolder::FOLDER_TYPES
      @public_media = @listing.media_items.public_items.where(media_folder: nil).includes(media_attachment: :blob)
      @media_folders = @listing.media_folders.includes(media_items: { media_attachment: :blob })
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to my_listings_path, notice: 'Votre annonce a été supprimée avec succès.'
  end

  private

  def set_listing
    @listing = Listing.includes(:vehicle, :user, :media_items, :media_folders).find(params[:id])
  end

  def ensure_owner
    unless @listing.user == current_user
      redirect_to listings_path, alert: 'Vous n\'êtes pas autorisé à modifier cette annonce.'
    end
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :status)
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :make, :model, :year, :description, :price, :kilometers, :fuel_type, :transmission,
      :finition, :doors, :exterior_color, :interior_material, :interior_color, :previous_owners, 
      :last_service_date, :next_ct_date, :ct_expiry_date, :has_service_history, :non_smoker, 
      :location, :safety_features, :comfort_features, :multimedia_features, :exterior_features, 
      :other_features, :body_condition, :interior_condition, :tire_condition, :recent_works, 
      :issues, :expected_costs, :category_id, :subcategory, :custom_type, :cylinder_capacity, 
      :engine_type, :cooling_type, :starter_type, :license_type, :length, :width, :draft, 
      :hull_material, :number_of_cabins, :number_of_berths, :engine_hours, :drive_type, 
      :transmission_type, :number_of_seats, :flight_hours, :number_of_engines, :ceiling, 
      :range, :operating_hours, :lifting_capacity, :maximum_reach, :additional_equipment, 
      :bucket_capacity, :loading_capacity, :towing_capacity, :axles, :sleeping_cab, :emission_standard
    )
  end
  
  def handle_media_items(media_items_attributes, listing)
    media_items_attributes.to_h.values.each do |media_item_attr|
      next unless media_item_attr[:media].present?
      
      content_type = detect_content_type(media_item_attr[:media])
      private = media_item_attr[:private] == "1"
      folder_id = media_item_attr[:media_folder_id].presence
      
      media_item = listing.media_items.new(
        title: media_item_attr[:title].presence || "Sans titre",
        context: media_item_attr[:context],
        content_type: content_type,
        private: private,
        media_folder_id: folder_id
      )
      
      media_item.media.attach(media_item_attr[:media])
      
      unless media_item.save
        logger.error "Erreur lors de la sauvegarde du media item: #{media_item.errors.full_messages.join(', ')}"
      end
    end
  end
  
  def handle_media_folders(media_folders_attributes, listing)
    media_folders_attributes.to_h.values.each do |folder_attr|
      next unless folder_attr[:name].present?
      
      media_folder = listing.media_folders.new(
        name: folder_attr[:name],
        description: folder_attr[:description],
        private: folder_attr[:private] == "1"
      )
      
      if media_folder.save && folder_attr[:media_items_attributes].present?
        folder_attr[:media_items_attributes].to_h.values.each do |media_item_attr|
          next unless media_item_attr[:media].present?
          
          content_type = detect_content_type(media_item_attr[:media])
          
          media_item = media_folder.media_items.new(
            title: media_item_attr[:title].presence || "Sans titre",
            context: media_item_attr[:context],
            content_type: content_type,
            private: true,
            listing: listing
          )
          
          media_item.media.attach(media_item_attr[:media])
          
          unless media_item.save
            logger.error "Erreur lors de la sauvegarde du media item dans le dossier: #{media_item.errors.full_messages.join(', ')}"
          end
        end
      else
        logger.error "Erreur lors de la sauvegarde du dossier media: #{media_folder.errors.full_messages.join(', ')}"
      end
    end
  end
  
  def detect_content_type(upload)
    return "document" if upload.content_type == "application/pdf"
    return "video" if upload.content_type.start_with?('video/')
    return "image" if upload.content_type.start_with?('image/')
    
    "unknown"
  end
end

