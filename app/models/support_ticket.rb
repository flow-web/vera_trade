class SupportTicket < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: 'User', optional: true
  
  has_many :ticket_messages, dependent: :destroy
  has_many_attached :attachments

  # Validations
  validates :title, presence: true, length: { minimum: 10, maximum: 200 }
  validates :description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :priority, inclusion: { in: %w[low normal high urgent] }
  validates :status, inclusion: { in: %w[open in_progress waiting_user resolved closed] }
  validates :category, presence: true, inclusion: { 
    in: %w[technical_issue account_problem billing_inquiry feature_request dispute_support general_inquiry] 
  }
  validates :ticket_number, presence: true, uniqueness: true
  validates :satisfaction_rating, numericality: { in: 1..5 }, allow_blank: true

  # Callbacks
  before_validation :generate_ticket_number, on: :create
  after_create :notify_assignment
  after_update :track_status_changes
  after_update :notify_resolution, if: :saved_change_to_status?

  # Scopes
  scope :open, -> { where(status: ['open', 'in_progress', 'waiting_user']) }
  scope :closed, -> { where(status: ['resolved', 'closed']) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_status, ->(status) { where(status: status) }
  scope :assigned_to, ->(user) { where(assigned_to: user) }
  scope :unassigned, -> { where(assigned_to: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :urgent, -> { where(priority: 'urgent') }
  scope :requiring_attention, -> { where(status: ['open', 'waiting_user']) }

  # Constants
  CATEGORIES = {
    'technical_issue' => 'Problème technique',
    'account_problem' => 'Problème de compte',
    'billing_inquiry' => 'Question de facturation',
    'feature_request' => 'Demande de fonctionnalité',
    'dispute_support' => 'Support pour litige',
    'general_inquiry' => 'Question générale'
  }.freeze

  STATUSES = {
    'open' => 'Ouvert',
    'in_progress' => 'En cours',
    'waiting_user' => 'En attente utilisateur',
    'resolved' => 'Résolu',
    'closed' => 'Fermé'
  }.freeze

  PRIORITIES = {
    'low' => 'Faible',
    'normal' => 'Normal',
    'high' => 'Élevé',
    'urgent' => 'Urgent'
  }.freeze

  # Instance methods
  def category_label
    CATEGORIES[category] || category&.humanize
  end

  def status_label
    STATUSES[status] || status&.humanize
  end

  def priority_label
    PRIORITIES[priority] || priority&.humanize
  end

  def open?
    %w[open in_progress waiting_user].include?(status)
  end

  def closed?
    %w[resolved closed].include?(status)
  end

  def can_be_viewed_by?(viewer)
    return true if viewer.admin?
    return true if viewer == assigned_to
    viewer == user
  end

  def can_be_edited_by?(editor)
    return false if closed?
    return true if editor.admin?
    return true if editor == assigned_to
    editor == user
  end

  def assign_to!(agent)
    update!(assigned_to: agent, status: 'in_progress')
    notify_assignment_change
  end

  def unassign!
    update!(assigned_to: nil, status: 'open')
  end

  def resolve!(resolution_notes = nil)
    update!(
      status: 'resolved',
      resolved_at: Time.current,
      resolution_notes: resolution_notes
    )
  end

  def close!
    update!(status: 'closed')
  end

  def reopen!
    return false if closed? && resolved_at && resolved_at < 30.days.ago
    update!(status: 'open', resolved_at: nil)
  end

  def waiting_for_user!
    update!(status: 'waiting_user')
  end

  def back_to_progress!
    return false unless status == 'waiting_user'
    update!(status: 'in_progress')
  end

  def unread_messages_for(viewer)
    case viewer
    when user
      ticket_messages.where(read_by_user: false, internal: false)
    when assigned_to
      ticket_messages.where(read_by_admin: false)
    else
      ticket_messages.none
    end
  end

  def last_activity_at
    [
      ticket_messages.maximum(:created_at),
      updated_at
    ].compact.max
  end

  def response_time
    return nil unless assigned_to && status_changed_to_in_progress_at
    
    status_changed_to_in_progress_at - created_at
  end

  def resolution_time
    return nil unless resolved_at
    
    resolved_at - created_at
  end

  def overdue?
    return false if closed?
    
    case priority
    when 'urgent'
      created_at < 2.hours.ago
    when 'high'
      created_at < 8.hours.ago
    when 'normal'
      created_at < 24.hours.ago
    when 'low'
      created_at < 3.days.ago
    else
      false
    end
  end

  def auto_close_eligible?
    status == 'resolved' && resolved_at && resolved_at < 7.days.ago
  end

  def satisfaction_provided?
    satisfaction_rating.present?
  end

  def add_satisfaction_rating!(rating, feedback = nil)
    update!(
      satisfaction_rating: rating,
      satisfaction_feedback: feedback
    )
  end

  def tag_list
    return [] if tags.blank?
    JSON.parse(tags)
  rescue JSON::ParserError
    []
  end

  def tag_list=(tag_array)
    self.tags = tag_array.compact.uniq.to_json
  end

  def add_tag(tag)
    current_tags = tag_list
    current_tags << tag.to_s unless current_tags.include?(tag.to_s)
    self.tag_list = current_tags
    save
  end

  def remove_tag(tag)
    current_tags = tag_list
    current_tags.delete(tag.to_s)
    self.tag_list = current_tags
    save
  end

  private

  def generate_ticket_number
    return if ticket_number.present?
    
    loop do
      self.ticket_number = "TK-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      break unless SupportTicket.exists?(ticket_number: ticket_number)
    end
  end

  def notify_assignment
    return unless assigned_to
    
    SupportTicketMailer.ticket_assigned(self).deliver_later
  end

  def notify_assignment_change
    return unless assigned_to
    
    SupportTicketMailer.ticket_reassigned(self).deliver_later
    
    # Notify user
    user.notifications.create!(
      title: "Votre ticket #{ticket_number} a été assigné",
      message: "Un agent s'occupe maintenant de votre demande.",
      notification_type: 'support_update',
      action_url: Rails.application.routes.url_helpers.support_ticket_path(self)
    )
  end

  def track_status_changes
    return unless saved_change_to_status?
    
    # Store when ticket moved to in_progress for metrics
    if status == 'in_progress' && status_was != 'in_progress'
      update_column(:status_changed_to_in_progress_at, Time.current)
    end
    
    # Add system message
    ticket_messages.create!(
      user: assigned_to || User.system_user,
      message: "Statut modifié de '#{STATUSES[status_was] || status_was}' à '#{status_label}'",
      message_type: 'status_change',
      internal: false
    )
  end

  def notify_resolution
    return unless status == 'resolved'
    
    SupportTicketMailer.ticket_resolved(self).deliver_later
    
    user.notifications.create!(
      title: "Votre ticket #{ticket_number} a été résolu",
      message: "Votre demande de support a été résolue. N'hésitez pas à nous faire un retour.",
      notification_type: 'support_resolved',
      action_url: Rails.application.routes.url_helpers.support_ticket_path(self)
    )
  end
end
