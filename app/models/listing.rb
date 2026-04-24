class Listing < ApplicationRecord
  include PgSearch::Model

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
  has_many :escrows, dependent: :restrict_with_error
  has_one :auction, dependent: :destroy

  # Constantes M8 — une seule source de vérité pour le nombre d'étapes.
  WIZARD_STEP_COUNT = 7
  PHOTO_MAX_COUNT = 10
  PHOTO_MAX_BYTES = 5.megabytes
  PHOTO_ALLOWED_TYPES = %w[image/jpeg image/jpg image/webp image/png].freeze
  VEHICLE_STUB_STRING = "À définir".freeze

  # PR1 catalogue-search — segments collector basés sur l'année véhicule.
  # Le filtre UI traduit un segment en range d'année appliqué sur vehicles.year.
  SEGMENT_YEAR_RANGES = {
    "classique"  => ..1984,
    "youngtimer" => 1985..1999,
    "moderne"    => 2000..2015,
    "recent"     => 2016..
  }.freeze

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

  # PR1 catalogue-search — full-text search with weighted rank.
  #
  # Pondération :
  #   - A (highest) : listings.title
  #   - B           : vehicles.make, vehicles.model
  #   - C           : listings.description, vehicles.location
  #
  # `any_word: true` pour matcher "BMW E30" sur des annonces qui contiennent
  # au moins un des deux termes — le ranking remonte naturellement en tête
  # celles qui matchent les deux. `prefix: true` autorise les recherches
  # partielles ("bmw" matche "BMW M3").
  pg_search_scope :search_query,
    against: {
      title: "A",
      description: "C"
    },
    associated_against: {
      vehicle: {
        make: "B",
        model: "B",
        location: "C"
      }
    },
    using: {
      tsearch: {
        prefix: true,
        any_word: true,
        dictionary: "simple"
      }
    }

  # Filter scopes.
  #
  # IMPORTANT : tous les scopes WHERE utilisent la forme singulière
  # `where(vehicle: { ... })` (nom d'association) plutôt que la forme
  # plurielle `where(vehicles: { ... })` (nom de table).
  #
  # Pourquoi : quand ces scopes sont chaînés APRÈS `search_query` (pg_search),
  # le gem ajoute une sous-requête `pg_search_documents` et Rails alias la
  # table `vehicles` en `"vehicles" "vehicles_listings"` pour éviter la
  # collision. Une référence en dur au nom de table (plural form OR raw SQL
  # `"vehicles.year"` OR même `merge(Vehicle.where(...))`) génère alors un
  # SQL qui casse avec `invalid reference to FROM-clause entry`.
  #
  # La forme singulière `where(vehicle: { ... })` passe par l'association
  # reflection de Rails, qui connaît l'alias courant et le résout à la
  # génération du SQL. C'est la seule forme alias-safe dans toutes les
  # chaînes — y compris post-pg_search.
  scope :by_make, ->(make) {
    joins(:vehicle).where(vehicle: { make: make }) if make.present?
  }
  scope :by_segment, ->(segment) {
    return all if segment.blank?
    range = SEGMENT_YEAR_RANGES[segment.to_s.downcase]
    return none unless range
    joins(:vehicle).where(vehicle: { year: range })
  }
  scope :by_fuel, ->(fuel) {
    joins(:vehicle).where(vehicle: { fuel_type: fuel }) if fuel.present?
  }
  scope :by_transmission, ->(t) {
    joins(:vehicle).where(vehicle: { transmission: t }) if t.present?
  }
  scope :by_price_range, ->(min, max) {
    result = joins(:vehicle)
    result = result.where(vehicle: { price: min.to_f.. }) if min.present?
    result = result.where(vehicle: { price: ..max.to_f }) if max.present?
    result
  }
  scope :by_year_range, ->(min, max) {
    result = joins(:vehicle)
    result = result.where(vehicle: { year: min.to_i.. }) if min.present?
    result = result.where(vehicle: { year: ..max.to_i }) if max.present?
    result
  }
  scope :by_km_max, ->(km) {
    joins(:vehicle).where(vehicle: { kilometers: ..km.to_i }) if km.present?
  }

  # sorted_by utilise du SQL brut référençant `vehicles.*`. Rails n'a pas
  # d'équivalent singulier pour `order` sur une association. Ce scope ne
  # doit donc JAMAIS être chaîné après `search_query` — le controller
  # garantit ce contrat en utilisant `sorted_by` uniquement quand aucun
  # query pg_search n'est actif (auquel cas pg_search trie par rank DESC,
  # ce qui est le comportement attendu : "recherche → tri par pertinence").
  scope :sorted_by, ->(sort) {
    case sort
    when "price_asc"  then joins(:vehicle).order("vehicles.price ASC")
    when "price_desc" then joins(:vehicle).order("vehicles.price DESC")
    when "year_desc"  then joins(:vehicle).order("vehicles.year DESC")
    when "year_asc"   then joins(:vehicle).order("vehicles.year ASC")
    when "km_asc"     then joins(:vehicle).order("vehicles.kilometers ASC")
    else order(created_at: :desc)
    end
  }

  private

  def photos_content_type_and_size
    return unless photos.attached?

    photos.each do |photo|
      begin
        data = photo.blob.download
        detected = Marcel::MimeType.for(data, name: photo.filename.to_s)
      rescue ActiveStorage::FileNotFoundError
        detected = photo.content_type
      end
      unless PHOTO_ALLOWED_TYPES.include?(detected)
        errors.add(:photos, "doit être au format JPG, PNG ou WEBP (détecté : #{detected})")
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

  def destroy_orphan_vehicle
    vehicle&.destroy if vehicle&.listings&.empty?
  end
  after_destroy :destroy_orphan_vehicle
end
