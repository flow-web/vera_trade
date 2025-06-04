class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :conversation, optional: true
  
  has_many_attached :attachments
  
  attr_accessor :current_user_id
  
  validates :content, presence: true, unless: :has_attachments?
  
  # Enums for status and message types
  enum :status, { 
    sent: 'sent', 
    delivered: 'delivered', 
    read: 'read', 
    failed: 'failed' 
  }, default: 'sent'
  
  enum :message_type, { 
    text: 'text', 
    image: 'image', 
    document: 'document', 
    video: 'video',
    audio: 'audio',
    quick_reply: 'quick_reply',
    system: 'system'
  }, default: 'text'
  
  scope :between, -> (sender_id, recipient_id) do
    where(sender_id: sender_id, recipient_id: recipient_id)
    .or(where(sender_id: recipient_id, recipient_id: sender_id))
    .order(created_at: :asc)
  end
  
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  
  after_create_commit :broadcast_to_users, :update_conversation_activity, :set_delivered_status
  after_update_commit :broadcast_status_update
  
  # Reactions management
  def add_reaction(user, emoji)
    reactions_hash = parse_reactions
    reactions_hash[emoji] ||= []
    reactions_hash[emoji] << user.id unless reactions_hash[emoji].include?(user.id)
    update(reactions: reactions_hash.to_json)
  end
  
  def remove_reaction(user, emoji)
    reactions_hash = parse_reactions
    return unless reactions_hash[emoji]
    
    reactions_hash[emoji].delete(user.id)
    reactions_hash.delete(emoji) if reactions_hash[emoji].empty?
    update(reactions: reactions_hash.to_json)
  end
  
  def parse_reactions
    return {} if reactions.blank?
    JSON.parse(reactions)
  rescue JSON::ParserError
    {}
  end
  
  def mark_as_read!
    return if read?
    update!(read: true, status: 'read', read_at: Time.current)
  end

  def mark_as_unread!
    update!(read: false, read_at: nil) if read?
  end
  
  def mark_as_delivered!
    update!(status: 'delivered') if sent?
  end
  
  private
  
  def has_attachments?
    attachments.attached?
  end
  
  def set_delivered_status
    mark_as_delivered!
  end
  
  def update_conversation_activity
    return unless conversation
    conversation.update(last_activity_at: Time.current)
  end
  
  def broadcast_to_users
    # Broadcast individually to each user with their own current_user_id
    [sender_id, recipient_id].uniq.each do |user_id|
      broadcast_append_later_to(
        ["user", user_id, "messages"],
        target: "message-list",
        partial: "messages/message",
        locals: { message: self, current_user_id: user_id }
      )
    end
    
    # Broadcast notification for new message
    broadcast_update_later_to(
      ["user", recipient_id, "notifications"],
      target: "notification-badge",
      partial: "shared/notification_badge",
      locals: { count: recipient.unread_messages_count }
    )
  end
  
  def broadcast_status_update
    if saved_change_to_status? || saved_change_to_read?
      broadcast_update_later_to(
        ["user", sender_id, "message_status"],
        target: "message-status-#{id}",
        partial: "messages/message_status",
        locals: { message: self }
      )
    end
  end
end
