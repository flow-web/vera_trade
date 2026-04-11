class RustZone < ApplicationRecord
  VALID_STATUSES = %w[ok surface deep perforation].freeze
  SEVERITY = { "ok" => 0, "surface" => 5, "deep" => 12, "perforation" => 25 }.freeze

  belongs_to :rust_map

  validates :x_pct, :y_pct, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
