require "test_helper"

class EscrowTest < ActiveSupport::TestCase
  test "valid escrow with all required fields" do
    escrow = Escrow.new(
      listing: listings(:one),
      buyer: users(:two),
      seller: users(:one),
      amount: 25000,
      status: "pending"
    )
    assert escrow.valid?
  end

  test "buyer and seller must differ" do
    escrow = Escrow.new(
      listing: listings(:one),
      buyer: users(:one),
      seller: users(:one),
      amount: 25000,
      status: "pending"
    )
    assert_not escrow.valid?
    assert_includes escrow.errors[:buyer], "ne peut pas être le vendeur"
  end

  test "amount must be positive" do
    escrow = escrows(:pending_escrow)
    escrow.amount = -100
    assert_not escrow.valid?
  end

  test "status must be valid" do
    escrow = escrows(:pending_escrow)
    assert_raises(ArgumentError) { escrow.status = "invalid" } rescue nil
    escrow.status = "invalid"
    assert_not escrow.valid?
  end

  test "can_release? only when paid or held" do
    escrow = escrows(:paid_escrow)
    assert escrow.can_release?

    escrow.status = "held"
    assert escrow.can_release?

    escrow.status = "pending"
    assert_not escrow.can_release?
  end

  test "can_dispute? only when paid or held" do
    escrow = escrows(:paid_escrow)
    assert escrow.can_dispute?

    escrow.status = "released"
    assert_not escrow.can_dispute?
  end

  test "can_refund? when paid, held, or disputed" do
    escrow = escrows(:paid_escrow)
    assert escrow.can_refund?

    escrow.status = "disputed"
    assert escrow.can_refund?

    escrow.status = "released"
    assert_not escrow.can_refund?
  end

  test "active scope returns only active escrows" do
    active = Escrow.active
    active.each do |e|
      assert_includes %w[paid held disputed], e.status
    end
  end

  test "for_user returns escrows where user is buyer or seller" do
    alice = users(:one)
    escrows = Escrow.for_user(alice)
    escrows.each do |e|
      assert(e.buyer_id == alice.id || e.seller_id == alice.id)
    end
  end
end
