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
    
    if @vehicle.save
      @listing = current_user.listings.new(listing_params)
      @listing.vehicle = @vehicle
      
      if @listing.save
        redirect_to @listing, notice: 'Votre annonce a été créée avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @listing = Listing.new(listing_params)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.vehicle.update(vehicle_params) && @listing.update(listing_params)
      redirect_to @listing, notice: 'Votre annonce a été mise à jour avec succès.'
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
                                   :kilometers, :fuel_type, :transmission)
  end
end
