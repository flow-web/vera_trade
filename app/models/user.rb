class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :listings, dependent: :destroy
  has_many :vehicles, through: :listings
  
  has_many :conversations, foreign_key: :user_id, dependent: :destroy
  has_many :other_conversations, class_name: 'Conversation', foreign_key: :other_user_id, dependent: :destroy
  has_many :messages, foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient_id, dependent: :destroy

  has_one :wallet, dependent: :destroy
  has_many :wallet_transactions, through: :wallet
  
  has_many :search_presets, dependent: :destroy

  after_create :create_wallet

  def other_users
    User.where.not(id: id)
  end

  private

  def create_wallet
    create_wallet!(balance: 0)
  end
end
