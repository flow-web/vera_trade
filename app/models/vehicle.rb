class Vehicle < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :users, through: :listings

  validates :make, :model, :year, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :kilometers, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Validations pour les nouveaux champs
  validates :license_plate, format: { with: /\A[A-Z]{2}[- ]?\d{3}[- ]?[A-Z]{2}\z/, message: "doit être au format AA-123-AA" }, allow_nil: true
  validates :vin, format: { with: /\A[A-HJ-NPR-Z0-9]{17}\z/, message: "doit contenir exactement 17 caractères alphanumériques" }, allow_nil: true
  validates :fiscal_power, numericality: { greater_than: 0 }, allow_nil: true
  validates :average_consumption, numericality: { greater_than: 0 }, allow_nil: true
  validates :co2_emissions, numericality: { greater_than: 0 }, allow_nil: true

  # Validations d'unicité
  validates :license_plate, uniqueness: true, allow_nil: true
  validates :vin, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :normalize_license_plate
  before_validation :normalize_vin

  private

  def normalize_license_plate
    return if license_plate.blank?
    self.license_plate = license_plate.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def normalize_vin
    return if vin.blank?
    self.vin = vin.upcase
  end
end
