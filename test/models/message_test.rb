require "test_helper"

class MessageTest < ActiveSupport::TestCase
  # Fixture shorthand :
  #   users(:one)   → Alice
  #   users(:two)   → Bob
  #   listings(:one).user → users(:one)

  def valid_message_attributes(overrides = {})
    {
      sender: users(:two),
      recipient: users(:one),
      content: "Bonjour, j'ai une question sur votre annonce."
    }.merge(overrides)
  end

  # ---------- offer_cents validation ----------

  test "offer_cents is optional" do
    m = Message.new(valid_message_attributes)
    assert m.valid?
  end

  test "offer_cents must be a positive integer" do
    m = Message.new(valid_message_attributes(offer_cents: -100))
    refute m.valid?
    assert m.errors[:offer_cents].any?
  end

  test "offer_cents must not exceed OFFER_MAX_CENTS" do
    m = Message.new(valid_message_attributes(offer_cents: Message::OFFER_MAX_CENTS + 1))
    refute m.valid?
    assert m.errors[:offer_cents].any?
  end

  test "offer_cents equal to zero is rejected" do
    m = Message.new(valid_message_attributes(offer_cents: 0))
    refute m.valid?
  end

  # ---------- helpers ----------

  test "offer? returns true when offer_cents is present" do
    m = Message.new(valid_message_attributes(offer_cents: 15_000_00))
    assert m.offer?
  end

  test "offer? returns false when offer_cents is nil" do
    m = Message.new(valid_message_attributes)
    refute m.offer?
  end

  test "offer_euros returns the amount in euros as a float" do
    m = Message.new(valid_message_attributes(offer_cents: 15_250_00))
    assert_in_delta 15_250.0, m.offer_euros, 0.001
  end

  test "offer_euros returns nil when no offer" do
    m = Message.new(valid_message_attributes)
    assert_nil m.offer_euros
  end

  # ---------- with_offer scope ----------

  test "with_offer scope returns only messages carrying an offer" do
    convo = Conversation.find_or_create_for(listing: listings(:one), buyer: users(:two))
    plain = convo.messages.create!(
      sender: users(:two), recipient: users(:one),
      content: "Bonjour"
    )
    with_offer = convo.messages.create!(
      sender: users(:two), recipient: users(:one),
      content: "Je vous propose 15000€", offer_cents: 15_000_00
    )

    assert_includes Message.with_offer, with_offer
    refute_includes Message.with_offer, plain
  end
end
