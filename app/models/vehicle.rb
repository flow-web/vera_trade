class Vehicle < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :users, through: :listings
  
  validates :make, :model, :year, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :kilometers, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
