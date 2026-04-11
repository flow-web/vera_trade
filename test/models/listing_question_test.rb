require "test_helper"

class ListingQuestionTest < ActiveSupport::TestCase
  test "belongs to listing and user" do
    q = listing_questions(:one)
    assert q.listing
    assert q.user
  end

  test "body required" do
    q = ListingQuestion.new(listing: listings(:one), user: users(:one))
    refute q.valid?
  end

  test "has one answer" do
    q = listing_questions(:one)
    assert_equal listing_answers(:one), q.answer
  end

  test "published scope returns only published questions" do
    listings(:one).listing_questions.create!(user: users(:two), body: "hidden draft", published: false)
    assert_includes ListingQuestion.published, listing_questions(:one)
    assert_equal 1, ListingQuestion.published.where(listing: listings(:one)).count
  end
end
