require "test_helper"

class AuctionFinalizerJobTest < ActiveJob::TestCase
  test "finalizes expired active auctions" do
    auction = auctions(:active_auction)
    auction.update_columns(ends_at: 1.minute.ago, status: "active")

    AuctionFinalizerJob.perform_now

    auction.reload
    assert_includes %w[ended sold], auction.status
  end

  test "does not finalize auctions that have not ended" do
    auction = auctions(:active_auction)
    auction.update_columns(ends_at: 1.hour.from_now, status: "active")

    AuctionFinalizerJob.perform_now

    auction.reload
    assert_equal "active", auction.status
  end
end
