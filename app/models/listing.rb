class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  
  has_many_attached :photos
  has_many_attached :videos
  
  # Relations pour les services
  has_many :service_requests, dependent: :destroy
  has_many :service_bookings, dependent: :destroy
  
  validates :title, :description, :status, presence: true
  
  enum :status, { active: 'active', pending: 'pending', sold: 'sold' }, default: 'active'
  
  before_validation :set_default_status, on: :create
  
  # Validation for video files
  validate :acceptable_videos
  
  # Méthodes pour les services
  def has_service_requests?
    service_requests.open.any?
  end

  def active_service_requests_count
    service_requests.open.count
  end

  def needs_services?
    # Logique pour déterminer si l'annonce nécessite des services
    # Peut être basée sur des mots-clés, catégories, etc.
    description.downcase.match?(/réparation|entretien|révision|carrosserie|mécanique|transport/)
  end
  
  private
  
  def set_default_status
    self.status ||= 'active'
  end
  
  def acceptable_videos
    return unless videos.attached?
    
    videos.each do |video|
      unless video.blob.content_type.in?(['video/mp4', 'video/mpeg', 'video/quicktime', 'video/webm'])
        errors.add(:videos, 'must be a MP4, MPEG, MOV, or WebM file')
      end
      
      if video.blob.byte_size > 50.megabytes
        errors.add(:videos, 'should be less than 50MB')
      end
    end
  end
end
