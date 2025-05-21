class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  
  has_many_attached :photos
  
  validates :title, :description, :status, presence: true
  
  enum :status, { active: 'active', pending: 'pending', sold: 'sold' }, default: 'active'
  
  before_validation :set_default_status, on: :create
  
  private
  
  def set_default_status
    self.status ||= 'active'
  end
end
