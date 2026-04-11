require "test_helper"

class RustZoneTest < ActiveSupport::TestCase
  test "belongs to a rust_map" do
    assert_equal rust_maps(:one), rust_zones(:one).rust_map
  end

  test "coordinates are required" do
    z = RustZone.new(rust_map: rust_maps(:one), status: "ok")
    refute z.valid?
    assert z.errors.of_kind?(:x_pct, :blank) || z.errors.of_kind?(:x_pct, :not_a_number)
    assert z.errors.of_kind?(:y_pct, :blank) || z.errors.of_kind?(:y_pct, :not_a_number)
  end

  test "coordinates are clamped to 0..100" do
    z = RustZone.new(rust_map: rust_maps(:one), x_pct: 150, y_pct: -5, status: "ok")
    refute z.valid?
    assert z.errors.of_kind?(:x_pct, :less_than_or_equal_to)
    assert z.errors.of_kind?(:y_pct, :greater_than_or_equal_to)
  end

  test "status must be in enum" do
    z = RustZone.new(rust_map: rust_maps(:one), x_pct: 10, y_pct: 10, status: "molten")
    refute z.valid?
  end

  test "SEVERITY hash drives score penalty" do
    assert_equal 0,  RustZone::SEVERITY["ok"]
    assert_equal 5,  RustZone::SEVERITY["surface"]
    assert_equal 12, RustZone::SEVERITY["deep"]
    assert_equal 25, RustZone::SEVERITY["perforation"]
  end
end
