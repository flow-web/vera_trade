class ServiceBooking < ApplicationRecord
  belongs_to :service_provider
  belongs_to :user
  belongs_to :service_offer, optional: true
  belongs_to :listing, optional: true
  has_one :service_review, dependent: :destroy
  has_many_attached :documents

  enum :status, { 
    pending: 0, 
    accepted: 1, 
    in_progress: 2, 
    completed: 3, 
    cancelled: 4, 
    disputed: 5 
  }

  enum :payment_status, { 
    unpaid: 0, 
    paid: 1, 
    refunded: 2, 
    disputed: 3 
  }

  validates :description, presence: true
  validates :proposed_date, presence: true
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_provider, ->(provider) { where(service_provider: provider) }
  scope :for_user, ->(user) { where(user: user) }
  scope :completed, -> { where(status: :completed) }
  scope :active, -> { where(status: [:pending, :accepted, :in_progress]) }

  def can_be_reviewed?
    completed? && service_review.nil?
  end

  def is_past_due?
    proposed_date < Date.current && !completed?
  end

  def days_until_service
    return 0 if proposed_date <= Date.current
    (proposed_date - Date.current).to_i
  end

  def formatted_amount
    "#{total_amount}€"
  end

  def related_listing_title
    listing&.title || "Service général"
  end
end 