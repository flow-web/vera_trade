class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    active = Listing.where(status: "active").includes(:vehicle, :user)

    @featured_listing = active.order(created_at: :desc).first
    @curated_listings = active.where.not(id: @featured_listing&.id)
                              .order(created_at: :desc)
                              .limit(5)
    @listings_count   = active.count
    @segment_counts   = Listing::SEGMENT_YEAR_RANGES.keys.index_with do |key|
      active.by_segment(key).count
    end

    @live_auctions = if defined?(Auction) && Auction.respond_to?(:active)
      Auction.active.includes(listing: :vehicle).limit(3).to_a
    else
      []
    end

    @auctions_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("ENABLE_AUCTIONS", "false")) ||
                        @live_auctions.any?
  end

  def cgu; end
  def mentions_legales; end
  def confidentialite; end

  def sitemap
    @listings = Listing.where(status: "active").includes(:vehicle).order(updated_at: :desc).limit(50_000)
    respond_to do |format|
      format.xml
    end
  end
end
