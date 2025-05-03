class MediaFolder < ApplicationRecord
  belongs_to :listing
  has_many :media_items, dependent: :destroy
  
  FOLDER_TYPES = [
    "Carnet d'entretien",
    "Factures & achats",
    "Restaurations / Réparations",
    "Certificats & documents",
    "Contrôle technique",
    "Carte grise",
    "Autre"
  ]
  
  validates :name, presence: true
  validates :private, inclusion: { in: [true, false] }
  
  scope :public_folders, -> { where(private: false) }
  scope :private_folders, -> { where(private: true) }
end
