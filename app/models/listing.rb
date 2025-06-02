class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  
  has_many_attached :photos
  has_many_attached :videos
  
  validates :title, :description, :status, presence: true
  
  enum :status, { active: 'active', pending: 'pending', sold: 'sold' }, default: 'active'
  
  before_validation :set_default_status, on: :create
  
  # Validation for video files
  validate :acceptable_videos
  
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
