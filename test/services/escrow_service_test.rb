require "test_helper"

class EscrowServiceTest < ActiveSupport::TestCase
  setup do
    @pending = escrows(:pending_escrow)
    @paid = escrows(:paid_escrow)
  end

  test "mark_paid! transitions pending to paid" do
    service = EscrowService.new(@pending)
    service.mark_paid!(stripe_payment_intent_id: "pi_test_123")

    @pending.reload
    assert_equal "paid", @pending.status
    assert_not_nil @pending.paid_at
    assert_equal "pi_test_123", @pending.stripe_payment_intent_id
  end

  test "mark_paid! creates a wallet transaction" do
    service = EscrowService.new(@pending)
    buyer_wallet = @pending.buyer.wallet

    assert_difference -> { buyer_wallet.wallet_transactions.count }, 1 do
      service.mark_paid!
    end

    tx = buyer_wallet.wallet_transactions.last
    assert_equal "purchase", tx.transaction_type
    assert_equal (@pending.amount * 100).to_i, tx.amount_cents
  end

  test "mark_paid! raises on non-pending escrow" do
    service = EscrowService.new(@paid)
    assert_raises(EscrowService::EscrowError) { service.mark_paid! }
  end

  test "release! transitions paid to released and credits seller" do
    service = EscrowService.new(@paid)
    seller_wallet = @paid.seller.wallet
    initial_balance = seller_wallet.balance

    service.release!

    @paid.reload
    assert_equal "released", @paid.status
    assert_not_nil @paid.released_at

    seller_wallet.reload
    assert_equal initial_balance + @paid.amount, seller_wallet.balance
  end

  test "release! creates a sale transaction for seller" do
    service = EscrowService.new(@paid)
    seller_wallet = @paid.seller.wallet

    assert_difference -> { seller_wallet.wallet_transactions.count }, 1 do
      service.release!
    end

    tx = seller_wallet.wallet_transactions.last
    assert_equal "sale", tx.transaction_type
  end

  test "dispute! transitions paid to disputed" do
    service = EscrowService.new(@paid)
    service.dispute!(notes: "Véhicule ne correspond pas à l'annonce")

    @paid.reload
    assert_equal "disputed", @paid.status
    assert_not_nil @paid.disputed_at
    assert_equal "Véhicule ne correspond pas à l'annonce", @paid.notes
  end

  test "refund! transitions disputed to refunded" do
    @paid.update!(status: "disputed", disputed_at: Time.current)
    service = EscrowService.new(@paid)

    service.refund!

    @paid.reload
    assert_equal "refunded", @paid.status
    assert_not_nil @paid.refunded_at
  end

  test "cancel! only works on pending escrows" do
    service = EscrowService.new(@pending)
    service.cancel!

    @pending.reload
    assert_equal "cancelled", @pending.status
  end

  test "cancel! raises on paid escrow" do
    service = EscrowService.new(@paid)
    assert_raises(EscrowService::EscrowError) { service.cancel! }
  end
end
