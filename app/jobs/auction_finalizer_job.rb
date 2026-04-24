class AuctionFinalizerJob < ApplicationJob
  queue_as :default

  def perform
    Auction.active.where(ends_at: ...Time.current).find_each do |auction|
      auction.finalize!
    rescue => e
      Rails.logger.error("[AuctionFinalizerJob] Failed to finalize auction ##{auction.id}: #{e.message}")
    end
  end
end
