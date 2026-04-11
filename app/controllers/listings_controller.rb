class ListingsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_listing, only: [ :show, :edit, :destroy ]
  before_action :ensure_owner, only: [ :edit, :destroy ]

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
    @page = [ params[:page].to_i, 1 ].max
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

  # M8 — l'ancien formulaire monolithique est remplacé par le wizard 7 étapes.
  # new/edit redirigent désormais vers ListingWizardsController. create/update
  # sont supprimés (le wizard utilise ses propres actions save_step + publish).
  def new
    redirect_to new_listing_wizard_path
  end

  def edit
    if @listing.draft?
      redirect_to edit_listing_wizard_path(@listing)
    else
      # Pour une annonce déjà publiée, on pourrait ouvrir un wizard en mode
      # édition. Pour l'instant on retombe vers le show.
      redirect_to listing_path(@listing), alert: "L'édition d'une annonce publiée sera disponible prochainement."
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
end
