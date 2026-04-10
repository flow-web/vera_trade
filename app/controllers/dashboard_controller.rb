class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_listings = current_user.listings.includes(:vehicle).order(created_at: :desc)
    @my_purchases = Listing.where(buyer_id: current_user.id).includes(:vehicle).order(created_at: :desc)
    @wallet = current_user.wallet

    # Wishlist — favoris du user
    @my_favorites = current_user.favorited_listings
                                .includes(:vehicle)
                                .where(status: "active")
                                .limit(6)

    # Conversations bidirectionnelles
    @conversations = Conversation.where(user_id: current_user.id)
                                 .or(Conversation.where(other_user_id: current_user.id))
                                 .includes(:user, :other_user)
                                 .order(updated_at: :desc)
                                 .limit(5)

    # KPIs éditoriaux "Votre Garage"
    active_scope             = @my_listings.where(status: "active")
    @active_listings_count   = active_scope.count
    @total_views             = active_scope.sum(:views_count)
    @total_favorites_received = Favorite.joins(:listing)
                                        .where(listings: { user_id: current_user.id, status: "active" })
                                        .count
    @collection_value        = active_scope.joins(:vehicle).sum("vehicles.price")
    @unread_messages_count   = current_user.received_messages.unread.count
    @total_sales_count       = @my_listings.where(status: "sold").count
  end
end
