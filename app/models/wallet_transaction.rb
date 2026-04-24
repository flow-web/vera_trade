class WalletTransaction < ApplicationRecord
  belongs_to :wallet

  delegate :user, to: :wallet

  validates :amount_cents, numericality: { other_than: 0 }
  validates :transaction_type, presence: true

  enum :transaction_type, {
    deposit: 0,
    withdrawal: 1,
    purchase: 2,
    sale: 3,
    refund: 4
  }, default: :deposit

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2
  }, default: :pending

  before_create :set_default_notes

  private

  def set_default_notes
    self.notes ||= case transaction_type
    when "deposit"    then "Dépôt de fonds"
    when "withdrawal" then "Retrait de fonds"
    when "purchase"   then "Achat"
    when "sale"       then "Vente"
    when "refund"     then "Remboursement"
    end
  end
end
