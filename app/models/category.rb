class Category < ApplicationRecord
  has_many :service_categories, dependent: :destroy
  has_many :service_providers, through: :service_categories
  has_many :service_offers, dependent: :destroy
  has_many :service_requests, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :for_services, -> { joins(:service_providers).distinct }
  scope :popular, -> { 
    joins(:service_providers)
      .select('categories.*, COUNT(service_providers.id) as providers_count')
      .group('categories.id')
      .order('providers_count DESC') 
  }

  def service_providers_count
    service_providers.active.count
  end

  def active_requests_count
    service_requests.open.count
  end
end
