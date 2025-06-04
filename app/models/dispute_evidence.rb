class DisputeEvidence < ApplicationRecord
  belongs_to :dispute
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User', optional: true
  
  has_many_attached :files

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :evidence_type, presence: true, inclusion: { 
    in: %w[photo document video audio screenshot receipt invoice communication other] 
  }
  validates :status, inclusion: { in: %w[pending_review approved rejected] }
  validates :files, presence: true
  validate :files_validation

  # Callbacks
  before_validation :set_file_metadata
  after_create :notify_evidence_submitted
  after_update :notify_status_change, if: :saved_change_to_status?

  # Scopes
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending_review') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :by_type, ->(type) { where(evidence_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  # Constants
  EVIDENCE_TYPES = {
    'photo' => 'Photographie',
    'document' => 'Document',
    'video' => 'Vidéo',
    'audio' => 'Audio',
    'screenshot' => 'Capture d\'écran',
    'receipt' => 'Reçu',
    'invoice' => 'Facture',
    'communication' => 'Communication',
    'other' => 'Autre'
  }.freeze

  STATUSES = {
    'pending_review' => 'En attente de révision',
    'approved' => 'Approuvé',
    'rejected' => 'Rejeté'
  }.freeze

  ALLOWED_FILE_TYPES = {
    'photo' => %w[image/jpeg image/png image/gif image/webp],
    'document' => %w[application/pdf text/plain application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document],
    'video' => %w[video/mp4 video/mpeg video/quicktime video/webm],
    'audio' => %w[audio/mpeg audio/wav audio/ogg],
    'screenshot' => %w[image/jpeg image/png image/gif image/webp],
    'receipt' => %w[image/jpeg image/png application/pdf],
    'invoice' => %w[image/jpeg image/png application/pdf],
    'communication' => %w[image/jpeg image/png application/pdf text/plain],
    'other' => %w[image/jpeg image/png application/pdf text/plain]
  }.freeze

  MAX_FILE_SIZE = 10.megabytes
  MAX_FILES_COUNT = 5

  # Instance methods
  def evidence_type_label
    EVIDENCE_TYPES[evidence_type] || evidence_type&.humanize
  end

  def status_label
    STATUSES[status] || status&.humanize
  end

  def can_be_reviewed_by?(reviewer)
    return false if status != 'pending_review'
    reviewer.admin? || reviewer == dispute.mediator
  end

  def approve!(reviewer, notes = nil)
    update!(
      status: 'approved',
      reviewed_at: Time.current,
      reviewed_by: reviewer,
      review_notes: notes
    )
  end

  def reject!(reviewer, notes)
    update!(
      status: 'rejected',
      reviewed_at: Time.current,
      reviewed_by: reviewer,
      review_notes: notes
    )
  end

  def total_file_size
    files.sum(&:byte_size)
  end

  def total_file_size_mb
    (total_file_size.to_f / 1.megabyte).round(2)
  end

  def files_count
    files.count
  end

  def pending_review?
    status == 'pending_review'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def can_be_viewed_by?(viewer)
    return true if viewer.admin?
    return true if viewer == dispute.mediator
    return true if dispute.involved_users.include?(viewer) && approved?
    
    # User can always see their own evidence
    viewer == user
  end

  private

  def set_file_metadata
    return unless files.attached?
    
    total_size = files.sum(&:byte_size)
    self.file_size = total_size
    
    # Set file_type based on the first file if not set
    if files.any? && file_type.blank?
      first_file = files.first
      self.file_type = first_file.content_type
    end
  end

  def files_validation
    return unless files.attached?

    # Check file count
    if files.count > MAX_FILES_COUNT
      errors.add(:files, "Vous ne pouvez télécharger que #{MAX_FILES_COUNT} fichiers maximum")
      return
    end

    # Check each file
    files.each_with_index do |file, index|
      # Check file size
      if file.byte_size > MAX_FILE_SIZE
        errors.add(:files, "Le fichier #{index + 1} est trop volumineux (maximum #{MAX_FILE_SIZE / 1.megabyte}MB)")
      end

      # Check file type
      allowed_types = ALLOWED_FILE_TYPES[evidence_type] || []
      unless allowed_types.include?(file.content_type)
        errors.add(:files, "Le fichier #{index + 1} n'est pas d'un type autorisé pour ce type de preuve")
      end
    end

    # Check total size
    total_size = files.sum(&:byte_size)
    if total_size > MAX_FILE_SIZE * 2
      errors.add(:files, "La taille totale des fichiers ne peut pas dépasser #{(MAX_FILE_SIZE * 2) / 1.megabyte}MB")
    end
  end

  def notify_evidence_submitted
    # Notify dispute parties
    dispute.involved_users.each do |recipient|
      next if recipient == user
      
      DisputeEvidenceMailer.evidence_submitted(self, recipient).deliver_later
    end

    # Add system message to dispute
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "#{user.email} a soumis une nouvelle preuve : #{title}",
      message_type: 'evidence_submission',
      visibility: 'all_parties'
    )
  end

  def notify_status_change
    return unless reviewed_by

    # Notify the submitter
    DisputeEvidenceMailer.evidence_reviewed(self).deliver_later

    # Add system message to dispute
    status_text = approved? ? 'approuvée' : 'rejetée'
    dispute.dispute_messages.create!(
      user: User.system_user,
      message: "La preuve '#{title}' a été #{status_text} par #{reviewed_by.email}",
      message_type: 'system_update',
      visibility: 'all_parties'
    )
  end
end
