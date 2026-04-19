class AuctionChannel < ApplicationCable::Channel
  def subscribed
    auction = Auction.find(params[:id])
    stream_from "auction_#{auction.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
