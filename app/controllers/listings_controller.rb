class ListingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @listings = Listing.where(status: 'active').includes(:vehicle, :user).order(created_at: :desc)
  end

  def my_listings
    @listings = current_user.listings.includes(:vehicle).order(created_at: :desc)
  end

  def show
  end

  def new
    @listing = Listing.new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.is_draft = params[:save_as_draft].present?
    
    if @vehicle.save
      @listing = current_user.listings.new(listing_params)
      @listing.vehicle = @vehicle
      @listing.status = 'active' unless @vehicle.is_draft
      
      if @listing.save
        # Gérer les photos après la sauvegarde de l'annonce
        if params[:listing][:photos].present?
          @listing.photos.attach(params[:listing][:photos])
        end
        
        redirect_to @listing, notice: @vehicle.is_draft ? 'Brouillon enregistré avec succès.' : 'Votre annonce a été créée avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @listing = Listing.new(listing_params)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicle = @listing.vehicle
  end

  def update
    # Gérer la suppression des photos existantes
    if params[:delete_photos].present?
      params[:delete_photos].each do |photo_id|
        photo = @listing.photos.find_by(id: photo_id)
        photo.purge if photo
      end
    end
    
    # Gérer l'ajout de nouvelles photos
    if params[:listing][:photos].present?
      @listing.photos.attach(params[:listing][:photos])
    end
    
    @vehicle = @listing.vehicle
    @vehicle.is_draft = params[:save_as_draft].present?
    
    if @vehicle.update(vehicle_params) && @listing.update(listing_params)
      redirect_to @listing, notice: @vehicle.is_draft ? 'Brouillon mis à jour avec succès.' : 'Votre annonce a été mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to my_listings_path, notice: 'Votre annonce a été supprimée avec succès.'
  end

  private

  def set_listing
    @listing = Listing.includes(:vehicle, :user).find(params[:id])
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
    params.require(:vehicle).permit(:make, :model, :year, :description, :price, 
                                   :kilometers, :fuel_type, :transmission,
                                   :finition, :doors, :exterior_color, :interior_material, 
                                   :interior_color, :previous_owners, :last_service_date, 
                                   :next_ct_date, :ct_expiry_date, :has_service_history, 
                                   :non_smoker, :location, :safety_features, :comfort_features, 
                                   :multimedia_features, :exterior_features, :other_features, 
                                   :body_condition, :interior_condition, :tire_condition, 
                                   :recent_works, :issues, :expected_costs,
                                   :license_plate, :vin, :fiscal_power,
                                   :average_consumption, :co2_emissions)
  end
end
