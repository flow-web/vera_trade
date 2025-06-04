class ServiceRequestResponse < ApplicationRecord
  belongs_to :service_request
  belongs_to :service_provider

  validates :message, presence: true, length: { minimum: 20 }
  validates :proposed_price, presence: true, numericality: { greater_than: 0 }
  validates :estimated_duration, presence: true
  validates :service_request_id, uniqueness: { scope: :service_provider_id }

  scope :recent, -> { order(created_at: :desc) }

  def formatted_price
    "#{proposed_price}€"
  end

  def is_within_budget?
    service_request.budget_min <= proposed_price && proposed_price <= service_request.budget_max
  end
end 