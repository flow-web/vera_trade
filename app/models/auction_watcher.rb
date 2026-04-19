class AuctionWatcher < ApplicationRecord
  belongs_to :auction, counter_cache: :watchers_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :auction_id }
end
