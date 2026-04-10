class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_listings = current_user.listings.includes(:vehicle).order(created_at: :desc)
    @my_purchases = Listing.where(buyer_id: current_user.id).includes(:vehicle).order(created_at: :desc)
    @wallet = current_user.wallet

    # Conversations bidirectionnelles
    @conversations = Conversation.where(user_id: current_user.id)
      .or(Conversation.where(other_user_id: current_user.id))
      .includes(:user, :other_user)
      .order(updated_at: :desc)
      .limit(5)

    @stats = {
      active_listings: @my_listings.where(status: :active).count,
      total_sales: @my_listings.where(status: :sold).count,
      total_purchases: @my_purchases.count,
      unread_messages: current_user.received_messages.unread.count
    }
  end
end
