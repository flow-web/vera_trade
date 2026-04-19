class AuctionsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_auction, only: [:show, :place_bid, :watch, :unwatch]

  def show
    @listing = @auction.listing
    @vehicle = @listing.vehicle
    @bids = @auction.bids.ordered.limit(50)
    @is_watching = user_signed_in? && @auction.auction_watchers.exists?(user: current_user)
    @seller = @listing.user
  end

  def place_bid
    amount = params[:amount].to_f

    begin
      @bid = @auction.place_bid!(current_user, amount)
      ActionCable.server.broadcast(
        "auction_#{@auction.id}",
        {
          type: "new_bid",
          bid: {
            id: @bid.id,
            amount: @bid.amount.to_f,
            bidder_name: @bid.bidder.display_name,
            created_at: @bid.created_at.iso8601
          },
          auction: {
            current_price: @auction.current_price.to_f,
            bids_count: @auction.bids_count,
            minimum_next_bid: @auction.minimum_next_bid.to_f,
            ends_at: @auction.ends_at.iso8601,
            time_remaining: @auction.time_remaining
          }
        }
      )
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to auction_path(@auction), notice: "Enchère placée : #{amount} €" }
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("bid_errors", partial: "auctions/bid_error", locals: { message: e.message }) }
        format.html { redirect_to auction_path(@auction), alert: e.message }
      end
    end
  end

  def watch
    @auction.auction_watchers.find_or_create_by!(user: current_user)
    redirect_to auction_path(@auction), notice: "Vous suivez cette enchère"
  end

  def unwatch
    @auction.auction_watchers.find_by(user: current_user)&.destroy
    redirect_to auction_path(@auction), notice: "Vous ne suivez plus cette enchère"
  end

  private

  def set_auction
    @auction = Auction.find(params[:id])
  end
end
