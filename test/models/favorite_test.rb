require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  # Fixture shorthand:
  #   favorites(:one) -> user :two favorited listing :one

  test "valid favorite" do
    fav = Favorite.new(user: users(:three), listing: listings(:one))
    assert fav.valid?
  end

  test "requires user" do
    fav = Favorite.new(listing: listings(:one))
    assert_not fav.valid?
  end

  test "requires listing" do
    fav = Favorite.new(user: users(:one))
    assert_not fav.valid?
  end

  test "uniqueness scoped to user and listing" do
    # favorites(:one) is user :two + listing :one
    duplicate = Favorite.new(user: users(:two), listing: listings(:one))
    assert_not duplicate.valid?
    assert duplicate.errors[:listing_id].any?
  end

  test "same user can favorite different listings" do
    fav = Favorite.new(user: users(:two), listing: listings(:two))
    assert fav.valid?
  end

  test "different users can favorite the same listing" do
    fav = Favorite.new(user: users(:three), listing: listings(:one))
    assert fav.valid?
  end
end
