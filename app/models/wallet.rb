class Wallet < ApplicationRecord
  class InsufficientFundsError < StandardError; end

  belongs_to :user
  has_many :wallet_transactions, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def credit(amount)
    with_lock do
      update!(balance: balance + amount)
    end
  end

  def debit(amount)
    with_lock do
      raise InsufficientFundsError, "Solde insuffisant (#{balance} < #{amount})" if balance < amount
      update!(balance: balance - amount)
    end
  end
end
