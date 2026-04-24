class SearchPreset < ApplicationRecord
  belongs_to :user

  MAX_PER_USER = 20

  validates :name, presence: true
  validates :filters, presence: true
  validate :user_preset_cap

  private

  def user_preset_cap
    return unless user && user.search_presets.count >= MAX_PER_USER
    errors.add(:base, "Vous ne pouvez pas avoir plus de #{MAX_PER_USER} recherches sauvegardées")
  end

  public

  # Définit les filtres par défaut si non spécifiés
  before_validation :set_default_filters, on: :create

  private

  def set_default_filters
    self.filters ||= {}
  end
end
