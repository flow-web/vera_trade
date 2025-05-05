module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @total_listings = Listing.count
      @total_vehicles = Vehicle.count
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_listings = Listing.includes(:user, :vehicle).order(created_at: :desc).limit(5)
      @pending_listings = Listing.where(status: 'pending').count
      @active_listings = Listing.where(status: 'active').count
    end
  end
end 