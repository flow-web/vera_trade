class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  has_many_attached :photos

  validates :title, :description, :status, presence: true
  validates :slug, uniqueness: true, allow_nil: true

  enum :status, { active: "active", pending: "pending", sold: "sold" }, default: "active"

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

  def generate_slug
    return if title.blank?
    base = [vehicle&.make, vehicle&.model, vehicle&.year, SecureRandom.hex(3)].compact.join("-")
    self.slug = base.parameterize
  end

  def set_default_status
    self.status ||= "active"
  end
end
