require "test_helper"

class RustZoneTest < ActiveSupport::TestCase
  test "belongs to a rust_map" do
    assert_equal rust_maps(:one), rust_zones(:one).rust_map
  end

  test "coordinates are required" do
    z = RustZone.new(rust_map: rust_maps(:one), status: "ok")
    refute z.valid?
    assert_includes z.errors[:x_pct], "can't be blank"
    assert_includes z.errors[:y_pct], "can't be blank"
  end

  test "coordinates are clamped to 0..100" do
    z = RustZone.new(rust_map: rust_maps(:one), x_pct: 150, y_pct: -5, status: "ok")
    refute z.valid?
    assert_includes z.errors[:x_pct], "must be less than or equal to 100"
    assert_includes z.errors[:y_pct], "must be greater than or equal to 0"
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
