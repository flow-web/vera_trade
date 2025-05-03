class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  
  has_many :media_folders, dependent: :destroy
  has_many :media_items, dependent: :destroy
  
  has_many_attached :photos
  
  validates :title, :description, :status, presence: true
  
  enum :status, { draft: 0, active: 1, sold: 2, archived: 3 }
  
  scope :active, -> { where(status: :active) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  
  before_validation :set_default_status, on: :create
  
  def public_photos
    media_items.public_items.where(media_folder: nil)
  end
  
  def main_photo
    media_items.public_items.where(media_folder: nil).first
  end
  
  private
  
  def set_default_status
    self.status ||= 'active'
  end
end
