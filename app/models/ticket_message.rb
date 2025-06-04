class TicketMessage < ApplicationRecord
  belongs_to :support_ticket
  belongs_to :user
  
  has_many_attached :attachments

  # Validations
  validates :message, presence: true, length: { minimum: 1, maximum: 2000 }
  validates :message_type, inclusion: { 
    in: %w[user_message admin_response status_change auto_response] 
  }

  # Callbacks
  after_create :mark_ticket_activity
  after_create :send_notifications
  after_create :update_ticket_status

  # Scopes
  scope :visible_to_user, -> { where(internal: false) }
  scope :internal_only, -> { where(internal: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(message_type: type) }
  scope :user_messages, -> { where(message_type: 'user_message') }
  scope :admin_responses, -> { where(message_type: 'admin_response') }

  # Constants
  MESSAGE_TYPES = {
    'user_message' => 'Message utilisateur',
    'admin_response' => 'Réponse administrateur',
    'status_change' => 'Changement de statut',
    'auto_response' => 'Réponse automatique'
  }.freeze

  # Instance methods
  def message_type_label
    MESSAGE_TYPES[message_type] || message_type&.humanize
  end

  def visible_to?(viewer)
    return true if viewer.admin?
    return false if internal?
    viewer == support_ticket.user || viewer == support_ticket.assigned_to
  end

  def can_be_edited_by?(editor)
    return false if edited_at.present?
    return false if message_type != 'user_message' && message_type != 'admin_response'
    return false if created_at < 15.minutes.ago
    
    self.user == editor
  end

  def mark_as_read_by!(reader)
    case reader
    when support_ticket.user
      update!(read_by_user: true) unless read_by_user?
    else
      update!(read_by_admin: true) unless read_by_admin?
    end
  end

  def read_by?(reader)
    case reader
    when support_ticket.user
      read_by_user?
    else
      read_by_admin?
    end
  end

  def edit!(new_message, reason = nil)
    update!(
      message: new_message,
      edited_at: Time.current,
      edit_reason: reason
    )
  end

  def edited?
    edited_at.present?
  end

  def system_message?
    message_type != 'user_message' && message_type != 'admin_response'
  end

  def from_user?
    user == support_ticket.user
  end

  def from_admin?
    user != support_ticket.user
  end

  def has_attachments?
    attachments.attached?
  end

  private

  def mark_ticket_activity
    support_ticket.touch(:updated_at)
  end

  def send_notifications
    return if system_message?
    return if internal?

    if from_user?
      # Notify assigned admin
      if support_ticket.assigned_to
        TicketMessageMailer.new_user_message(self).deliver_later
        
        support_ticket.assigned_to.notifications.create!(
          title: "Nouveau message dans le ticket #{support_ticket.ticket_number}",
          message: message.truncate(100),
          notification_type: 'support_message',
          action_url: Rails.application.routes.url_helpers.admin_support_ticket_path(support_ticket),
          related_model: 'TicketMessage',
          related_id: id
        )
      end
    else
      # Notify user
      TicketMessageMailer.new_admin_response(self).deliver_later
      
      support_ticket.user.notifications.create!(
        title: "Nouvelle réponse pour votre ticket #{support_ticket.ticket_number}",
        message: message.truncate(100),
        notification_type: 'support_response',
        action_url: Rails.application.routes.url_helpers.support_ticket_path(support_ticket),
        related_model: 'TicketMessage',
        related_id: id
      )
    end
  end

  def update_ticket_status
    return if system_message?
    
    # If user responds and ticket was waiting for user, move to in_progress
    if from_user? && support_ticket.status == 'waiting_user'
      support_ticket.back_to_progress!
    end
  end
end
