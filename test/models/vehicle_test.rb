require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  # Fixture shorthand:
  #   vehicles(:one) -> Citroen BX GTi 16V 1989
  #   vehicles(:two) -> Peugeot 205 GTI 1.9 1991

  # ---------- presence validations ----------

  test "valid vehicle with required fields" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 25000)
    assert v.valid?
  end

  test "make is required" do
    v = Vehicle.new(model: "E30", year: 1990, price: 25000)
    assert_not v.valid?
    assert v.errors[:make].any?
  end

  test "model is required" do
    v = Vehicle.new(make: "BMW", year: 1990, price: 25000)
    assert_not v.valid?
    assert v.errors[:model].any?
  end

  test "year is required" do
    v = Vehicle.new(make: "BMW", model: "E30", price: 25000)
    assert_not v.valid?
    assert v.errors[:year].any?
  end

  test "price is required" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990)
    assert_not v.valid?
    assert v.errors[:price].any?
  end

  # ---------- numericality validations ----------

  test "price must be positive" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 0)
    assert_not v.valid?
    assert v.errors[:price].any?
  end

  test "kilometers must be non-negative" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, kilometers: -1)
    assert_not v.valid?
    assert v.errors[:kilometers].any?
  end

  test "kilometers nil is allowed" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, kilometers: nil)
    assert v.valid?
  end

  # ---------- license plate format ----------

  test "valid license plate format accepted" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, license_plate: "AB-123-CD")
    assert v.valid?
  end

  test "invalid license plate format rejected" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, license_plate: "1234")
    assert_not v.valid?
    assert v.errors[:license_plate].any?
  end

  test "license plate nil is allowed" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, license_plate: nil)
    assert v.valid?
  end

  # ---------- VIN format ----------

  test "valid VIN accepted" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, vin: "WBAPH5C55BA123456")
    assert v.valid?
  end

  test "invalid VIN rejected" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, vin: "TOOSHORT")
    assert_not v.valid?
    assert v.errors[:vin].any?
  end

  # ---------- normalization callbacks ----------

  test "license plate is normalized to uppercase without separators" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, license_plate: "ab-123-cd")
    v.valid?
    assert_equal "AB123CD", v.license_plate
  end

  test "VIN is normalized to uppercase" do
    v = Vehicle.new(make: "BMW", model: "E30", year: 1990, price: 1000, vin: "wbaph5c55ba123456")
    v.valid?
    assert_equal "WBAPH5C55BA123456", v.vin
  end

  # ---------- associations ----------

  test "vehicle has many listings" do
    assert_respond_to vehicles(:one), :listings
  end
end
