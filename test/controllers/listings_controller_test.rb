require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  # Fixture shorthand:
  #   users(:one)   -> Alice (owns listings :one)
  #   users(:two)   -> Bob   (owns listings :two)
  #   listings(:one)  -> Citroen BX GTi 16V 1989 (active)
  #   listings(:two)  -> Peugeot 205 GTI 1991 (active)
  #   listings(:three) -> Renault Twingo III 2020 (active)

  # ---------- index (public) ----------

  test "index renders successfully without sign-in" do
    get listings_path
    assert_response :success
  end

  test "index displays active listings" do
    get listings_path
    assert_response :success
    assert_select "body"  # page renders
  end

  test "index filters by make" do
    get listings_path(make: "Renault")
    assert_response :success
  end

  test "index filters by segment" do
    get listings_path(segment: "youngtimer")
    assert_response :success
  end

  test "index filters by price range" do
    get listings_path(price_min: 10_000, price_max: 25_000)
    assert_response :success
  end

  test "index filters by year range" do
    get listings_path(year_min: 1985, year_max: 2000)
    assert_response :success
  end

  test "index sorts by price_asc" do
    get listings_path(sort: "price_asc")
    assert_response :success
  end

  test "index accepts query param for full-text search" do
    get listings_path(query: "Peugeot")
    assert_response :success
  end

  # ---------- show (public) ----------

  test "show renders successfully by slug" do
    listing = listings(:one)
    get listing_path(listing)
    assert_response :success
  end

  test "show increments views_count" do
    listing = listings(:one)
    original = listing.views_count
    get listing_path(listing)
    assert_equal original + 1, listing.reload.views_count
  end

  # ---------- my_listings (auth required) ----------

  test "my_listings redirects unauthenticated user" do
    get my_listings_path
    assert_response :redirect
  end

  test "my_listings renders for authenticated user" do
    sign_in users(:one)
    get my_listings_path
    assert_response :success
  end

  # ---------- new (redirects to wizard) ----------

  test "new redirects unauthenticated user" do
    get new_listing_path
    assert_response :redirect
  end

  test "new redirects to listing wizard" do
    sign_in users(:one)
    users(:one).update!(kyc_status: "verified")
    get new_listing_path
    assert_response :redirect
    assert_match(/listing_wizards/, response.location)
  end

  # ---------- destroy (owner only) ----------

  test "destroy redirects unauthenticated user" do
    delete listing_path(listings(:one))
    assert_response :redirect
  end

  test "destroy removes listing for owner" do
    sign_in users(:one)
    assert_difference -> { Listing.count }, -1 do
      delete listing_path(listings(:one))
    end
    assert_redirected_to my_listings_path
  end

  test "destroy rejects non-owner" do
    sign_in users(:two)
    assert_no_difference -> { Listing.count } do
      delete listing_path(listings(:one))
    end
    assert_redirected_to listings_path
  end

  # ---------- edit ----------

  test "edit redirects unauthenticated user" do
    get edit_listing_path(listings(:one))
    assert_response :redirect
  end

  test "edit redirects non-owner" do
    sign_in users(:two)
    get edit_listing_path(listings(:one))
    assert_redirected_to listings_path
  end
end
