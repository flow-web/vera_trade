class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :other_user, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates :user_id, uniqueness: { scope: :other_user_id }

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_count
    messages.where(recipient: user, read: false).count
  end
end 