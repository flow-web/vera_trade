class ServiceReview < ApplicationRecord
  belongs_to :service_provider
  belongs_to :user
  belongs_to :service_booking, optional: true
  has_many_attached :images

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :title, presence: true
  validates :comment, presence: true, length: { minimum: 10 }
  validates :communication_rating, inclusion: { in: 1..5 }
  validates :quality_rating, inclusion: { in: 1..5 }
  validates :value_rating, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :service_provider_id, message: "Vous avez déjà évalué ce prestataire" }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :verified, -> { joins(:service_booking).where.not(service_bookings: { id: nil }) }

  after_create :update_provider_rating
  after_update :update_provider_rating
  after_destroy :update_provider_rating

  def verified?
    service_booking.present?
  end

  def helpful_votes
    # À implémenter si système de vote sur les avis
    0
  end

  def overall_rating
    (communication_rating + quality_rating + value_rating) / 3.0
  end

  private

  def update_provider_rating
    service_provider.update(
      average_rating: service_provider.service_reviews.average(:rating),
      total_reviews: service_provider.service_reviews.count
    )
  end
end 