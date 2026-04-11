require "test_helper"

class ListingQuestionTest < ActiveSupport::TestCase
  # ---------- Associations ----------
  test "belongs to listing and user" do
    q = listing_questions(:one)
    assert q.listing
    assert q.user
  end

  test "has one answer" do
    q = listing_questions(:one)
    assert_equal listing_answers(:one), q.answer
  end

  # ---------- Validations ----------
  test "body is required" do
    q = ListingQuestion.new(listing: listings(:one), user: users(:two))
    refute q.valid?
    assert_includes q.errors[:body], "doit être rempli(e)"
  end

  test "body length capped at BODY_MAX_LENGTH" do
    q = ListingQuestion.new(
      listing: listings(:one),
      user: users(:two),
      body: "x" * (ListingQuestion::BODY_MAX_LENGTH + 1)
    )
    refute q.valid?
    assert q.errors[:body].any?
  end

  # ---------- published default + scope ----------
  test "new questions default to published=true via attribute default" do
    q = ListingQuestion.new(listing: listings(:one), user: users(:two), body: "test")
    assert_equal true, q.published
  end

  test "published scope returns only published questions" do
    hidden = listings(:one).listing_questions.create!(
      user: users(:two),
      body: "hidden draft",
      published: false
    )
    published_ids = ListingQuestion.published.pluck(:id)
    assert_includes published_ids, listing_questions(:one).id
    refute_includes published_ids, hidden.id
  end

  # ---------- unanswered / answered scopes ----------
  test "unanswered scope excludes questions with an answer" do
    # listing_questions(:one) is answered via listing_answers(:one).
    unanswered_q = listings(:one).listing_questions.create!(
      user: users(:two),
      body: "pas encore répondue"
    )
    unanswered_ids = ListingQuestion.unanswered.pluck(:id)
    assert_includes unanswered_ids, unanswered_q.id
    refute_includes unanswered_ids, listing_questions(:one).id
  end

  test "answered scope includes only questions with an answer" do
    answered_ids = ListingQuestion.answered.pluck(:id)
    assert_includes answered_ids, listing_questions(:one).id
  end

  # ---------- ordered scope ----------
  test "ordered scope returns by created_at ascending" do
    older = listings(:one).listing_questions.create!(
      user: users(:two),
      body: "older",
      created_at: 2.days.ago
    )
    newer = listings(:one).listing_questions.create!(
      user: users(:two),
      body: "newer",
      created_at: 1.hour.ago
    )
    ordered = listings(:one).listing_questions.ordered.pluck(:id)
    assert ordered.index(older.id) < ordered.index(newer.id),
      "older question must appear before newer in chronological order"
  end

  # ---------- Rate limit guard ----------
  test "over_rate_limit? returns false when under the daily cap" do
    refute ListingQuestion.over_rate_limit?(user: users(:two), listing: listings(:one))
  end

  test "over_rate_limit? returns true once RATE_LIMIT_PER_DAY questions posted in 24h" do
    user = users(:three)
    listing = listings(:one)
    ListingQuestion::RATE_LIMIT_PER_DAY.times do |i|
      listing.listing_questions.create!(user: user, body: "q #{i}")
    end
    assert ListingQuestion.over_rate_limit?(user: user, listing: listing)
  end

  test "over_rate_limit? is scoped per listing (not global)" do
    user = users(:three)
    ListingQuestion::RATE_LIMIT_PER_DAY.times do |i|
      listings(:one).listing_questions.create!(user: user, body: "q #{i}")
    end
    # Limit reached on listing :one, but :two should still accept.
    refute ListingQuestion.over_rate_limit?(user: user, listing: listings(:two))
  end

  test "over_rate_limit? ignores questions older than 24 hours" do
    user = users(:three)
    listing = listings(:one)
    ListingQuestion::RATE_LIMIT_PER_DAY.times do |i|
      listing.listing_questions.create!(user: user, body: "stale #{i}", created_at: 2.days.ago)
    end
    refute ListingQuestion.over_rate_limit?(user: user, listing: listing)
  end
end
