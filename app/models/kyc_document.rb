class KycDocument < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: "User", foreign_key: :reviewed_by_id, optional: true

  has_one_attached :file

  DOCUMENT_TYPES = %w[identity_card passport driver_license proof_of_address].freeze
  STATUSES = %w[pending approved rejected].freeze

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png application/pdf].freeze
  MAX_FILE_SIZE = 10.megabytes

  validates :document_type, inclusion: { in: DOCUMENT_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :rejection_reason, presence: true, if: -> { status == "rejected" }
  validate :file_attached_and_valid

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  def pending?;  status == "pending"; end
  def approved?; status == "approved"; end
  def rejected?; status == "rejected"; end

  def approve!(reviewer)
    update!(
      status: "approved",
      reviewed_at: Time.current,
      reviewed_by_id: reviewer.id,
      rejection_reason: nil
    )
    user.update_kyc_status!
  end

  def reject!(reviewer, reason:)
    update!(
      status: "rejected",
      reviewed_at: Time.current,
      reviewed_by_id: reviewer.id,
      rejection_reason: reason
    )
    user.update_kyc_status!
  end

  private

  def file_attached_and_valid
    return errors.add(:file, "doit être joint") unless file.attached?

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      errors.add(:file, "doit être au format JPG, PNG ou PDF")
    end

    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "doit peser moins de #{MAX_FILE_SIZE / 1.megabyte} Mo")
    end
  end
end
