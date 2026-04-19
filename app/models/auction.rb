class Auction < ApplicationRecord
  belongs_to :listing
  has_many :bids, dependent: :destroy
  has_many :auction_watchers, dependent: :destroy
  has_many :watchers, through: :auction_watchers, source: :user

  has_one :user, through: :listing

  STATUSES = %w[scheduled active ended sold cancelled].freeze
  ANTI_SNIPE_WINDOW = 2.minutes
  ANTI_SNIPE_EXTENSION = 2.minutes

  validates :starting_price, numericality: { greater_than: 0 }
  validates :reserve_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :duration_days, inclusion: { in: [3, 5, 7, 10, 14] }
  validates :status, inclusion: { in: STATUSES }
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_starts

  scope :active, -> { where(status: "active") }
  scope :ending_soon, -> { active.where(ends_at: ..24.hours.from_now) }

  before_validation :set_ends_at, on: :create

  def scheduled?;  status == "scheduled"; end
  def active?;     status == "active"; end
  def ended?;      status == "ended"; end
  def sold?;       status == "sold"; end
  def cancelled?;  status == "cancelled"; end

  def time_remaining
    return 0 if ended? || sold? || cancelled?
    [(ends_at - Time.current).to_i, 0].max
  end

  def reserve_met?
    return true if reserve_price.nil?
    current_price.present? && current_price >= reserve_price
  end

  def winning_bid
    bids.order(amount: :desc).first
  end

  def winner
    winning_bid&.bidder
  end

  def minimum_next_bid
    if current_price.nil?
      starting_price
    else
      current_price + bid_increment
    end
  end

  def place_bid!(bidder, amount)
    raise "L'enchère n'est pas active" unless active?
    raise "Vous ne pouvez pas enchérir sur votre propre annonce" if bidder.id == listing.user_id
    raise "L'enchère minimum est #{minimum_next_bid} €" if amount < minimum_next_bid

    bid = nil
    with_lock do
      bid = bids.create!(bidder: bidder, amount: amount)
      update!(
        current_price: amount,
        bids_count: bids_count + 1
      )
      extend_if_anti_snipe!
    end
    bid
  end

  def finalize!
    return unless active? && Time.current >= ends_at

    if winning_bid && reserve_met?
      update!(status: "sold")
    else
      update!(status: "ended")
    end
  end

  private

  def set_ends_at
    self.ends_at ||= starts_at + duration_days.days if starts_at.present?
  end

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "doit être après le début") if ends_at <= starts_at
  end

  def bid_increment
    case current_price
    when 0..999        then 50
    when 1000..4999    then 100
    when 5000..24999   then 250
    when 25000..99999  then 500
    else 1000
    end
  end

  def extend_if_anti_snipe!
    return unless ends_at - Time.current < ANTI_SNIPE_WINDOW
    update!(ends_at: ends_at + ANTI_SNIPE_EXTENSION)
  end
end
