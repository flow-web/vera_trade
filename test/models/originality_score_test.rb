require "test_helper"

class OriginalityScoreTest < ActiveSupport::TestCase
  test "belongs to listing" do
    assert_equal listings(:one), originality_scores(:one).listing
  end

  test "overall_score clamped 0..100" do
    s = OriginalityScore.new(listing: listings(:two), overall_score: 110)
    refute s.valid?
  end

  test "original_paint_pct clamped 0..100" do
    s = OriginalityScore.new(listing: listings(:two), original_paint_pct: 150)
    refute s.valid?
  end
end
