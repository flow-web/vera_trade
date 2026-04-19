require "test_helper"

class AuctionTest < ActiveSupport::TestCase
  test "valid auction with required fields" do
    auction = Auction.new(
      listing: listings(:two),
      starting_price: 10000,
      status: "scheduled",
      duration_days: 7,
      starts_at: 1.day.from_now,
      ends_at: 8.days.from_now
    )
    assert auction.valid?
  end

  test "duration_days must be in allowed set" do
    auction = auctions(:active_auction)
    auction.duration_days = 6
    assert_not auction.valid?
  end

  test "starting_price must be positive" do
    auction = auctions(:active_auction)
    auction.starting_price = 0
    assert_not auction.valid?
  end

  test "minimum_next_bid returns starting_price when no bids" do
    auction = Auction.new(starting_price: 10000, current_price: nil)
    assert_equal 10000, auction.minimum_next_bid
  end

  test "minimum_next_bid increments based on current price tier" do
    auction = Auction.new(starting_price: 1000, current_price: 3500)
    assert_equal 3600, auction.minimum_next_bid

    auction.current_price = 15000
    assert_equal 15250, auction.minimum_next_bid

    auction.current_price = 50000
    assert_equal 50500, auction.minimum_next_bid
  end

  test "place_bid! creates bid and updates current_price" do
    auction = auctions(:active_auction)
    bidder = users(:two)
    min = auction.minimum_next_bid

    bid = auction.place_bid!(bidder, min)

    assert bid.persisted?
    assert_equal min, bid.amount
    auction.reload
    assert_equal min, auction.current_price
  end

  test "place_bid! rejects bid below minimum" do
    auction = auctions(:active_auction)
    bidder = users(:two)

    assert_raises(RuntimeError) { auction.place_bid!(bidder, 1) }
  end

  test "place_bid! rejects seller bidding on own auction" do
    auction = auctions(:active_auction)
    seller = auction.listing.user

    assert_raises(RuntimeError) { auction.place_bid!(seller, 99999) }
  end

  test "anti-snipe extends ends_at when bid placed in last 2 minutes" do
    auction = auctions(:active_auction)
    auction.update!(ends_at: 1.minute.from_now)
    bidder = users(:two)
    original_ends_at = auction.ends_at

    auction.place_bid!(bidder, auction.minimum_next_bid)

    auction.reload
    assert auction.ends_at > original_ends_at
  end

  test "reserve_met? returns true when no reserve" do
    auction = auctions(:active_auction)
    auction.reserve_price = nil
    assert auction.reserve_met?
  end

  test "reserve_met? returns false when price below reserve" do
    auction = auctions(:active_auction)
    auction.reserve_price = 100000
    auction.current_price = 22500
    assert_not auction.reserve_met?
  end

  test "finalize! marks as sold when reserve met" do
    auction = auctions(:active_auction)
    auction.update!(ends_at: 1.second.ago, reserve_price: 20000)
    bid = auction.bids.create!(bidder: users(:two), amount: 22500)

    auction.finalize!
    assert_equal "sold", auction.status
  end

  test "finalize! marks as ended when reserve not met" do
    auction = auctions(:active_auction)
    auction.update!(ends_at: 1.second.ago, reserve_price: 100000, current_price: 22500)
    auction.bids.create!(bidder: users(:two), amount: 22500)

    auction.finalize!
    assert_equal "ended", auction.status
  end

  test "time_remaining returns 0 when ended" do
    auction = auctions(:active_auction)
    auction.status = "ended"
    assert_equal 0, auction.time_remaining
  end
end
