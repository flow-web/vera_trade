class AddListingContactColumns < ActiveRecord::Migration[8.0]
  # PR3 feat/buyer-contact — adds the data layer for listing-scoped
  # conversations and optional price offers on messages.
  #
  # conversations:
  #   + listing_id (nullable FK) — when set, this is a buyer-contact
  #     thread about a specific listing; when null, it's a legacy
  #     generic DM between two users. Nullable so the new column
  #     doesn't break any existing row (there shouldn't be any in
  #     practice, but belt-and-suspenders).
  #   + partial unique index on (listing_id, user_id) where
  #     listing_id IS NOT NULL — enforces "one conversation per
  #     (listing, buyer)" at the DB level. The find_or_create_for
  #     class method relies on this.
  #
  # messages:
  #   + conversation_id (nullable FK) — ties a message to its parent
  #     conversation. New buyer-contact messages set it; legacy
  #     messages found via Message.between(sender, recipient) can
  #     keep it nil.
  #   + offer_cents (nullable integer) — a message may carry an
  #     optional financial offer from buyer to seller. Stored in
  #     cents to avoid decimal rounding; converted to euros in
  #     the view layer.
  def change
    add_reference :conversations, :listing, foreign_key: true, null: true
    add_reference :messages, :conversation, foreign_key: true, null: true
    add_column :messages, :offer_cents, :integer, null: true

    add_index :conversations, [ :listing_id, :user_id ],
              unique: true,
              where: "listing_id IS NOT NULL",
              name: "index_conversations_on_listing_and_buyer_unique"
  end
end
