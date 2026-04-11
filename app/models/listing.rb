class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  has_many_attached :photos

  # M8 — Wizard dépôt associations
  has_one :rust_map, dependent: :destroy
  has_many :provenance_events, dependent: :destroy
  has_one :originality_score, dependent: :destroy
  has_many :listing_questions, dependent: :destroy

  # Constantes M8 — une seule source de vérité pour le nombre d'étapes.
  WIZARD_STEP_COUNT = 7
  PHOTO_MAX_COUNT = 10
  PHOTO_MAX_BYTES = 5.megabytes
  PHOTO_ALLOWED_TYPES = %w[image/jpeg image/jpg image/webp image/png].freeze
  VEHICLE_STUB_STRING = "À définir".freeze

  validates :title, :description, :status, presence: true
  validates :slug, uniqueness: true, allow_nil: true

  # M8 — Photos : content_type + size + count enforcés server-side.
  validate :photos_content_type_and_size
  validate :photos_count_within_limit

  enum :status, { active: "active", pending: "pending", sold: "sold", draft: "draft" }, default: "draft"

  # M8 — Helpers wizard
  def wizard_in_progress?
    draft? && wizard_step < WIZARD_STEP_COUNT
  end

  # M8 — publishable? exige une vraie saisie utilisateur (pas les stubs du new).
  def publishable?
    return false unless draft? && vehicle.present? && photos.any? && rust_map.present?

    # Le draft_data doit contenir de vraies valeurs véhicule (pas les placeholders
    # "À définir" posés par ListingWizardsController#new).
    v = draft_data.is_a?(Hash) ? draft_data["vehicle"].to_h : {}
    required_keys = %w[make model year price]
    required_keys.all? { |k| v[k].present? && v[k].to_s.strip != VEHICLE_STUB_STRING }
  end

  before_validation :generate_slug, on: :create
  before_validation :set_default_status, on: :create

  # SEO-friendly URLs
  def to_param
    slug || id.to_s
  end

  # Full-text search scope
  scope :search_query, ->(query) {
    return all if query.blank?
    joins(:vehicle).where(
      "listings.title ILIKE :q OR vehicles.make ILIKE :q OR vehicles.model ILIKE :q OR vehicles.location ILIKE :q",
      q: "%#{sanitize_sql_like(query)}%"
    )
  }

  # Filter scopes
  scope :by_make, ->(make) { joins(:vehicle).where(vehicles: { make: make }) if make.present? }
  scope :by_fuel, ->(fuel) { joins(:vehicle).where(vehicles: { fuel_type: fuel }) if fuel.present? }
  scope :by_transmission, ->(t) { joins(:vehicle).where(vehicles: { transmission: t }) if t.present? }
  scope :by_price_range, ->(min, max) {
    scope = joins(:vehicle)
    scope = scope.where("vehicles.price >= ?", min) if min.present?
    scope = scope.where("vehicles.price <= ?", max) if max.present?
    scope
  }
  scope :by_year_range, ->(min, max) {
    scope = joins(:vehicle)
    scope = scope.where("vehicles.year >= ?", min) if min.present?
    scope = scope.where("vehicles.year <= ?", max) if max.present?
    scope
  }
  scope :by_km_max, ->(km) { joins(:vehicle).where("vehicles.kilometers <= ?", km) if km.present? }

  scope :sorted_by, ->(sort) {
    case sort
    when "price_asc" then joins(:vehicle).order("vehicles.price ASC")
    when "price_desc" then joins(:vehicle).order("vehicles.price DESC")
    when "year_desc" then joins(:vehicle).order("vehicles.year DESC")
    when "year_asc" then joins(:vehicle).order("vehicles.year ASC")
    when "km_asc" then joins(:vehicle).order("vehicles.kilometers ASC")
    else order(created_at: :desc)
    end
  }

  private

  def photos_content_type_and_size
    return unless photos.attached?

    photos.each do |photo|
      unless PHOTO_ALLOWED_TYPES.include?(photo.content_type)
        errors.add(:photos, "doit être au format JPG, PNG ou WEBP (reçu : #{photo.content_type})")
      end
      if photo.byte_size > PHOTO_MAX_BYTES
        errors.add(:photos, "doit peser moins de #{PHOTO_MAX_BYTES / 1.megabyte} Mo")
      end
    end
  end

  def photos_count_within_limit
    return unless photos.attached?
    if photos.count > PHOTO_MAX_COUNT
      errors.add(:photos, "ne peut pas dépasser #{PHOTO_MAX_COUNT} images")
    end
  end

  def generate_slug
    return if title.blank?
    base = [ vehicle&.make, vehicle&.model, vehicle&.year, SecureRandom.hex(3) ].compact.join("-")
    self.slug = base.parameterize
  end

  def set_default_status
    self.status ||= "active"
  end
end
