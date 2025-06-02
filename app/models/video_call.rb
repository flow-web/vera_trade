class VideoCall < ApplicationRecord
  belongs_to :conversation
  
  validates :status, presence: true
  
  # Enums for call status
  enum :status, {
    scheduled: 'scheduled',
    ringing: 'ringing',
    active: 'active',
    ended: 'ended',
    cancelled: 'cancelled',
    missed: 'missed',
    rejected: 'rejected'
  }, default: 'scheduled'
  
  scope :recent, -> { order(created_at: :desc) }
  scope :upcoming, -> { where(status: 'scheduled').where('scheduled_at > ?', Time.current) }
  scope :past, -> { where(status: ['ended', 'cancelled', 'missed', 'rejected']) }
  
  before_create :generate_room_id
  
  def duration
    return nil unless started_at && ended_at
    ((ended_at - started_at) / 60).round(1) # in minutes
  end
  
  def start!
    update!(
      status: 'active',
      started_at: Time.current
    )
  end
  
  def end!
    update!(
      status: 'ended',
      ended_at: Time.current
    )
  end
  
  def cancel!
    update!(status: 'cancelled')
  end
  
  def reject!
    update!(status: 'rejected')
  end
  
  def miss!
    update!(status: 'missed')
  end
  
  def participants
    [conversation.user, conversation.other_user]
  end
  
  def other_participant(current_user)
    conversation.other_participant(current_user)
  end
  
  def can_join?(user)
    participants.include?(user) && (scheduled? || ringing? || active?)
  end
  
  def expired?
    scheduled? && scheduled_at && scheduled_at < 1.hour.ago
  end
  
  private
  
  def generate_room_id
    self.room_id = SecureRandom.uuid if room_id.blank?
  end
end
