class WalletTransaction < ApplicationRecord
  belongs_to :wallet
  
  validates :amount_cents, presence: true, numericality: { only_integer: true }
  validates :currency, :transaction_type, :status, presence: true
  
  enum :transaction_type, {
    deposit: 0,    # Adding funds to wallet
    payment: 1,    # Payment for a purchase
    withdraw: 2,   # Withdrawing funds from wallet
    conversion: 3, # Converting between currencies
    refund: 4,     # Refund from a transaction
    fee: 5         # Platform fees
  }
  
  enum :status, {
    pending: 0,    # Transaction initiated but not completed
    confirmed: 1,  # Transaction completed successfully
    failed: 2      # Transaction failed
  }
  
  before_validation :set_defaults
  
  def amount
    amount_cents.to_f / 100
  end
  
  def amount=(value)
    self.amount_cents = (value.to_f * 100).to_i
  end
  
  private
  
  def set_defaults
    self.currency ||= "EUR"
    self.status ||= "pending"
  end
end 