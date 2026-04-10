class ListingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  PER_PAGE = 12

  def index
    @listings = Listing.where(status: "active").includes(:vehicle, :user)
    @listings = @listings.search_query(params[:query]) if params[:query].present?
    @listings = @listings.by_make(params[:make])
    @listings = @listings.by_fuel(params[:fuel_type])
    @listings = @listings.by_transmission(params[:transmission])
    @listings = @listings.by_price_range(params[:price_min], params[:price_max])
    @listings = @listings.by_year_range(params[:year_min], params[:year_max])
    @listings = @listings.by_km_max(params[:km_max])
    @listings = @listings.sorted_by(params[:sort])

    @total_count = @listings.count
    @page = [params[:page].to_i, 1].max
    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @listings = @listings.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def my_listings
    @listings = current_user.listings.includes(:vehicle).order(created_at: :desc)
  end

  def show
    @listing.increment!(:views_count)
    @vehicle = @listing.vehicle
    @is_favorited = user_signed_in? && current_user.favorites.exists?(listing: @listing)
    @seller = @listing.user
    @other_listings = @seller.listings.where(status: "active").where.not(id: @listing.id).includes(:vehicle).limit(3)
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
      @listing.status = "active" unless @vehicle.is_draft

      if @listing.save
        @listing.photos.attach(params[:listing][:photos]) if params[:listing][:photos].present?
        redirect_to @listing, notice: @vehicle.is_draft ? "Brouillon enregistré." : "Annonce publiée !"
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
    if params[:delete_photos].present?
      params[:delete_photos].each do |photo_id|
        photo = @listing.photos.find_by(id: photo_id)
        photo.purge if photo
      end
    end
    @listing.photos.attach(params[:listing][:photos]) if params[:listing][:photos].present?

    @vehicle = @listing.vehicle
    @vehicle.is_draft = params[:save_as_draft].present?

    if @vehicle.update(vehicle_params) && @listing.update(listing_params)
      redirect_to @listing, notice: "Annonce mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to my_listings_path, notice: "Annonce supprimée."
  end

  private

  def set_listing
    @listing = Listing.includes(:vehicle, :user).find_by(slug: params[:id]) || Listing.find(params[:id])
  end

  def ensure_owner
    redirect_to listings_path, alert: "Non autorisé." unless @listing.user == current_user
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :status)
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :make, :model, :year, :description, :price, :kilometers, :fuel_type, :transmission,
      :finition, :doors, :exterior_color, :interior_material, :interior_color,
      :previous_owners, :last_service_date, :next_ct_date, :ct_expiry_date,
      :has_service_history, :non_smoker, :location,
      :safety_features, :comfort_features, :multimedia_features, :exterior_features,
      :other_features, :body_condition, :interior_condition, :tire_condition,
      :recent_works, :issues, :expected_costs,
      :license_plate, :vin, :fiscal_power, :average_consumption, :co2_emissions
    )
  end
end
