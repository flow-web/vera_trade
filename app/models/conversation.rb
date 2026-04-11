class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :other_user, class_name: "User"
  belongs_to :listing, optional: true
  has_many :messages, dependent: :destroy

  # Aliases to make listing-contact code read as buyer/seller without
  # renaming the legacy user_id / other_user_id columns. `alias_method`
  # works on the association reader methods ; `alias_attribute` would
  # only work on actual DB columns.
  alias_method :buyer,  :user
  alias_method :seller, :other_user

  # Uniqueness for legacy generic DMs (listing-less conversations).
  # Listing-scoped conversations are uniqued by the partial index in
  # db/schema.rb on (listing_id, user_id) WHERE listing_id IS NOT NULL.
  validates :user_id, uniqueness: { scope: :other_user_id }, if: -> { listing_id.blank? }

  # PR3 feat/buyer-contact — single entrypoint for the buyer-contact
  # flow. Returns the existing conversation for this (listing, buyer)
  # pair if one exists, otherwise creates a fresh one linking the
  # buyer (user) to the seller (other_user, from listing.user).
  #
  # Raises ArgumentError if the buyer is the listing owner — sellers
  # cannot contact themselves about their own listing.
  def self.find_or_create_for(listing:, buyer:)
    raise ArgumentError, "buyer cannot be the listing owner" if listing.user_id == buyer.id

    find_or_create_by!(
      listing_id: listing.id,
      user_id:    buyer.id,
      other_user_id: listing.user_id
    )
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  # Per-user unread count — the legacy method assumed the viewer was
  # always `user` (the buyer), which is wrong in a two-sided thread.
  def unread_count_for(viewer)
    messages.where(recipient_id: viewer.id, read: false).count
  end
end
