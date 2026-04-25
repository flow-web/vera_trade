require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Fixture shorthand:
  #   users(:one)   -> Alice (regular user, owns listing :one)
  #   users(:two)   -> Bob   (regular user, owns listing :two)
  #   users(:three) -> Claire
  #   users(:admin) -> Admin (role: 1)

  # ---------- associations ----------

  test "user has many listings" do
    assert_respond_to users(:one), :listings
    assert users(:one).listings.count > 0
  end

  test "user has many favorites" do
    assert_respond_to users(:one), :favorites
  end

  test "user has many favorited_listings through favorites" do
    assert_respond_to users(:two), :favorited_listings
    assert_includes users(:two).favorited_listings, listings(:one)
  end

  test "user has one wallet" do
    assert_respond_to users(:one), :wallet
    assert_not_nil users(:one).wallet
  end

  test "user has many search_presets" do
    assert_respond_to users(:one), :search_presets
  end

  # ---------- phone uniqueness ----------

  test "phone must be unique" do
    dupe = User.new(
      email: "unique@test.com",
      password: "password123",
      phone: users(:one).phone,
      first_name: "Test",
      last_name: "User",
      terms_accepted: true
    )
    assert_not dupe.valid?
    assert dupe.errors[:phone].any?
  end

  # ---------- wallet auto-creation ----------

  test "wallet is created on user creation" do
    user = User.create!(
      email: "newuser@test.com",
      password: "password123",
      first_name: "New",
      last_name: "User",
      phone: "0699999999",
      terms_accepted: true,
      confirmed_at: Time.current
    )
    assert_not_nil user.wallet
    assert_equal 0, user.wallet.balance.to_i
  end

  # ---------- admin? ----------

  test "admin? returns true for admin user" do
    assert users(:admin).admin?
  end

  test "admin? returns false for regular user" do
    assert_not users(:one).admin?
  end

  # ---------- KYC methods ----------

  test "kyc_verified? returns true when status is verified" do
    users(:one).update_column(:kyc_status, "verified")
    assert users(:one).kyc_verified?
  end

  test "kyc_verified? returns false by default" do
    assert_not users(:one).kyc_verified?
  end

  test "kyc_pending? returns true when status is pending" do
    users(:one).update_column(:kyc_status, "pending")
    assert users(:one).kyc_pending?
  end

  # ---------- display_name ----------

  test "display_name concatenates first and last name" do
    assert_equal "Alice Laurent", users(:one).display_name
  end

  test "display_name falls back to email prefix" do
    user = users(:one)
    user.first_name = nil
    user.last_name = nil
    assert_equal "alice", user.display_name
  end

  # ---------- public_display_name ----------

  test "public_display_name shows first name and last initial" do
    assert_equal "Alice L.", users(:one).public_display_name
  end

  test "public_display_name shows Vendeur when names are blank" do
    user = users(:one)
    user.first_name = nil
    user.last_name = nil
    assert_equal "Vendeur", user.public_display_name
  end

  # ---------- scopes ----------

  test "with_active_listings returns users who have active listings" do
    result = User.with_active_listings
    assert_includes result, users(:one)
  end
end
