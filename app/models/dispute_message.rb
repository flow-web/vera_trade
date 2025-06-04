class DisputeMessage < ApplicationRecord
  belongs_to :dispute
  belongs_to :user
  
  has_many_attached :attachments

  # Validations
  validates :message, presence: true, length: { minimum: 1, maximum: 2000 }
  validates :message_type, inclusion: { 
    in: %w[user_message system_update evidence_submission resolution_proposal status_change] 
  }
  validates :visibility, inclusion: { in: %w[all_parties private_to_mediator private_to_admin] }

  # Callbacks
  after_create :mark_dispute_activity
  after_create :send_notifications

  # Scopes
  scope :visible_to, ->(user) do
    if user.admin?
      all
    elsif user == dispute.mediator
      where(visibility: ['all_parties', 'private_to_mediator'])
    else
      where(visibility: 'all_parties')
    end
  end
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(message_type: type) }
  scope :user_messages, -> { where(message_type: 'user_message') }
  scope :system_messages, -> { where(message_type: 'system_update') }

  # Constants
  MESSAGE_TYPES = {
    'user_message' => 'Message utilisateur',
    'system_update' => 'Mise à jour système',
    'evidence_submission' => 'Soumission de preuve',
    'resolution_proposal' => 'Proposition de résolution',
    'status_change' => 'Changement de statut'
  }.freeze

  VISIBILITY_LEVELS = {
    'all_parties' => 'Toutes les parties',
    'private_to_mediator' => 'Privé pour le médiateur',
    'private_to_admin' => 'Privé pour l\'administrateur'
  }.freeze

  # Instance methods
  def message_type_label
    MESSAGE_TYPES[message_type] || message_type&.humanize
  end

  def visibility_label
    VISIBILITY_LEVELS[visibility] || visibility&.humanize
  end

  def visible_to?(user)
    return true if user.admin?
    return true if visibility == 'all_parties'
    return true if visibility == 'private_to_mediator' && user == dispute.mediator
    false
  end

  def can_be_edited_by?(user)
    return false if edited_at.present?
    return false if message_type != 'user_message'
    return false if created_at < 15.minutes.ago
    
    self.user == user
  end

  def mark_as_read_by!(reader)
    case reader
    when dispute.user
      update!(read_by_user: true) unless read_by_user?
    when dispute.other_party
      update!(read_by_other_user: true) unless read_by_other_user?
    when dispute.mediator
      update!(read_by_mediator: true) unless read_by_mediator?
    end
  end

  def read_by?(reader)
    case reader
    when dispute.user
      read_by_user?
    when dispute.other_party
      read_by_other_user?
    when dispute.mediator
      read_by_mediator?
    else
      false
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
    message_type != 'user_message'
  end

  def has_attachments?
    attachments.attached?
  end

  private

  def mark_dispute_activity
    dispute.touch(:updated_at)
  end

  def send_notifications
    return if system_message?
    return if visibility != 'all_parties'

    dispute.involved_users.each do |recipient|
      next if recipient == user
      
      DisputeMessageMailer.new_message(self, recipient).deliver_later
      
      # Create in-app notification
      recipient.notifications.create!(
        title: "Nouveau message dans le litige #{dispute.reference_number}",
        message: message.truncate(100),
        notification_type: 'dispute_message',
        action_url: Rails.application.routes.url_helpers.dispute_path(dispute),
        related_model: 'DisputeMessage',
        related_id: id
      )
    end
  end
end
