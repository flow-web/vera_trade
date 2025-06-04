class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :other_user, class_name: 'User'
  belongs_to :listing, optional: true
  has_many :messages, dependent: :destroy
  has_many :video_calls, dependent: :destroy

  validates :user_id, uniqueness: { scope: :other_user_id }
  
  # Enums for status
  enum :status, { 
    active: 'active', 
    archived: 'archived', 
    blocked: 'blocked',
    completed: 'completed'
  }, default: 'active'
  
  scope :active_for_user, ->(user) { 
    where(
      "(user_id = ? AND (archived_by_user = false OR archived_by_user IS NULL)) OR 
       (other_user_id = ? AND (archived_by_other_user = false OR archived_by_other_user IS NULL))",
      user.id, user.id
    ).where(status: ['active', 'completed'])
  }
  
  scope :archived_for_user, ->(user) { 
    where(
      "(user_id = ? AND archived_by_user = true) OR 
       (other_user_id = ? AND archived_by_other_user = true)",
      user.id, user.id
    )
  }
  
  scope :recent_activity, -> { order(last_activity_at: :desc, updated_at: :desc) }

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    messages.where(recipient: user, read: false).count
  end
  
  def other_participant(current_user)
    current_user == user ? other_user : user
  end
  
  def archive_for!(user)
    if user == self.user
      update!(archived_by_user: true)
    elsif user == other_user
      update!(archived_by_other_user: true)
    end
  end
  
  def unarchive_for!(user)
    if user == self.user
      update!(archived_by_user: false)
    elsif user == other_user
      update!(archived_by_other_user: false)
    end
  end
  
  def archived_for?(user)
    if user == self.user
      archived_by_user?
    elsif user == other_user
      archived_by_other_user?
    else
      false
    end
  end
  
  def update_activity!
    update!(last_activity_at: Time.current)
  end
  
  def self.between(user1, user2)
    where(
      "(user_id = ? AND other_user_id = ?) OR (user_id = ? AND other_user_id = ?)",
      user1.id, user2.id, user2.id, user1.id
    ).first
  end
  
  def self.find_or_create_between(user1, user2, listing = nil)
    conversation = between(user1, user2)
    
    unless conversation
      conversation = create!(
        user: user1,
        other_user: user2,
        listing: listing,
        last_activity_at: Time.current
      )
    end
    
    conversation
  end
end 