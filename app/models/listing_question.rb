class ListingQuestion < ApplicationRecord
  belongs_to :listing
  belongs_to :user
  has_one :answer, class_name: "ListingAnswer", dependent: :destroy

  # Rate limit anti-spam : un acheteur ne peut pas poser plus de
  # RATE_LIMIT_PER_DAY questions sur la MÊME annonce en 24 glissantes.
  # C'est une garde basique côté controller ; pour du ML-grade anti-abuse
  # on utilisera Rack::Attack + un store dédié plus tard.
  RATE_LIMIT_PER_DAY = 5
  BODY_MAX_LENGTH = 1_000

  # Nouvelles questions sont publiées par défaut (UX à faible friction).
  # Le vendeur peut hider reactive via un futur bouton admin. La colonne
  # DB garde default: false comme filet de sécurité.
  attribute :published, :boolean, default: true

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }

  scope :published,   -> { where(published: true) }
  scope :ordered,     -> { order(created_at: :asc) }
  scope :unanswered,  -> { where.missing(:answer) }
  scope :answered,    -> { joins(:answer) }

  # Anti-spam guard consulted by ListingQuestionsController#create.
  # Returns true when user has already posted RATE_LIMIT_PER_DAY questions
  # on this listing within the last 24 hours.
  def self.over_rate_limit?(user:, listing:)
    where(user: user, listing: listing)
      .where(created_at: 24.hours.ago..)
      .count >= RATE_LIMIT_PER_DAY
  end
end
