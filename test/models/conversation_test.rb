require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  # Fixture shorthand :
  #   users(:one)   → Alice  (owns listings(:one))
  #   users(:two)   → Bob
  #   users(:three) → Claire
  #   listings(:one).user → users(:one)

  # ---------- Conversation.find_or_create_for ----------

  test "find_or_create_for creates a fresh conversation for a new (listing, buyer)" do
    assert_difference -> { Conversation.count }, +1 do
      convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
      assert_equal listings(:one).id, convo.listing_id
      assert_equal users(:three).id,  convo.user_id      # buyer
      assert_equal users(:one).id,    convo.other_user_id # seller (listing.user)
    end
  end

  test "find_or_create_for is idempotent — returns the same conversation on re-call" do
    first  = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    second = nil
    assert_no_difference -> { Conversation.count } do
      second = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    end
    assert_equal first.id, second.id
  end

  test "find_or_create_for raises when the buyer is the listing owner" do
    error = assert_raises(ArgumentError) do
      Conversation.find_or_create_for(listing: listings(:one), buyer: users(:one))
    end
    assert_match(/owner/i, error.message)
  end

  test "separate buyers on the same listing get separate conversations" do
    claire_convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    bob_convo    = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:two))
    refute_equal claire_convo.id, bob_convo.id
  end

  test "same buyer on two different listings gets two conversations" do
    c1 = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    c2 = Conversation.find_or_create_for(listing: listings(:two), buyer: users(:three))
    refute_equal c1.id, c2.id
  end

  # ---------- aliases ----------

  test "buyer and seller aliases read from user_id and other_user_id" do
    convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    assert_equal users(:three), convo.buyer
    assert_equal users(:one),   convo.seller
  end

  # ---------- unread_count_for(viewer) ----------

  test "unread_count_for returns the number of unread messages addressed to the viewer" do
    convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:three))
    # 2 messages: one from buyer → seller (unread for seller), one from
    # seller → buyer (already read).
    convo.messages.create!(sender: users(:three), recipient: users(:one), content: "Bonjour", read: false)
    convo.messages.create!(sender: users(:one),   recipient: users(:three), content: "Merci",  read: true)

    assert_equal 1, convo.unread_count_for(users(:one))   # seller has 1 unread
    assert_equal 0, convo.unread_count_for(users(:three)) # buyer has 0 unread
  end
end
