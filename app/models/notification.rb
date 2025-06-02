class Notification < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :notification_type, presence: true
  
  # Types de notifications
  enum :notification_type, {
    info: 'info',
    warning: 'warning',
    success: 'success',
    error: 'error',
    reminder: 'reminder',
    message: 'message',
    listing_update: 'listing_update',
    payment: 'payment',
    delivery: 'delivery',
    contract: 'contract',
    video_call: 'video_call',
    system: 'system'
  }, default: 'info'
  
  # Niveaux de priorité
  enum :priority, {
    low: 'low',
    normal: 'normal',
    high: 'high',
    urgent: 'urgent'
  }, default: 'normal'
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :urgent, -> { where(priority: 'urgent') }
  scope :high_priority, -> { where(priority: ['high', 'urgent']) }
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  
  def mark_as_read!
    update!(read: true)
  end
  
  def mark_as_unread!
    update!(read: false)
  end
  
  def expired?
    expires_at && expires_at < Time.current
  end
  
  def related_object
    return nil unless related_model && related_id
    related_model.constantize.find_by(id: related_id)
  end
  
  def related_object=(object)
    self.related_model = object.class.name
    self.related_id = object.id
  end
  
  def icon_class
    case notification_type
    when 'info' then 'fas fa-info-circle text-blue-500'
    when 'warning' then 'fas fa-exclamation-triangle text-yellow-500'
    when 'success' then 'fas fa-check-circle text-green-500'
    when 'error' then 'fas fa-times-circle text-red-500'
    when 'reminder' then 'fas fa-bell text-orange-500'
    when 'message' then 'fas fa-envelope text-blue-500'
    when 'listing_update' then 'fas fa-car text-primary'
    when 'payment' then 'fas fa-credit-card text-green-500'
    when 'delivery' then 'fas fa-truck text-blue-500'
    when 'contract' then 'fas fa-file-contract text-purple-500'
    when 'video_call' then 'fas fa-video text-blue-500'
    when 'system' then 'fas fa-cog text-gray-500'
    else 'fas fa-info-circle text-gray-500'
    end
  end
  
  def priority_color
    case priority
    when 'low' then 'text-gray-500'
    when 'normal' then 'text-blue-500'
    when 'high' then 'text-orange-500'
    when 'urgent' then 'text-red-500'
    else 'text-gray-500'
    end
  end
  
  # Méthodes de classe pour créer des notifications spécifiques
  def self.create_message_notification(user, message)
    create!(
      user: user,
      title: "Nouveau message",
      message: "Vous avez reçu un nouveau message de #{message.sender.email}",
      notification_type: 'message',
      priority: 'normal',
      action_url: "/conversations/#{message.conversation_id}",
      related_object: message
    )
  end
  
  def self.create_video_call_notification(user, video_call)
    create!(
      user: user,
      title: "Appel vidéo planifié",
      message: "Un appel vidéo a été planifié pour #{video_call.scheduled_at&.strftime('%d/%m/%Y à %H:%M')}",
      notification_type: 'video_call',
      priority: 'high',
      action_url: "/video_calls/#{video_call.id}",
      related_object: video_call
    )
  end
  
  def self.create_contract_notification(user, title, message, action_url)
    create!(
      user: user,
      title: title,
      message: message,
      notification_type: 'contract',
      priority: 'high',
      action_url: action_url
    )
  end
end
