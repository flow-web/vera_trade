class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Annonces
    @my_listings = current_user.listings.includes(:vehicle).order(created_at: :desc)
    @my_purchases = Listing.where(buyer_id: current_user.id).includes(:vehicle).order(created_at: :desc)
    
    # Portefeuille
    @wallet = current_user.wallet
    @transactions = current_user.wallet_transactions.order(created_at: :desc).limit(5)
    
    # Messagerie
    @conversations = current_user.conversations
      .includes(:other_user, :messages)
      .order(updated_at: :desc)
      .limit(5)
    
    # Services (à implémenter plus tard)
    # @transport_requests = current_user.transport_requests
    #   .includes(:carrier)
    #   .order(created_at: :desc)
    #   .limit(5)
    
    # @service_requests = current_user.service_requests
    #   .includes(:service)
    #   .order(created_at: :desc)
    #   .limit(5)
    
    # Statistiques
    @stats = {
      active_listings: @my_listings.where(status: :active).count,
      total_sales: @my_listings.where(status: :sold).count,
      total_purchases: @my_purchases.count,
      unread_messages: current_user.received_messages.unread.count
    }
  end
end 