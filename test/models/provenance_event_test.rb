require "test_helper"

class ProvenanceEventTest < ActiveSupport::TestCase
  test "belongs to listing" do
    assert_equal listings(:one), provenance_events(:one).listing
  end

  test "event_year required" do
    e = ProvenanceEvent.new(listing: listings(:one), event_type: "purchase", label: "x")
    refute e.valid?
    assert e.errors.of_kind?(:event_year, :blank) || e.errors.of_kind?(:event_year, :not_a_number)
  end

  test "label required" do
    e = ProvenanceEvent.new(listing: listings(:one), event_type: "purchase", event_year: 1990)
    refute e.valid?
  end

  test "event_type must be valid" do
    e = ProvenanceEvent.new(listing: listings(:one), event_year: 1990, label: "x", event_type: "abduction")
    refute e.valid?
  end

  test "default scope orders by year then position" do
    listing = listings(:one)
    listing.provenance_events.destroy_all
    a = listing.provenance_events.create!(event_year: 2000, event_type: "service", label: "A", position: 0)
    b = listing.provenance_events.create!(event_year: 1990, event_type: "purchase", label: "B", position: 0)
    c = listing.provenance_events.create!(event_year: 2000, event_type: "race", label: "C", position: 1)

    assert_equal [b, a, c], listing.provenance_events.reload.to_a
  end
end
