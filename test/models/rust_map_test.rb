require "test_helper"

class RustMapTest < ActiveSupport::TestCase
  test "belongs to a listing and has many zones" do
    rm = rust_maps(:one)
    assert_equal listings(:one), rm.listing
    assert rm.respond_to?(:zones)
    assert_equal 2, rm.zones.count
  end

  test "silhouette_variant defaults to sedan" do
    rm = RustMap.new
    assert_equal "sedan", rm.silhouette_variant
  end

  test "transparency_score defaults to 100" do
    rm = RustMap.new
    assert_equal 100, rm.transparency_score
  end

  test "transparency_score is clamped between 0 and 100" do
    rm = RustMap.new(listing: listings(:two), transparency_score: 120)
    refute rm.valid?
    assert_includes rm.errors[:transparency_score], "must be less than or equal to 100"
  end

  test "valid silhouette variants" do
    RustMap::VALID_VARIANTS.each do |variant|
      rm = RustMap.new(silhouette_variant: variant, listing: listings(:two))
      assert rm.valid?, "expected #{variant} to be valid: #{rm.errors.full_messages.join(', ')}"
    end
  end

  test "invalid silhouette variant is rejected" do
    rm = RustMap.new(silhouette_variant: "spaceship", listing: listings(:two))
    refute rm.valid?
  end

  test "recompute_score! subtracts severity penalties" do
    rm = rust_maps(:one)
    # one surface zone (5pt penalty) + one ok zone (0pt) → 100 - 5 = 95
    rm.recompute_score!
    assert_equal 95, rm.reload.transparency_score
  end

  test "recompute_score! floors at 0" do
    rm = rust_maps(:one)
    rm.zones.destroy_all
    5.times { rm.zones.create!(x_pct: 10, y_pct: 10, status: "perforation") }
    rm.recompute_score!
    assert_equal 0, rm.reload.transparency_score
  end
end
