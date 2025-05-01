class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  
  validates :title, :description, :status, presence: true
  
  enum status: { active: 'active', pending: 'pending', sold: 'sold' }
  
  before_validation :set_default_status, on: :create
  
  private
  
  def set_default_status
    self.status ||= 'active'
  end
end
