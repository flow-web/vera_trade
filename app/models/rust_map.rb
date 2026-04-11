class RustMap < ApplicationRecord
  VALID_VARIANTS = %w[sedan coupe wagon suv hatch convertible motorcycle van pickup].freeze

  belongs_to :listing
  has_many :zones, -> { order(position: :asc) }, class_name: "RustZone", dependent: :destroy

  validates :silhouette_variant, presence: true, inclusion: { in: VALID_VARIANTS }
  validates :transparency_score,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  # Recalcule le score de transparence à partir des zones existantes.
  # ok = 0pt, surface = -5pt, deep = -12pt, perforation = -25pt. Min 0.
  def recompute_score!
    penalty = zones.sum { |z| RustZone::SEVERITY.fetch(z.status, 0) }
    update!(transparency_score: [ 100 - penalty, 0 ].max)
  end
end
