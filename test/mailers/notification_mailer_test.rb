require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  # ---- new_question ----

  test "new_question is sent to the listing owner" do
    question = listing_questions(:one)
    mail = NotificationMailer.new_question(question)

    assert_equal [ question.listing.user.email ], mail.to
    assert_includes mail.subject, question.listing.title
    assert_includes mail.html_part.body.decoded, "Nouvelle question"
    assert_includes mail.text_part.body.decoded, "question"
  end

  test "new_question is enqueued when a question is created" do
    listing = listings(:two)
    buyer   = users(:one)

    assert_enqueued_emails(1) do
      ListingQuestion.create!(
        listing: listing,
        user: buyer,
        body: "Le carnet est-il complet ?"
      )
    end
  end

  # ---- new_answer ----

  test "new_answer is sent to the question asker" do
    answer = listing_answers(:one)
    mail = NotificationMailer.new_answer(answer)

    asker = answer.listing_question.user
    assert_equal [ asker.email ], mail.to
    assert_includes mail.subject, answer.listing_question.listing.title
    assert_includes mail.html_part.body.decoded, "Le vendeur a"
  end

  test "new_answer is enqueued when an answer is created" do
    question = listing_questions(:one)
    seller   = question.listing.user

    fresh_question = ListingQuestion.create!(
      listing: question.listing,
      user: users(:two),
      body: "Le CT est-il valide ?"
    )

    assert_enqueued_emails(1) do
      ListingAnswer.create!(
        listing_question: fresh_question,
        user: seller,
        body: "Oui, CT OK."
      )
    end
  end

  # ---- new_bid ----

  test "new_bid is sent to the listing seller" do
    auction = auctions(:active_auction)
    bidder  = users(:two)
    bid     = Bid.new(auction: auction, bidder: bidder, amount: 30_000)
    bid.save!(validate: false)

    mail = NotificationMailer.new_bid(bid)

    assert_equal [ auction.listing.user.email ], mail.to
    assert_includes mail.subject, "30"
  end

  # ---- outbid ----

  test "outbid is sent to the previous high bidder" do
    auction = auctions(:active_auction)
    bidder  = users(:three)
    outbid_user = users(:two)
    bid = Bid.new(auction: auction, bidder: bidder, amount: 35_000)
    bid.save!(validate: false)

    mail = NotificationMailer.outbid(bid, outbid_user)

    assert_equal [ outbid_user.email ], mail.to
    assert_includes mail.subject, auction.listing.title
  end

  # ---- auction_ending_soon ----

  test "auction_ending_soon is sent to the watcher" do
    auction = auctions(:active_auction)
    watcher = users(:two)
    mail = NotificationMailer.auction_ending_soon(auction, watcher)

    assert_equal [ watcher.email ], mail.to
    assert_includes mail.subject, auction.listing.title
  end
end
