class ServiceRequest < ApplicationRecord
  belongs_to :listing
  belongs_to :user
  belongs_to :category
  has_many :service_request_responses, dependent: :destroy
  has_many :service_providers, through: :service_request_responses

  enum :status, { open: 0, closed: 1, completed: 2 }
  enum :urgency, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 20 }
  validates :budget_min, presence: true, numericality: { greater_than: 0 }
  validates :budget_max, presence: true, numericality: { greater_than: :budget_min }
  validates :deadline, presence: true

  scope :open, -> { where(status: :open) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :in_budget_range, ->(min, max) {
    where("budget_min <= ? AND budget_max >= ?", max, min) if min && max
  }

  def budget_range
    "#{budget_min}€ - #{budget_max}€"
  end

  def days_until_deadline
    return 0 if deadline <= Date.current
    (deadline - Date.current).to_i
  end

  def response_count
    service_request_responses.count
  end

  def is_expired?
    deadline < Date.current
  end
end 