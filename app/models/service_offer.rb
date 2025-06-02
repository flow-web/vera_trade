class ServiceOffer < ApplicationRecord
  belongs_to :service_provider
  belongs_to :category
  has_many :service_bookings, dependent: :destroy
  has_many_attached :images

  enum :pricing_type, { fixed: 0, hourly: 1, quote_only: 2, negotiable: 3 }
  enum :status, { active: 0, inactive: 1, draft: 2 }

  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 20 }
  validates :pricing_type, presence: true
  validates :base_price, presence: true, if: -> { fixed? || hourly? }
  validates :duration_estimate, presence: true, if: -> { hourly? }

  scope :active, -> { where(status: :active) }
  scope :by_category, ->(category) { where(category: category) }
  scope :in_price_range, ->(min_price, max_price) {
    where(base_price: min_price..max_price) if min_price && max_price
  }

  def formatted_price
    case pricing_type
    when 'fixed'
      "#{base_price.to_i}€"
    when 'hourly'
      "#{base_price.to_i}€/h"
    when 'quote_only'
      'Sur devis'
    when 'negotiable'
      'À négocier'
    end
  end

  def average_rating
    service_bookings.joins(:service_review).average(:rating) || 0
  end

  def total_bookings
    service_bookings.count
  end
end 