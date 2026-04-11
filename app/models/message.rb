class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :conversation, optional: true

  attr_accessor :current_user_id

  OFFER_MAX_CENTS = 10_000_000_00 # 10 000 000 € sanity cap

  validates :content, presence: true
  validates :offer_cents,
    numericality: {
      only_integer: true,
      greater_than: 0,
      less_than_or_equal_to: OFFER_MAX_CENTS
    },
    allow_nil: true

  scope :between, ->(sender_id, recipient_id) do
    where(sender_id: sender_id, recipient_id: recipient_id)
    .or(where(sender_id: recipient_id, recipient_id: sender_id))
    .order(created_at: :asc)
  end

  scope :unread,     -> { where(read: false) }
  scope :with_offer, -> { where.not(offer_cents: nil) }

  after_create_commit :broadcast_to_users
  after_create_commit :notify_recipient_by_email

  def offer?
    offer_cents.present?
  end

  # Returns the offer amount in euros as a Float (never rounded, the
  # cents storage is the source of truth). Nil if no offer is attached.
  def offer_euros
    return nil unless offer?
    offer_cents / 100.0
  end

  def mark_as_read!
    update!(read: true) unless read?
  end

  def mark_as_unread!
    update!(read: false) if read?
  end

  private

  def notify_recipient_by_email
    ConversationMailer.new_message(self).deliver_later
  end

  def broadcast_to_users
    # Broadcast individually to each user with their own current_user_id
    [ sender_id, recipient_id ].uniq.each do |user_id|
      broadcast_append_later_to(
        [ "user", user_id, "messages" ],
        target: "message-list",
        partial: "messages/message",
        locals: { message: self, current_user_id: user_id }
      )
    end
  end
end
