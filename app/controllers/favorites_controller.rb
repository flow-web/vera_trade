class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @listings = current_user.favorited_listings.includes(:vehicle).order("favorites.created_at DESC")
  end

  def create
    listing = Listing.find(params[:listing_id])
    current_user.favorites.find_or_create_by(listing: listing)
    redirect_back fallback_location: listing, notice: "Ajouté aux favoris"
  end

  def destroy
    favorite = current_user.favorites.find_by(listing_id: params[:listing_id])
    favorite&.destroy
    redirect_back fallback_location: listings_path, notice: "Retiré des favoris"
  end
end
