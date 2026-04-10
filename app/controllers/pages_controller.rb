class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home; end

  def sitemap
    @listings = Listing.where(status: "active").includes(:vehicle).order(updated_at: :desc)
    respond_to do |format|
      format.xml
    end
  end
end
