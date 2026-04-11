require "test_helper"

class ListingTest < ActiveSupport::TestCase
  # PR1 catalogue-search — covers the filter scopes and the pg_search-backed
  # full-text search_query scope. These hit the real Postgres test DB because
  # pg_search ranks depend on tsvector/tsquery evaluation server-side.

  # ----------------------------------------------------------------------
  # Fixture shorthand — the three contrasted fixtures loaded by default:
  #
  #   :one   → Citroën BX GTi 16V 1989 (Youngtimer, 18500 €, 142500 km, Lyon)
  #   :two   → Peugeot 205 GTI 1.9 1991 (Youngtimer, 22000 €, 98700 km, Bordeaux)
  #   :three → Renault Twingo III 2020  (Récent,      8200 €,  35000 km, Paris)
  # ----------------------------------------------------------------------

  # ---------- search_query (pg_search weighted) ----------
  test "search_query finds a listing by vehicle make" do
    results = Listing.search_query("Citroën")
    assert_includes results, listings(:one)
    refute_includes results, listings(:two)
    refute_includes results, listings(:three)
  end

  test "search_query finds a listing by vehicle model" do
    results = Listing.search_query("Twingo")
    assert_includes results, listings(:three)
    refute_includes results, listings(:one)
  end

  test "search_query finds a listing by title prefix match" do
    # prefix: true — "peug" should match "Peugeot 205 GTI 1.9 de 1991"
    results = Listing.search_query("peug")
    assert_includes results, listings(:two)
  end

  test "search_query is case-insensitive" do
    results = Listing.search_query("renault")
    assert_includes results, listings(:three)
  end

  test "search_query returns empty relation on total miss" do
    assert_empty Listing.search_query("zzzzzunknowncar")
  end

  # ---------- by_make ----------
  test "by_make restricts to the given vehicle make" do
    results = Listing.by_make("Renault")
    assert_equal [ listings(:three) ], results.to_a
  end

  test "by_make returns all listings when make is blank" do
    assert_equal Listing.count, Listing.by_make(nil).count
    assert_equal Listing.count, Listing.by_make("").count
  end

  # ---------- by_segment (SEGMENT_YEAR_RANGES) ----------
  test "by_segment youngtimer matches 1985-1999 vehicles" do
    results = Listing.by_segment("youngtimer")
    assert_includes results, listings(:one)   # 1989
    assert_includes results, listings(:two)   # 1991
    refute_includes results, listings(:three) # 2020
  end

  test "by_segment recent matches vehicles from 2016 onwards" do
    results = Listing.by_segment("recent")
    assert_includes results, listings(:three) # 2020
    refute_includes results, listings(:one)   # 1989
    refute_includes results, listings(:two)   # 1991
  end

  test "by_segment moderne matches 2000-2015 vehicles (empty in current fixtures)" do
    assert_empty Listing.by_segment("moderne")
  end

  test "by_segment returns all when segment is blank" do
    assert_equal Listing.count, Listing.by_segment(nil).count
    assert_equal Listing.count, Listing.by_segment("").count
  end

  test "by_segment returns none for unknown segment" do
    assert_empty Listing.by_segment("wacky_segment")
  end

  # ---------- by_price_range ----------
  test "by_price_range with min and max filters correctly" do
    # Twingo 8200, BX 18500, 205 GTI 22000 → range 10000..20000 should keep
    # only the BX.
    results = Listing.by_price_range(10_000, 20_000)
    assert_equal [ listings(:one) ], results.to_a
  end

  test "by_price_range with only min works" do
    results = Listing.by_price_range(15_000, nil)
    assert_includes results, listings(:one)
    assert_includes results, listings(:two)
    refute_includes results, listings(:three)
  end

  # ---------- sorted_by ----------
  test "sorted_by price_asc orders by vehicle price ascending" do
    results = Listing.sorted_by("price_asc").to_a
    ids = results.map(&:id)
    assert_equal [ listings(:three).id, listings(:one).id, listings(:two).id ], ids
  end

  test "sorted_by year_desc orders by vehicle year descending" do
    results = Listing.sorted_by("year_desc").to_a
    assert_equal listings(:three).id, results.first.id
  end

  test "sorted_by with unknown key falls back to created_at desc" do
    results = Listing.sorted_by("garbage")
    assert_respond_to results, :to_a
    assert_equal Listing.count, results.count
  end
end
