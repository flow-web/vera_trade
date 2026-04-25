require "test_helper"

class WalletTest < ActiveSupport::TestCase
  # Fixture shorthand:
  #   wallets(:one) -> user :one, balance 5000
  #   wallets(:two) -> user :two, balance 3000
  #   wallets(:three) -> user :three, balance 0

  # ---------- validations ----------

  test "balance cannot be negative" do
    wallet = wallets(:one)
    wallet.balance = -1
    assert_not wallet.valid?
  end

  test "balance of zero is valid" do
    wallet = wallets(:three)
    assert wallet.valid?
  end

  # ---------- credit ----------

  test "credit increases balance" do
    wallet = wallets(:one)
    original = wallet.balance
    wallet.credit(500)
    assert_equal original + 500, wallet.reload.balance
  end

  # ---------- debit ----------

  test "debit decreases balance" do
    wallet = wallets(:one)
    original = wallet.balance
    wallet.debit(1000)
    assert_equal original - 1000, wallet.reload.balance
  end

  test "debit raises InsufficientFundsError when balance too low" do
    wallet = wallets(:three) # balance 0
    assert_raises(Wallet::InsufficientFundsError) do
      wallet.debit(100)
    end
  end

  # ---------- associations ----------

  test "wallet belongs to user" do
    assert_equal users(:one), wallets(:one).user
  end

  test "wallet has many wallet_transactions" do
    assert_respond_to wallets(:one), :wallet_transactions
  end
end


class WalletTransactionTest < ActiveSupport::TestCase
  # Fixture shorthand:
  #   wallet_transactions(:deposit_one) -> wallet :one, 500000 cents deposit
  #   wallet_transactions(:purchase_one) -> wallet :two, -180000 cents purchase

  # ---------- validations ----------

  test "amount_cents cannot be zero" do
    wt = WalletTransaction.new(wallet: wallets(:one), amount_cents: 0, transaction_type: :deposit)
    assert_not wt.valid?
    assert wt.errors[:amount_cents].any?
  end

  test "transaction_type is required" do
    wt = WalletTransaction.new(wallet: wallets(:one), amount_cents: 100)
    # transaction_type has a default of :deposit, so removing it manually
    wt.transaction_type = nil
    assert_not wt.valid?
  end

  test "valid deposit transaction" do
    wt = WalletTransaction.new(wallet: wallets(:one), amount_cents: 10000, transaction_type: :deposit)
    assert wt.valid?
  end

  # ---------- enums ----------

  test "transaction_type enum values" do
    assert_equal({ "deposit" => 0, "withdrawal" => 1, "purchase" => 2, "sale" => 3, "refund" => 4 },
                 WalletTransaction.transaction_types)
  end

  test "status enum values" do
    assert_equal({ "pending" => 0, "completed" => 1, "failed" => 2 }, WalletTransaction.statuses)
  end

  # ---------- default notes callback ----------

  test "sets default notes on create" do
    wt = WalletTransaction.create!(wallet: wallets(:one), amount_cents: 5000, transaction_type: :withdrawal)
    assert_equal "Retrait de fonds", wt.notes
  end

  test "does not overwrite explicit notes" do
    wt = WalletTransaction.create!(wallet: wallets(:one), amount_cents: 5000, transaction_type: :deposit, notes: "Custom note")
    assert_equal "Custom note", wt.notes
  end

  # ---------- delegate ----------

  test "user delegates to wallet" do
    wt = wallet_transactions(:deposit_one)
    assert_equal wallets(:one).user, wt.user
  end
end
