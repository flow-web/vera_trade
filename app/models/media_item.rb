class MediaItem < ApplicationRecord
  belongs_to :media_folder, optional: true
  belongs_to :listing
  has_one_attached :media
  
  CONTEXTS = [
    "Vue extérieure - avant",
    "Vue extérieure - arrière",
    "Vue extérieure - 3/4 avant",
    "Vue extérieure - 3/4 arrière",
    "Vue latérale",
    "Moteur",
    "Habitacle - avant",
    "Habitacle - arrière",
    "Tableau de bord",
    "Jantes",
    "Plancher",
    "Soubassement",
    "Coffre",
    "Siège",
    "Document",
    "Vidéo - démarrage",
    "Vidéo - conduite",
    "Vidéo - fonctionnalités",
    "Autre"
  ]
  
  CONTENT_TYPES = [
    "image",
    "video",
    "document"
  ]
  
  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: CONTENT_TYPES }
  validates :private, inclusion: { in: [true, false] }
  validates :media, presence: true
  validate :validate_media_type
  validate :validate_media_count, on: :create
  
  scope :public_items, -> { where(private: false) }
  scope :private_items, -> { where(private: true) }
  scope :images, -> { where(content_type: "image") }
  scope :videos, -> { where(content_type: "video") }
  scope :documents, -> { where(content_type: "document") }
  
  MAX_PUBLIC_MEDIA_COUNT = 10
  
  private
  
  def validate_media_type
    return unless media.attached?
    
    case content_type
    when "image"
      unless media.content_type.start_with?('image/')
        errors.add(:media, "doit être une image")
      end
    when "video"
      unless media.content_type.start_with?('video/')
        errors.add(:media, "doit être une vidéo")
      end
    when "document"
      unless media.content_type == "application/pdf"
        errors.add(:media, "doit être un document PDF")
      end
    end
  end
  
  def validate_media_count
    return if private || media_folder.present?
    
    # Vérifier que le nombre de médias publics ne dépasse pas la limite
    if listing.media_items.public_items.where(media_folder: nil).count >= MAX_PUBLIC_MEDIA_COUNT
      errors.add(:base, "Vous ne pouvez pas ajouter plus de #{MAX_PUBLIC_MEDIA_COUNT} photos/vidéos publiques")
    end
  end
end
