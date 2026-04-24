class EscrowService
  class EscrowError < StandardError; end

  def initialize(escrow)
    @escrow = escrow
  end

  def mark_paid!(stripe_payment_intent_id: nil)
    raise EscrowError, "Escrow is not pending" unless @escrow.pending?

    ActiveRecord::Base.transaction do
      @escrow.update!(
        status: "paid",
        paid_at: Time.current,
        stripe_payment_intent_id: stripe_payment_intent_id
      )
      record_transaction!(:purchase, @escrow.buyer, "Paiement séquestre — #{@escrow.listing.title}")
    end
  end

  def hold!
    raise EscrowError, "Escrow is not paid" unless @escrow.paid?

    @escrow.update!(status: "held")
  end

  def release!
    raise EscrowError, "Cannot release escrow" unless @escrow.can_release?

    ActiveRecord::Base.transaction do
      @escrow.update!(
        status: "released",
        released_at: Time.current
      )
      credit_seller!
      record_transaction!(:sale, @escrow.seller, "Vente confirmée — #{@escrow.listing.title}")
    end
  end

  def dispute!(notes: nil)
    raise EscrowError, "Cannot dispute escrow" unless @escrow.can_dispute?

    @escrow.update!(
      status: "disputed",
      disputed_at: Time.current,
      notes: notes
    )
  end

  def refund!
    raise EscrowError, "Cannot refund escrow" unless @escrow.can_refund?

    ActiveRecord::Base.transaction do
      @escrow.update!(
        status: "refunded",
        refunded_at: Time.current
      )
      record_transaction!(:refund, @escrow.buyer, "Remboursement — #{@escrow.listing.title}")
    end
  end

  def cancel!
    raise EscrowError, "Only pending escrows can be cancelled" unless @escrow.pending?

    @escrow.update!(status: "cancelled")
  end

  private

  def credit_seller!
    wallet = @escrow.seller.wallet
    wallet.credit(@escrow.amount)
  end

  def record_transaction!(type, user, note)
    wallet = user.wallet
    wallet.wallet_transactions.create!(
      amount_cents: (@escrow.amount * 100).to_i,
      transaction_type: type,
      status: :completed,
      reference: "escrow_#{@escrow.id}",
      notes: note
    )
  end
end
