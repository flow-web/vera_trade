class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  attr_accessor :current_user_id

  validates :content, presence: true

  scope :between, ->(sender_id, recipient_id) do
    where(sender_id: sender_id, recipient_id: recipient_id)
    .or(where(sender_id: recipient_id, recipient_id: sender_id))
    .order(created_at: :asc)
  end

  scope :unread, -> { where(read: false) }

  after_create_commit :broadcast_to_users

  def mark_as_read!
    update!(read: true) unless read?
  end

  def mark_as_unread!
    update!(read: false) if read?
  end

  private

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
