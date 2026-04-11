class ListingAnswer < ApplicationRecord
  belongs_to :listing_question
  belongs_to :user

  BODY_MAX_LENGTH = 2_000

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validate :answerer_must_be_listing_owner

  private

  # Contrat : seul le vendeur (propriétaire de l'annonce) peut répondre
  # à une question sur son listing. Ce garde-fou protège contre un
  # controller bypass ou un scénario de course condition multi-onglet.
  def answerer_must_be_listing_owner
    return if listing_question.blank? || user.blank?

    listing_owner_id = listing_question.listing&.user_id
    return if listing_owner_id == user_id

    errors.add(:user, "ne peut pas répondre à une question sur une annonce dont il n'est pas propriétaire")
  end
end
