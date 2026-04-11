class SearchPreset < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :filters, presence: true

  # Définit les filtres par défaut si non spécifiés
  before_validation :set_default_filters, on: :create

  private

  def set_default_filters
    self.filters ||= {}
  end
end
