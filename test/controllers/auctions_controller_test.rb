require "test_helper"

class AuctionsControllerTest < ActionDispatch::IntegrationTest
  # Fixture shorthand:
  #   auctions(:active_auction) -> linked to listings(:one), owned by users(:one)
  #   users(:two)  -> Bob (potential bidder)
  #   users(:one)  -> Alice (seller)

  setup do
    @auction = auctions(:active_auction)
  end

  # ---------- show (public) ----------

  test "show renders successfully without sign-in" do
    get auction_path(@auction)
    assert_response :success
  end

  test "show renders for authenticated user" do
    sign_in users(:two)
    get auction_path(@auction)
    assert_response :success
  end

  # ---------- place_bid (auth + KYC required) ----------

  test "place_bid redirects unauthenticated user" do
    post place_bid_auction_path(@auction), params: { amount: 30000 }
    assert_response :redirect
  end

  test "place_bid redirects non-KYC user to KYC page" do
    sign_in users(:two) # kyc_status defaults to "none"
    post place_bid_auction_path(@auction), params: { amount: 30000 }
    assert_redirected_to kyc_path
  end

  test "place_bid succeeds for KYC-verified bidder" do
    bidder = users(:two)
    bidder.update!(kyc_status: "verified")
    sign_in bidder

    min_bid = @auction.minimum_next_bid
    post place_bid_auction_path(@auction), params: { amount: min_bid }
    assert_response :redirect
    assert_equal min_bid, @auction.reload.current_price
  end

  test "place_bid rejects bid below minimum" do
    bidder = users(:two)
    bidder.update!(kyc_status: "verified")
    sign_in bidder

    post place_bid_auction_path(@auction), params: { amount: 1 }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  # ---------- watch / unwatch (auth required) ----------

  test "watch redirects unauthenticated user" do
    post watch_auction_path(@auction)
    assert_response :redirect
  end

  test "watch adds user as watcher" do
    sign_in users(:two)
    assert_difference -> { AuctionWatcher.count }, +1 do
      post watch_auction_path(@auction)
    end
    assert_redirected_to auction_path(@auction)
  end

  test "watch is idempotent" do
    sign_in users(:two)
    @auction.auction_watchers.find_or_create_by!(user: users(:two))
    assert_no_difference -> { AuctionWatcher.count } do
      post watch_auction_path(@auction)
    end
  end

  test "unwatch removes user as watcher" do
    sign_in users(:two)
    @auction.auction_watchers.find_or_create_by!(user: users(:two))
    assert_difference -> { AuctionWatcher.count }, -1 do
      delete unwatch_auction_path(@auction)
    end
    assert_redirected_to auction_path(@auction)
  end
end
