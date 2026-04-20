class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    active = Listing.where(status: "active").includes(:vehicle, :user)

    @featured_listing = active.order(created_at: :desc).first
    @curated_listings = active.where.not(id: @featured_listing&.id)
                              .order(created_at: :desc)
                              .limit(4)
    @listings_count   = active.count
  end

  def cgu; end
  def mentions_legales; end
  def confidentialite; end

  def sitemap
    @listings = Listing.where(status: "active").includes(:vehicle).order(updated_at: :desc)
    respond_to do |format|
      format.xml
    end
  end
end
