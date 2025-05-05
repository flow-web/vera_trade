class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout 'dashboard'
  
  def index
    @my_listings = current_user.listings
    @my_purchases = Listing.where(buyer_id: current_user.id)
    
    # Create wallet if it doesn't exist for the user
    @wallet = current_user.wallet || current_user.create_wallet
    @transactions = @wallet.wallet_transactions.order(created_at: :desc).limit(10)
    
    @conversations = current_user.sent_messages.or(current_user.received_messages)
                                .select(:sender_id, :recipient_id)
                                .distinct
                                .limit(5)
                                .map { |msg| [msg.sender_id, msg.recipient_id].reject { |id| id == current_user.id }.first }
                                .compact
                                .uniq
                                .map { |uid| User.find(uid) }
  end
  
  def my_listings
    @listings = current_user.listings.order(created_at: :desc)
  end
  
  def my_purchases
    @purchases = Listing.where(buyer_id: current_user.id).order(created_at: :desc)
  end
  
  def wallet
    @wallet = current_user.wallet || current_user.create_wallet
    @transactions = @wallet.wallet_transactions.order(created_at: :desc).page(params[:page]).per(20)
  end
  
  def messages
    redirect_to messages_path
  end
  
  def transport
    # Future implementation for transport tracking
    @transports = [] # Placeholder
  end
  
  def services
    # Future implementation for mechanical services
    @services = [] # Placeholder
  end
  
  def profile
    @user = current_user
  end
end 