class Escrow < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }
  validates :status, presence: true
  validate :buyer_and_seller_differ

  STATUSES = %w[pending paid held released disputed refunded cancelled].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: %w[paid held disputed]) }
  scope :for_user, ->(user) { where(buyer: user).or(where(seller: user)) }

  def pending?;   status == "pending"; end
  def paid?;      status == "paid"; end
  def held?;      status == "held"; end
  def released?;  status == "released"; end
  def disputed?;  status == "disputed"; end
  def refunded?;  status == "refunded"; end
  def cancelled?; status == "cancelled"; end

  def can_release?
    held? || paid?
  end

  def can_dispute?
    paid? || held?
  end

  def can_refund?
    paid? || held? || disputed?
  end

  private

  def buyer_and_seller_differ
    errors.add(:buyer, "ne peut pas être le vendeur") if buyer_id == seller_id
  end
end
