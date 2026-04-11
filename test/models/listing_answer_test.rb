require "test_helper"

class ListingAnswerTest < ActiveSupport::TestCase
  # Fixture reminder :
  #   listings(:one).user     → users(:one)    (Alice)
  #   listing_questions(:one) → user: users(:two) (Bob, acheteur)
  #   listing_answers(:one)   → user: users(:one) (Alice, vendeur)
  #
  # The model contract: only the listing's owner may answer a question
  # posted on that listing.

  # ---------- Associations ----------
  test "belongs to listing_question and user" do
    a = listing_answers(:one)
    assert a.listing_question
    assert a.user
  end

  # ---------- Validations ----------
  test "body is required" do
    q = listings(:two).listing_questions.create!(user: users(:one), body: "question test")
    a = ListingAnswer.new(listing_question: q, user: users(:two))
    refute a.valid?
    assert_includes a.errors[:body], "doit être rempli(e)"
  end

  test "body length capped at BODY_MAX_LENGTH" do
    q = listings(:two).listing_questions.create!(user: users(:one), body: "question test")
    a = ListingAnswer.new(
      listing_question: q,
      user: users(:two),
      body: "x" * (ListingAnswer::BODY_MAX_LENGTH + 1)
    )
    refute a.valid?
    assert a.errors[:body].any?
  end

  # ---------- Owner-only contract ----------
  test "valid when the answerer is the listing owner" do
    q = listings(:one).listing_questions.create!(user: users(:two), body: "vraie question")
    a = ListingAnswer.new(
      listing_question: q,
      user: users(:one), # listings(:one).user
      body: "réponse du vendeur"
    )
    assert a.valid?
  end

  test "invalid when the answerer is NOT the listing owner" do
    q = listings(:one).listing_questions.create!(user: users(:two), body: "autre question")
    a = ListingAnswer.new(
      listing_question: q,
      user: users(:three), # pas le vendeur
      body: "je tente de répondre alors que je ne suis pas le vendeur"
    )
    refute a.valid?
    assert a.errors[:user].any?
  end

  # ---------- Unique index safety (1 answer per question) ----------
  test "question can have only one answer" do
    q = listing_questions(:one) # already has an answer
    second = ListingAnswer.new(
      listing_question: q,
      user: users(:one),
      body: "double réponse"
    )
    # Will either raise on save or fail validation depending on how Rails
    # catches the unique constraint. Either way it must NOT persist.
    assert_raises(ActiveRecord::RecordNotUnique) do
      second.save(validate: false)
    end
  end
end
