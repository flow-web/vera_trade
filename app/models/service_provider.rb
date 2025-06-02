class ServiceProvider < ApplicationRecord
  belongs_to :user
  has_many :service_categories, dependent: :destroy
  has_many :categories, through: :service_categories
  has_many :service_offers, dependent: :destroy
  has_many :service_requests, dependent: :destroy
  has_many :service_reviews, dependent: :destroy
  has_many :service_bookings, dependent: :destroy
  has_many :service_portfolios, dependent: :destroy
  has_many_attached :portfolio_images
  has_many_attached :certificates
  has_one_attached :profile_image
  has_one_attached :cv_document

  enum :status, { pending: 0, active: 1, suspended: 2, rejected: 3 }
  enum :verification_status, { unverified: 0, verified: 1, premium: 2 }

  validates :business_name, presence: true
  validates :description, presence: true, length: { minimum: 50 }
  validates :phone, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true

  scope :active, -> { where(status: :active) }
  scope :verified, -> { where(verification_status: [:verified, :premium]) }
  scope :premium, -> { where(verification_status: :premium) }
  scope :by_category, ->(category) { joins(:categories).where(categories: { id: category }) }
  scope :near_location, ->(latitude, longitude, radius = 50) {
    where("ST_DWithin(ST_Point(longitude, latitude)::geography, ST_Point(?, ?)::geography, ?)", 
          longitude, latitude, radius * 1000)
  }

  def average_rating
    service_reviews.average(:rating) || 0
  end

  def total_reviews
    service_reviews.count
  end

  def completed_services
    service_bookings.completed.count
  end

  def response_time
    # Calcul du temps de réponse moyen en heures
    conversations = user.all_conversations.joins(:messages).where(messages: { sender_id: user.id })
    return 0 if conversations.empty?
    
    # Logique de calcul du temps de réponse moyen
    24 # Placeholder - à implémenter
  end

  def is_available?
    status == 'active' && !suspended_until&.future?
  end

  def specialties_list
    specialties&.split(',')&.map(&:strip) || []
  end

  def full_address
    "#{address}, #{postal_code} #{city}"
  end

  def badge_types
    badges = []
    badges << 'verified' if verified? || premium?
    badges << 'premium' if premium?
    badges << 'top_rated' if average_rating >= 4.8 && total_reviews >= 10
    badges << 'quick_response' if response_time <= 2
    badges << 'experienced' if completed_services >= 50
    badges
  end
end 