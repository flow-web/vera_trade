class WalletTransaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user

  validates :amount, numericality: { other_than: 0 }
  validates :transaction_type, presence: true

  enum :transaction_type, {
    deposit: "deposit",
    withdrawal: "withdrawal",
    purchase: "purchase",
    sale: "sale",
    refund: "refund"
  }, default: "deposit"

  before_create :set_description

  private

  def set_description
    self.description ||= case transaction_type
    when "deposit"
      "Dépôt de fonds"
    when "withdrawal"
      "Retrait de fonds"
    when "purchase"
      "Achat"
    when "sale"
      "Vente"
    when "refund"
      "Remboursement"
    end
  end
end
