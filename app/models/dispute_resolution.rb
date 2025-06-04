class DisputeResolution < ApplicationRecord
  belongs_to :dispute
  belongs_to :proposed_by, class_name: 'User'

  # Validations
  validates :resolution_type, presence: true, inclusion: { 
    in: %w[full_refund partial_refund replacement service_redo compensation mutual_agreement custom] 
  }
  validates :details, presence: true, length: { minimum: 20, maximum: 1000 }
  validates :status, inclusion: { in: %w[pending accepted rejected expired implemented] }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :expires_at, presence: true
  validate :expiration_in_future, on: :create

  # Callbacks
  before_validation :set_expiration, on: :create
  after_create :notify_parties
  after_update :handle_status_change

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :expired, -> { where(status: 'expired') }
  scope :implemented, -> { where(status: 'implemented') }
  scope :active, -> { where(status: ['pending', 'accepted']) }
  scope :by_type, ->(type) { where(resolution_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  # Constants
  RESOLUTION_TYPES = {
    'full_refund' => 'Remboursement complet',
    'partial_refund' => 'Remboursement partiel',
    'replacement' => 'Remplacement',
    'service_redo' => 'Refaire le service',
    'compensation' => 'Compensation',
    'mutual_agreement' => 'Accord mutuel',
    'custom' => 'Solution personnalisée'
  }.freeze

  STATUSES = {
    'pending' => 'En attente',
    'accepted' => 'Accepté',
    'rejected' => 'Rejeté',
    'expired' => 'Expiré',
    'implemented' => 'Implémenté'
  }.freeze

  # Instance methods
  def resolution_type_label
    RESOLUTION_TYPES[resolution_type] || resolution_type&.humanize
  end

  def status_label
    STATUSES[status] || status&.humanize
  end

  def expired?
    expires_at < Time.current
  end

  def pending?
    status == 'pending' && !expired?
  end

  def accepted?
    status == 'accepted'
  end

  def can_be_accepted_by?(user)
    return false unless pending?
    return false if proposed_by == user
    
    dispute.involved_users.include?(user)
  end

  def can_be_rejected_by?(user)
    return false unless pending?
    return false if proposed_by == user
    
    dispute.involved_users.include?(user) || user.admin?
  end

  def accept_by!(user)
    return false unless can_be_accepted_by?(user)
    
    accepted_users = accepted_by_user_ids
    accepted_users << user.id unless accepted_users.include?(user.id)
    
    update!(accepted_by_users: accepted_users.to_json)
    
    # Check if all required parties have accepted
    required_parties = dispute.involved_users.reject { |u| u == proposed_by }
    if required_parties.all? { |party| accepted_users.include?(party.id) }
      update!(status: 'accepted')
    end
  end

  def reject_by!(user, reason = nil)
    return false unless can_be_rejected_by?(user)
    
    update!(
      status: 'rejected',
      rejection_reason: reason
    )
  end

  def implement!(notes = nil)
    return false unless accepted?
    
    update!(
      status: 'implemented',
      implemented_at: Time.current,
      implementation_notes: notes
    )
    
    # Mark dispute as resolved if this resolution is implemented
    dispute.resolve!(details)
    
    # Handle payment/refund if applicable
    handle_financial_resolution if involves_money?
  end

  def accepted_by_user_ids
    return [] if accepted_by_users.blank?
    JSON.parse(accepted_by_users)
  rescue JSON::ParserError
    []
  end

  def accepted_by?(user)
    accepted_by_user_ids.include?(user.id)
  end

  def remaining_acceptances_needed
    required_parties = dispute.involved_users.reject { |u| u == proposed_by }
    required_parties.reject { |party| accepted_by?(party) }
  end

  def involves_money?
    %w[full_refund partial_refund compensation].include?(resolution_type) && amount && amount > 0
  end

  def requires_manual_implementation?
    %w[replacement service_redo custom].include?(resolution_type)
  end

  def auto_implementable?
    %w[full_refund partial_refund].include?(resolution_type) && amount && amount > 0
  end

  def time_until_expiration
    return 0 if expired?
    ((expires_at - Time.current) / 1.hour).round(1)
  end

  def mark_as_expired!
    return false unless expires_at < Time.current && status == 'pending'
    
    update!(status: 'expired')
  end

  # Class methods
  def self.expire_old_resolutions!
    pending.where('expires_at < ?', Time.current).find_each(&:mark_as_expired!)
  end

  private

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  def expiration_in_future
    return unless expires_at
    
    if expires_at <= Time.current
      errors.add(:expires_at, "doit être dans le futur")
    end
  end

  def notify_parties
    dispute.involved_users.each do |recipient|
      next if recipient == proposed_by
      
      DisputeResolutionMailer.resolution_proposed(self, recipient).deliver_later
      
      recipient.notifications.create!(
        title: "Nouvelle proposition de résolution pour le litige #{dispute.reference_number}",
        message: "#{proposed_by.email} a proposé une résolution : #{resolution_type_label}",
        notification_type: 'dispute_resolution',
        action_url: Rails.application.routes.url_helpers.dispute_path(dispute),
        related_model: 'DisputeResolution',
        related_id: id
      )
    end

    # Add system message to dispute
    dispute.dispute_messages.create!(
      user: proposed_by,
      message: "Proposition de résolution : #{resolution_type_label} - #{details.truncate(100)}",
      message_type: 'resolution_proposal',
      visibility: 'all_parties'
    )
  end

  def handle_status_change
    case status
    when 'accepted'
      notify_resolution_accepted
    when 'rejected'
      notify_resolution_rejected
    when 'implemented'
      notify_resolution_implemented
    when 'expired'
      notify_resolution_expired
    end
  end

  def notify_resolution_accepted
    DisputeResolutionMailer.resolution_accepted(self).deliver_later
    
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "La proposition de résolution a été acceptée par toutes les parties",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end

  def notify_resolution_rejected
    DisputeResolutionMailer.resolution_rejected(self).deliver_later
    
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "La proposition de résolution a été rejetée",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end

  def notify_resolution_implemented
    DisputeResolutionMailer.resolution_implemented(self).deliver_later
    
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "La résolution a été implémentée avec succès",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end

  def notify_resolution_expired
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "La proposition de résolution a expiré",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end

  def handle_financial_resolution
    return unless involves_money?
    
    case resolution_type
    when 'full_refund', 'partial_refund'
      process_refund
    when 'compensation'
      process_compensation
    end
  end

  def process_refund
    # Integration with payment system would go here
    # For now, just log the action
    Rails.logger.info "Processing #{resolution_type} of #{amount} for dispute #{dispute.reference_number}"
    
    # This would integrate with Stripe, PayPal, or other payment processors
    # RefundService.new(dispute, amount).process
  end

  def process_compensation
    # Integration with wallet/compensation system would go here
    Rails.logger.info "Processing compensation of #{amount} for dispute #{dispute.reference_number}"
    
    # This could credit user's wallet or process a separate payment
    # CompensationService.new(dispute, amount).process
  end
end
