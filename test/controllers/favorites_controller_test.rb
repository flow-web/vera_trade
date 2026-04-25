require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  # Fixture shorthand:
  #   users(:two) has favorited listings(:one) via favorites(:one)

  setup do
    @user = users(:two)
    sign_in @user
  end

  # ---------- index ----------

  test "index redirects unauthenticated user" do
    sign_out @user
    get favorites_path
    assert_response :redirect
  end

  test "index renders for authenticated user" do
    get favorites_path
    assert_response :success
  end

  # ---------- create ----------

  test "create adds a listing to favorites" do
    listing = listings(:three) # not yet favorited by user two
    assert_difference -> { Favorite.count }, +1 do
      post listing_favorite_path(listing)
    end
    assert_response :redirect
  end

  test "create is idempotent for already-favorited listing" do
    listing = listings(:one) # already favorited by user two
    assert_no_difference -> { Favorite.count } do
      post listing_favorite_path(listing)
    end
    assert_response :redirect
  end

  # ---------- destroy ----------

  test "destroy removes a favorite" do
    listing = listings(:one) # favorited by user two
    assert_difference -> { Favorite.count }, -1 do
      delete listing_favorite_path(listing)
    end
    assert_response :redirect
  end

  test "destroy silently handles non-existent favorite" do
    listing = listings(:three) # not favorited
    assert_no_difference -> { Favorite.count } do
      delete listing_favorite_path(listing)
    end
    assert_response :redirect
  end
end
