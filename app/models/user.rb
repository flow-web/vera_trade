class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :listings, dependent: :destroy
  has_many :vehicles, through: :listings
  
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :destroy
  
  has_one :wallet, dependent: :destroy
  
  after_create :create_wallet
  
  def other_users
    User.where.not(id: id)
  end
  
  def create_wallet
    Wallet.find_or_create_by!(user_id: id) do |wallet|
      wallet.balance_cents = 0
    end
  end
  
  def conversations
    Message.where(sender_id: id).or(Message.where(recipient_id: id))
  end
end
