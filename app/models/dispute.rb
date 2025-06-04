class Dispute < ApplicationRecord
  belongs_to :user
  belongs_to :disputed_item, polymorphic: true
  belongs_to :mediator, class_name: 'User', optional: true
  
  has_many :dispute_messages, dependent: :destroy
  has_many :dispute_evidences, dependent: :destroy
  has_many :dispute_resolutions, dependent: :destroy
  
  has_many_attached :attachments

  # Validations
  validates :title, presence: true, length: { minimum: 10, maximum: 200 }
  validates :description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :dispute_type, presence: true, inclusion: { 
    in: %w[product_quality payment_issue service_dispute shipping_problem fraud_claim warranty_issue other] 
  }
  validates :status, presence: true, inclusion: { 
    in: %w[open waiting_response in_mediation escalated resolved closed cancelled] 
  }
  validates :priority, inclusion: { in: %w[low normal high urgent] }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :reference_number, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_reference_number, on: :create
  after_create :notify_parties
  after_update :track_status_changes

  # Scopes
  scope :open, -> { where(status: ['open', 'waiting_response', 'in_mediation', 'escalated']) }
  scope :closed, -> { where(status: ['resolved', 'closed', 'cancelled']) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_type, ->(type) { where(dispute_type: type) }
  scope :recent, -> { order(created_at: :desc) }
  scope :urgent, -> { where(priority: 'urgent') }
  scope :requiring_mediation, -> { where(status: 'escalated') }
  scope :for_user, ->(user) { where(user: user) }
  scope :involving_user, ->(user) do
    joins(:disputed_item).where(
      "(disputes.user_id = :user_id) OR 
       (disputed_item_type = 'Listing' AND disputed_item_id IN (SELECT id FROM listings WHERE user_id = :user_id)) OR
       (disputed_item_type = 'ServiceBooking' AND disputed_item_id IN (SELECT id FROM service_bookings WHERE user_id = :user_id OR service_provider_id IN (SELECT id FROM service_providers WHERE user_id = :user_id)))",
      user_id: user.id
    )
  end

  # Enums alternative using constants
  DISPUTE_TYPES = {
    'product_quality' => 'Problème de qualité du produit',
    'payment_issue' => 'Problème de paiement',
    'service_dispute' => 'Litige de service',
    'shipping_problem' => 'Problème de livraison',
    'fraud_claim' => 'Réclamation de fraude',
    'warranty_issue' => 'Problème de garantie',
    'other' => 'Autre'
  }.freeze

  STATUSES = {
    'open' => 'Ouvert',
    'waiting_response' => 'En attente de réponse',
    'in_mediation' => 'En médiation',
    'escalated' => 'Escaladé',
    'resolved' => 'Résolu',
    'closed' => 'Fermé',
    'cancelled' => 'Annulé'
  }.freeze

  PRIORITIES = {
    'low' => 'Faible',
    'normal' => 'Normal',
    'high' => 'Élevé',
    'urgent' => 'Urgent'
  }.freeze

  # Instance methods
  def dispute_type_label
    DISPUTE_TYPES[dispute_type] || dispute_type&.humanize
  end

  def status_label
    STATUSES[status] || status&.humanize
  end

  def priority_label
    PRIORITIES[priority] || priority&.humanize
  end

  def other_party
    return nil unless disputed_item.respond_to?(:user)
    disputed_item.user == user ? disputed_item.buyer : disputed_item.user
  end

  def involved_users
    users = [user]
    users << other_party if other_party
    users << mediator if mediator
    users.compact.uniq
  end

  def can_be_viewed_by?(viewer)
    involved_users.include?(viewer) || viewer.admin?
  end

  def can_be_edited_by?(editor)
    return false if closed?
    user == editor || mediator == editor || editor.admin?
  end

  def open?
    %w[open waiting_response in_mediation escalated].include?(status)
  end

  def closed?
    %w[resolved closed cancelled].include?(status)
  end

  def requires_mediation?
    status == 'escalated'
  end

  def auto_close_eligible?
    status == 'resolved' && resolved_at && resolved_at < 7.days.ago
  end

  def escalate!
    update!(status: 'escalated', escalated_at: Time.current)
    notify_escalation
  end

  def assign_mediator!(mediator_user)
    update!(mediator: mediator_user, status: 'in_mediation')
    notify_mediator_assigned
  end

  def resolve!(resolution_text = nil)
    update!(
      status: 'resolved',
      resolved_at: Time.current,
      resolution: resolution_text
    )
    notify_resolution
  end

  def reopen!
    return false if cancelled?
    update!(status: 'open', resolved_at: nil, resolution: nil)
    notify_reopened
  end

  def unread_messages_for(user)
    dispute_messages.where(
      case user
      when self.user
        { read_by_user: false }
      when other_party
        { read_by_other_user: false }
      when mediator
        { read_by_mediator: false }
      else
        { id: nil } # Return empty relation
      end
    )
  end

  def last_activity_at
    [
      dispute_messages.maximum(:created_at),
      dispute_evidences.maximum(:created_at),
      updated_at
    ].compact.max
  end

  private

  def generate_reference_number
    return if reference_number.present?
    
    loop do
      self.reference_number = "DIS-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      break unless Dispute.exists?(reference_number: reference_number)
    end
  end

  def notify_parties
    # Implement notification logic
    involved_users.each do |recipient|
      next if recipient == user
      DisputeMailer.dispute_created(self, recipient).deliver_later
    end
  end

  def track_status_changes
    return unless saved_change_to_status?
    
    # Log status change
    dispute_messages.create!(
      user: Current.user || User.system_user,
      message: "Statut modifié de '#{status_was}' à '#{status}'",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end

  def notify_escalation
    # Notify administrators about escalation
    User.admins.each do |admin|
      DisputeMailer.dispute_escalated(self, admin).deliver_later
    end
  end

  def notify_mediator_assigned
    DisputeMailer.mediator_assigned(self).deliver_later if mediator
  end

  def notify_resolution
    involved_users.each do |recipient|
      DisputeMailer.dispute_resolved(self, recipient).deliver_later
    end
  end

  def notify_reopened
    involved_users.each do |recipient|
      DisputeMailer.dispute_reopened(self, recipient).deliver_later
    end
  end
end
