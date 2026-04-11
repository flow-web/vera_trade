class ProvenanceEvent < ApplicationRecord
  VALID_TYPES = %w[purchase service restoration race award exhibition registration].freeze

  belongs_to :listing

  validates :event_year, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 2100 }
  validates :label, presence: true
  validates :event_type, presence: true, inclusion: { in: VALID_TYPES }

  default_scope -> { order(event_year: :asc, position: :asc) }
end
