class ServiceCategory < ApplicationRecord
  belongs_to :service_provider
  belongs_to :category

  validates :service_provider_id, uniqueness: { scope: :category_id }
end 