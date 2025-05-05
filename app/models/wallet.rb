class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_transactions, dependent: :destroy
  
  validates :balance_cents, presence: true, numericality: { only_integer: true }
  
  def balance
    balance_cents.to_f / 100
  end
  
  def balance=(amount)
    self.balance_cents = (amount.to_f * 100).to_i
  end
  
  def add_funds(amount_cents, currency: "EUR", reference: nil, transaction_type: "deposit")
    transaction do
      self.balance_cents += amount_cents
      save!
      
      wallet_transactions.create!(
        amount_cents: amount_cents,
        currency: currency,
        transaction_type: transaction_type,
        reference: reference,
        status: "confirmed"
      )
    end
  end
  
  def deduct_funds(amount_cents, currency: "EUR", reference: nil, transaction_type: "payment")
    transaction do
      raise InsufficientFundsError if balance_cents < amount_cents
      
      self.balance_cents -= amount_cents
      save!
      
      wallet_transactions.create!(
        amount_cents: -amount_cents,
        currency: currency,
        transaction_type: transaction_type,
        reference: reference,
        status: "confirmed"
      )
    end
  end
  
  class InsufficientFundsError < StandardError; end
end 