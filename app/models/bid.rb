class Bid < ApplicationRecord
  belongs_to :auction, counter_cache: :bids_count
  belongs_to :bidder, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }

  scope :ordered, -> { order(amount: :desc, created_at: :desc) }
end
